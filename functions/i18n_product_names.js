"use strict";

const admin = require("firebase-admin");
admin.initializeApp();

const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const crypto = require("crypto");

const db = admin.firestore();

// Secret
const DEEPL_AUTH_KEY = defineSecret("DEEPL_AUTH_KEY");

// Region
const REGION_PRIMARY = process.env.REGION_PRIMARY || "europe-west3";

// ---------------- helpers ----------------
function normalizeText(s) {
  return String(s ?? "").trim().replace(/\s+/g, " ");
}

function sha1(s) {
  return crypto.createHash("sha1").update(String(s ?? ""), "utf8").digest("hex");
}

function dictKeyFromText(text) {
  // zentrale Keys stabil machen (case + spaces)
  return sha1(normalizeText(text).toLowerCase());
}

// ---------------- in-memory cache (warm instance) ----------------
// Getrennte caches für product & category, damit nicht vermischt wird.
const memCache = {
  product: new Map(),   // key -> { translations, ts }
  category: new Map(),  // key -> { translations, ts }
};

const pending = {
  product: new Map(),   // key -> Promise<translations>
  category: new Map(),
};

const MEM_TTL_MS = 10 * 60 * 1000; // 10 min

// ---------------- DeepL Auto-Detect ----------------
// Wichtig: kein source_lang => Auto-Detect
async function deeplTranslateAuto(text, targetLang) {
  const authKey = DEEPL_AUTH_KEY.value();
  const endpoint = "https://api-free.deepl.com/v2/translate"; // DeepL API Free

  const params = new URLSearchParams();
  params.append("text", text);
  params.append("target_lang", targetLang.toUpperCase());

  const res = await fetch(endpoint, {
    method: "POST",
    headers: {
      Authorization: `DeepL-Auth-Key ${authKey}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: params.toString(),
  });

  if (res.status === 456) {
    const err = new Error("DeepL quota exceeded");
    err.code = 456;
    throw err;
  }
  if (!res.ok) {
    throw new Error(`DeepL error ${res.status}: ${await res.text()}`);
  }

  const json = await res.json();
  const t = json?.translations?.[0]?.text;
  return typeof t === "string" && t.trim() ? t.trim() : null;
}

/**
 * Zentraler Dictionary-Read/Write:
 * - collection: "i18n_product_names" oder "i18n_category_names"
 * - cacheBucket: "product" oder "category"
 */
async function getOrCreateCentralTranslations(collection, cacheBucket, originalText) {
  const text = normalizeText(originalText);
  const key = dictKeyFromText(text);

  // 1) warm cache
  const cached = memCache[cacheBucket].get(key);
  if (cached && Date.now() - cached.ts < MEM_TTL_MS) {
    return { key, translations: cached.translations };
  }

  // 2) in-flight dedup (pro warm instance)
  if (pending[cacheBucket].has(key)) {
    const t = await pending[cacheBucket].get(key);
    return { key, translations: t };
  }

  const p = (async () => {
    const ref = db.collection(collection).doc(key);

    // read existing
    const snap = await ref.get();
    if (snap.exists) {
      const d = snap.data() || {};
      if (d.status === "ready" && d.translations) {
        memCache[cacheBucket].set(key, { translations: d.translations, ts: Date.now() });
        return d.translations;
      }
    }

    // lock/create (best effort)
    try {
      await ref.create({
        textOriginal: text,
        status: "translating",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // exists already
    }

    // re-check
    const snap2 = await ref.get();
    const d2 = snap2.data() || {};
    if (d2.status === "ready" && d2.translations) {
      memCache[cacheBucket].set(key, { translations: d2.translations, ts: Date.now() });
      return d2.translations;
    }

    // translate into 3 targets, store original as ar fallback
    const translations = {
      ar: text,
      en: await deeplTranslateAuto(text, "en"),
      de: await deeplTranslateAuto(text, "de"),
      tr: await deeplTranslateAuto(text, "tr"),
    };

    await ref.set(
      {
        translations,
        status: "ready",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    memCache[cacheBucket].set(key, { translations, ts: Date.now() });
    return translations;
  })();

  pending[cacheBucket].set(key, p);
  try {
    const translations = await p;
    return { key, translations };
  } finally {
    pending[cacheBucket].delete(key);
  }
}

// ---------------- Trigger (ONE function for name + category) ----------------
exports.translateProductNamePublic = onDocumentWritten(
  {
    region: REGION_PRIMARY,
    document: "stores_public/{storeId}/products/{productId}",
    secrets: [DEEPL_AUTH_KEY],
  },
  async (event) => {
    const after = event.data && event.data.after;
    if (!after || !after.exists) return;

    const data = after.data() || {};

    // ---------------- PRODUCT NAME ----------------
    const nameRaw = typeof data.name === "string" ? data.name : "";
    const nameText = normalizeText(nameRaw);

    // Hash "nur einmal" pro aktuellem Produktnamen
    const nameHash = nameText ? sha1(nameText) : null;

    const nameAlreadyOk =
      !!nameText &&
      data.nameTranslationHash === nameHash &&
      data.name_i18n &&
      typeof data.name_i18n === "object";

    // ---------------- CATEGORY (Fall B: String) ----------------
    const catRaw = typeof data.category === "string" ? data.category : "";
    const catText = normalizeText(catRaw);

    const catHash = catText ? sha1(catText) : null;

    const categoryAlreadyOk =
      !!catText &&
      data.categoryTranslationHash === catHash &&
      data.category_i18n &&
      typeof data.category_i18n === "object";

    // Wenn beides schon passt -> nichts tun
    if ((nameText ? nameAlreadyOk : true) && (catText ? categoryAlreadyOk : true)) return;

    const updates = {};

    // ---------- translate name if needed ----------
    if (nameText && !nameAlreadyOk) {
      try {
        const { translations } = await getOrCreateCentralTranslations(
          "i18n_product_names",
          "product",
          nameText
        );

        updates.name_i18n = { ...(data.name_i18n || {}), ...translations };
        updates.nameTranslationHash = nameHash;
        updates.nameTranslatedAt = admin.firestore.FieldValue.serverTimestamp();
        updates.nameTranslationVersion = 1;
        updates.nameTranslationStatus = "ready";
      } catch (e) {
        const status = e && e.code === 456 ? "quota_exceeded" : "error";
        updates.nameTranslationStatus = status;
        updates.nameTranslationHash = nameHash;
        console.error("Name translation failed:", e);
      }
    }

    // ---------- translate category (string) if needed ----------
    if (catText && !categoryAlreadyOk) {
      try {
        const { translations } = await getOrCreateCentralTranslations(
          "i18n_category_names",
          "category",
          catText
        );

        updates.category_i18n = { ...(data.category_i18n || {}), ...translations };
        updates.categoryTranslationHash = catHash;
        updates.categoryTranslatedAt = admin.firestore.FieldValue.serverTimestamp();
        updates.categoryTranslationVersion = 1;
        updates.categoryTranslationStatus = "ready";
      } catch (e) {
        const status = e && e.code === 456 ? "quota_exceeded" : "error";
        updates.categoryTranslationStatus = status;
        updates.categoryTranslationHash = catHash;
        console.error("Category translation failed:", e);
      }
    }

    // Falls keine updates entstanden (z.B. name leer und category leer)
    if (Object.keys(updates).length === 0) return;

    await after.ref.set(updates, { merge: true });
  }
);
