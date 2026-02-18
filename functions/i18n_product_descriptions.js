"use strict";

const admin = require("firebase-admin");
admin.initializeApp();

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const crypto = require("crypto");

const db = admin.firestore();
const REGION_PRIMARY = process.env.REGION_PRIMARY || "europe-west3";

// Azure Translator secrets
const AZURE_TRANSLATOR_KEY = defineSecret("AZURE_TRANSLATOR_KEY");
const AZURE_TRANSLATOR_ENDPOINT = defineSecret("AZURE_TRANSLATOR_ENDPOINT");
const AZURE_TRANSLATOR_REGION = defineSecret("AZURE_TRANSLATOR_REGION");

// Gemini API Secret & Import
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const { GoogleGenerativeAI } = require("@google/generative-ai");

// Constants
const SUPPORTED_LANGS = ["ar", "de", "en", "tr"];
const MAX_DESC_LEN = 300; // only for auto-translate, NOT for manual edits
const MONTHLY_CHAR_LIMIT = 2_000_000;
const BUDGET_REF_PATH = "system/desc_translation_budget";

// ---------- Helpers ----------

function currentMonthBerlin() {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Europe/Berlin",
    year: "numeric",
    month: "2-digit",
  }).formatToParts(new Date());
  const y = parts.find((p) => p.type === "year").value;
  const m = parts.find((p) => p.type === "month").value;
  return `${y}-${m}`;
}

function truncate(text, maxLen) {
  return text.length <= maxLen ? text : text.slice(0, maxLen);
}

function sha1(s) {
  return crypto.createHash("sha1").update(String(s ?? ""), "utf8").digest("hex");
}

/**
 * Extract input text and source hint from the description field.
 * String  → inputText, no sourceHint
 * Map     → first non-empty value from ar/de/en/tr, key as sourceHint
 */
function extractInput(description) {
  if (typeof description === "string") {
    const text = description.trim();
    return text ? { inputText: text, sourceHint: null } : null;
  }
  if (description && typeof description === "object") {
    for (const lang of SUPPORTED_LANGS) {
      const val = description[lang];
      if (typeof val === "string" && val.trim()) {
        return { inputText: val.trim(), sourceHint: lang };
      }
    }
  }
  return null;
}

// ---------- Azure Translator ----------

async function azureDetect(text) {
  const endpoint = AZURE_TRANSLATOR_ENDPOINT.value();
  const key = AZURE_TRANSLATOR_KEY.value();
  const region = AZURE_TRANSLATOR_REGION.value();

  const res = await fetch(`${endpoint}/detect?api-version=3.0`, {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": key,
      "Ocp-Apim-Subscription-Region": region,
      "Content-Type": "application/json",
    },
    body: JSON.stringify([{ Text: text }]),
  });

  if (!res.ok) {
    throw new Error(`Azure detect error ${res.status}: ${await res.text()}`);
  }

  const json = await res.json();
  const detected = json?.[0];
  return {
    language: detected?.language ?? null,
    score: detected?.score ?? 0,
  };
}

async function azureTranslate(text, fromLang, targetLangs) {
  const endpoint = AZURE_TRANSLATOR_ENDPOINT.value();
  const key = AZURE_TRANSLATOR_KEY.value();
  const region = AZURE_TRANSLATOR_REGION.value();

  const toParams = targetLangs.map((l) => `to=${l}`).join("&");
  const url = `${endpoint}/translate?api-version=3.0&from=${fromLang}&${toParams}`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": key,
      "Ocp-Apim-Subscription-Region": region,
      "Content-Type": "application/json",
    },
    body: JSON.stringify([{ Text: text }]),
  });

  if (res.status === 429) {
    const err = new Error("Azure Translator rate limited (429)");
    err.code = 429;
    throw err;
  }

  if (!res.ok) {
    throw new Error(`Azure translate error ${res.status}: ${await res.text()}`);
  }

  const json = await res.json();
    const translations = {};
    for (const t of json?.[0]?.translations ?? []) {
      if (t.to && t.text) translations[t.to] = t.text;
    }
    return translations;
  }

  // ---------- Gemini Translator ----------
  async function geminiTranslate(text, sourceLang, targetLangs) {
    console.log(`[Gemini] Starte Übersetzung von ${sourceLang} nach ${targetLangs.join(", ")}`);

    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY.value());

    // WICHTIG: Wir zwingen das Modell auf JSON-Ausgabe
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      generationConfig: { responseMimeType: "application/json" }
    });

    const prompt = `
    Übersetze die folgende Produktbeschreibung von ${sourceLang} in die folgenden Sprachen: ${targetLangs.join(", ")}.
    Gib als Antwort NUR ein JSON-Objekt zurück. Die Keys müssen die Sprachcodes sein (z.B. "en", "de", "tr", "ar") und die Values die Übersetzungen.
    Text: "${text}"
    `;

    const result = await model.generateContent(prompt);
    let responseText = result.response.text();

    console.log(`[Gemini] Rohe Antwort vom Server:`, responseText);

    return JSON.parse(responseText);
  }

  // ---------- Fallback Wrapper (Gemini -> Azure) ----------
  async function translateWithFallback(text, sourceLang, targetLangs) {
    try {
      const translations = await geminiTranslate(text, sourceLang, targetLangs);
      console.log(`[translateWithFallback] Gemini war erfolgreich!`);
      return { translations, provider: "gemini" };
    } catch (error) {
      // Hier loggen wir GANZ GENAU, was schiefgelaufen ist!
      console.error(`[translateWithFallback] GEMINI ABSTURZ: ${error.message}`);
      console.error(`[translateWithFallback] Vollständiger Error:`, error);
      console.log(`[translateWithFallback] Wechsle zu Azure Fallback...`);

      const translations = await azureTranslate(text, sourceLang, targetLangs);
      return { translations, provider: "azure" };
    }
  }

  // ---------- Budget + Lock (atomic) ----------

/**
 * Atomically: check autoTranslateUsed lock, reserve char budget,
 * and set the lock + processing status on the product doc.
 *
 * Returns "OK" | "BUDGET_EXCEEDED" | "ALREADY_USED"
 *
 * On BUDGET_EXCEEDED the product is flagged pending_quota + locked
 * so double-clicks cannot queue twice.
 */
async function reserveBudgetAndLock(charCount, productRef) {
  const budgetRef = db.doc(BUDGET_REF_PATH);
  const month = currentMonthBerlin();

  return db.runTransaction(async (t) => {
    // ---- reads first ----
    const budgetSnap = await t.get(budgetRef);
    const prodSnap = await t.get(productRef);

    const budgetData = budgetSnap.exists ? budgetSnap.data() : {};
    const prodData = prodSnap.exists ? prodSnap.data() : {};
    const meta = prodData.description_meta || {};

    // Double-click / parallel-call protection
    if (meta.autoTranslateUsed === true) return "ALREADY_USED";

    // Budget check
    let usedChars = budgetData.usedChars || 0;
    const docMonth = budgetData.month || "";
    const limit = budgetData.limit || MONTHLY_CHAR_LIMIT;
    if (docMonth !== month) usedChars = 0;

    if (usedChars + charCount > limit) {
      // Lock flag + set status (prevents double-queuing)
      t.set(productRef, {
        descTranslationStatus: "pending_quota",
        description_meta: { autoTranslateUsed: true },
      }, { merge: true });
      return "BUDGET_EXCEEDED";
    }

    // Reserve budget + lock + set processing status
    t.set(budgetRef, { month, usedChars: usedChars + charCount, limit }, { merge: true });
    t.set(productRef, {
      descTranslationStatus: "processing",
      description_meta: { autoTranslateUsed: true },
    }, { merge: true });

    return "OK";
  });
}

/**
 * Budget-only reservation for the scheduler (no lock check).
 * Returns true if reserved, false if over limit.
 */
async function reserveBudget(charCount) {
  const budgetRef = db.doc(BUDGET_REF_PATH);
  const month = currentMonthBerlin();

  return db.runTransaction(async (t) => {
    const budgetSnap = await t.get(budgetRef);
    const budgetData = budgetSnap.exists ? budgetSnap.data() : {};

    let usedChars = budgetData.usedChars || 0;
    const docMonth = budgetData.month || "";
    const limit = budgetData.limit || MONTHLY_CHAR_LIMIT;
    if (docMonth !== month) usedChars = 0;

    if (usedChars + charCount > limit) return false;

    t.set(budgetRef, { month, usedChars: usedChars + charCount, limit }, { merge: true });
    return true;
  });
}

async function queuePending(productRefPath, inputText, sourceHint, status = "pending_quota") {
  await db.collection("pending_desc_translations").add({
    productRef: productRefPath,
    inputText,
    sourceHint: sourceHint || null,
    status,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ==========================================================================
// 1) onCreate — Normalize ALWAYS, translate ONLY if descAutoTranslateRequested==true
// ==========================================================================

exports.translateProductDescription = onDocumentCreated(
  {
    document: "stores_public/{storeId}/products/{productId}",
    region: REGION_PRIMARY,
    // IMPORTANT: needed because we may call Azure or Gemini here
    secrets: [AZURE_TRANSLATOR_KEY, AZURE_TRANSLATOR_ENDPOINT, AZURE_TRANSLATOR_REGION, GEMINI_API_KEY],
    timeoutSeconds: 120,
  },
  async (event) => {
    const snap = event.data;
    if (!snap?.exists) return;

    const data = snap.data() || {};
    const desc = data.description;
    const meta = data.description_meta || {};

    const requested = data.descAutoTranslateRequested === true;
    const sourceHintDoc =
      typeof data.sourceHint === "string" && SUPPORTED_LANGS.includes(data.sourceHint)
        ? data.sourceHint
        : null;

    // ---- 1) Normalize to 4-lang map (always) ----
    const normalized = { ar: "", de: "", en: "", tr: "" };

    if (typeof desc === "string") {
      normalized.ar = desc.trim();
    } else if (desc && typeof desc === "object" && !Array.isArray(desc)) {
      for (const lang of SUPPORTED_LANGS) {
        normalized[lang] = typeof desc[lang] === "string" ? desc[lang] : "";
      }
    }

    const descIsMap = desc && typeof desc === "object" && !Array.isArray(desc);
    const allKeysPresent = descIsMap && SUPPORTED_LANGS.every((l) => typeof desc[l] === "string");
    const needsNormalize = typeof desc === "string" || !allKeysPresent;
    const needsMeta = meta.autoTranslateUsed === undefined || meta.autoTranslateUsed === null;

    const baseUpdates = {};
    if (needsNormalize) baseUpdates.description = normalized;
    if (needsMeta) baseUpdates.description_meta = { ...meta, autoTranslateUsed: false };

    if (Object.keys(baseUpdates).length) {
      await snap.ref.set(baseUpdates, { merge: true });
    }

    // If not requested -> done after normalization
    if (!requested) return;

    // Prevent double-run if already used
    if (meta.autoTranslateUsed === true) return;

    // ---- 2) Pick source text (full text stays in Firestore) ----
    function pickSourceText(map, prefer) {
      if (prefer && (map[prefer] || "").trim()) {
        return { text: map[prefer].trim(), hint: prefer };
      }
      for (const l of SUPPORTED_LANGS) {
        const v = (map[l] || "").trim();
        if (v) return { text: v, hint: l };
      }
      return null;
    }

    const picked = pickSourceText(normalized, sourceHintDoc);
    if (!picked) {
      await snap.ref.set(
        {
          descTranslationStatus: "no_source",
          descAutoTranslateRequested: admin.firestore.FieldValue.delete(),
        },
        { merge: true }
      );
      return;
    }

    // Azure should only see max 300 chars (UI also enforces it, but backend is final gate)
    const inputTextForAuto = truncate(picked.text, MAX_DESC_LEN);

    // ---- 3) Detect source lang ----
    let sourceLang = picked.hint || "ar";
    try {
      const det = await azureDetect(inputTextForAuto);
      if (det.language && SUPPORTED_LANGS.includes(det.language) && det.score >= 0.6) {
        sourceLang = det.language;
      }
    } catch (_) {
      // keep fallback
    }

    const targetLangs = SUPPORTED_LANGS.filter((l) => l !== sourceLang);
    const chargedChars = inputTextForAuto.length * targetLangs.length;

    // ---- 4) Budget reserve + one-shot lock (atomic) ----
    const reserveResult = await reserveBudgetAndLock(chargedChars, snap.ref);

    if (reserveResult === "ALREADY_USED") return;

    if (reserveResult === "BUDGET_EXCEEDED") {
      await queuePending(snap.ref.path, inputTextForAuto, picked.hint, "pending_quota");
      await snap.ref.set(
        { descAutoTranslateRequested: admin.firestore.FieldValue.delete() },
        { merge: true }
      );
      return;
    }

    // ---- 5) Translate + write (fill ONLY empty target fields) ----
      try {
        const { translations, provider } = await translateWithFallback(inputTextForAuto, sourceLang, targetLangs);

        const currentDesc = { ...normalized };

      // NEVER overwrite non-empty values (manual text wins)
      // SourceLang stays full manual text (not truncated) if already present
      if (!(currentDesc[sourceLang] ?? "").trim()) {
        currentDesc[sourceLang] = picked.text; // keep full original user text
      }

      for (const lang of targetLangs) {
        if (!(currentDesc[lang] ?? "").trim() && translations[lang]) {
          currentDesc[lang] = translations[lang];
        }
      }

      for (const lang of SUPPORTED_LANGS) {
        if (currentDesc[lang] === undefined) currentDesc[lang] = "";
      }

      const hash = sha1(inputTextForAuto);

      await snap.ref.set(
        {
          description: currentDesc,
          descTranslationStatus: "ready",
          descAutoTranslateRequested: admin.firestore.FieldValue.delete(),
          sourceHint: admin.firestore.FieldValue.delete(),
          description_meta: {
                      autoTranslateUsed: true,
                      provider: provider,
                      sourceLang,
            autoSourceText: inputTextForAuto,
            hash,
            translatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
        },
        { merge: true }
      );
    } catch (error) {
      await queuePending(snap.ref.path, inputTextForAuto, picked.hint, "pending_retry");
      await snap.ref.set(
        {
          descTranslationStatus: "pending_retry",
          descAutoTranslateRequested: admin.firestore.FieldValue.delete(),
          description_meta: {
            autoTranslateUsed: true,
            lastError: String(error?.message || error),
          },
        },
        { merge: true }
      );
    }
  }
);


// ==========================================================================
// 3) Callable — translateProductDescriptionOnce (user clicks button)
// ==========================================================================


// ==========================================================================
// 4) Scheduler — process pending_quota + pending_retry jobs
// ==========================================================================

exports.runPendingDescTranslations = onSchedule(
  {
    schedule: "0 0 1 * *",
    region: REGION_PRIMARY,
        secrets: [AZURE_TRANSLATOR_KEY, AZURE_TRANSLATOR_ENDPOINT, AZURE_TRANSLATOR_REGION, GEMINI_API_KEY],
    timeoutSeconds: 540,
  },
  async () => {
    const month = currentMonthBerlin();

    // 1. Reset budget if month rolled over
    const budgetRef = db.doc(BUDGET_REF_PATH);
    const budgetSnap = await budgetRef.get();
    const budgetData = budgetSnap.exists ? budgetSnap.data() : {};

    if (budgetData.month !== month) {
      await budgetRef.set(
        { month, usedChars: 0, limit: budgetData.limit || MONTHLY_CHAR_LIMIT },
        { merge: true }
      );
      console.log(`[runPendingDescTranslations] Budget reset for ${month}`);
    }

    // 2. Process pending_quota + pending_retry jobs
    const PENDING_STATUSES = ["pending_quota", "pending_retry"];
    const PAGE = 50;
    let processed = 0;
    let budgetExhausted = false;

    for (const status of PENDING_STATUSES) {
      if (budgetExhausted) break;
      let lastDoc = null;

      for (;;) {
        if (budgetExhausted) break;

        let q = db
          .collection("pending_desc_translations")
          .where("status", "==", status)
          .orderBy("createdAt")
          .limit(PAGE);

        if (lastDoc) q = q.startAfter(lastDoc);

        const snap = await q.get();
        if (snap.empty) break;

        for (const doc of snap.docs) {
          const job = doc.data();
          const { productRef: refPath, inputText, sourceHint } = job;

          if (!refPath || !inputText) {
            await doc.ref.update({ status: "invalid" });
            continue;
          }

          const productRef = db.doc(refPath);
          const prodSnap = await productRef.get();

          if (!prodSnap.exists) {
            await doc.ref.update({ status: "invalid" });
            continue;
          }

          const prodData = prodSnap.data();
          const inputTextForAuto = truncate(inputText, MAX_DESC_LEN);

          // Detect source language
          let sourceLang;
          try {
            const det = await azureDetect(inputTextForAuto);
            if (det.language && SUPPORTED_LANGS.includes(det.language) && det.score >= 0.6) {
              sourceLang = det.language;
            } else {
              sourceLang = sourceHint || "ar";
            }
          } catch {
            sourceLang = sourceHint || "ar";
          }

          const targetLangs = SUPPORTED_LANGS.filter((l) => l !== sourceLang);
          const chargedChars = inputTextForAuto.length * targetLangs.length;

          // Budget reservation (no lock check — already authorized by callable)
          const budgetOk = await reserveBudget(chargedChars);
          if (!budgetOk) {
            budgetExhausted = true;
            console.log(`[runPendingDescTranslations] Budget exhausted after ${processed} jobs`);
            break;
          }

          try {
            const { translations, provider } = await translateWithFallback(inputTextForAuto, sourceLang, targetLangs);

            // Fill only empty keys
            const currentDesc = prodData.description && typeof prodData.description === "object"
              ? { ...prodData.description }
              : {};

            if (!(currentDesc[sourceLang] ?? "").trim()) {
              currentDesc[sourceLang] = inputTextForAuto;
            }

            for (const lang of targetLangs) {
              if (!(currentDesc[lang] ?? "").trim() && translations[lang]) {
                currentDesc[lang] = translations[lang];
              }
            }

            for (const lang of SUPPORTED_LANGS) {
              if (currentDesc[lang] === undefined) currentDesc[lang] = "";
            }

            const hash = sha1(inputTextForAuto);

            await productRef.set({
              description: currentDesc,
              descTranslationStatus: "ready",
              description_meta: {
                              autoTranslateUsed: true,
                              provider: provider,
                              sourceLang,
                autoSourceText: inputTextForAuto,
                hash,
                translatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
            }, { merge: true });

            await doc.ref.update({
              status: "done",
              processedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            processed++;
          } catch (error) {
            console.error(
              `[runPendingDescTranslations] Error processing ${refPath}:`,
              error.message
            );
            await doc.ref.update({ lastError: error.message });
          }
        }

        if (snap.size < PAGE) break;
        lastDoc = snap.docs[snap.docs.length - 1];
      }
    }

    console.log(`[runPendingDescTranslations] Finished. Processed: ${processed}`);
  }
);
