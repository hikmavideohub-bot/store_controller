"use strict";

const admin = require("firebase-admin");
admin.initializeApp();

const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const crypto = require("crypto");

const db = admin.firestore();
const REGION_PRIMARY = process.env.REGION_PRIMARY || "europe-west3";

const DEEPL_ENDPOINT = "https://api-free.deepl.com/v2/translate";
const DEEPL_AUTH_KEY = defineSecret("DEEPL_AUTH_KEY");

// Nur EIN Glossary: AR -> EN (classic one language pair)
const GLOSSARY_AR_EN = defineSecret("GLOSSARY_AR_EN");

const memCache = { product: new Map(), category: new Map() };
const pending = { product: new Map(), category: new Map() };
const MEM_TTL_MS = 10 * 60 * 1000;

function normalizeText(s) {
  return String(s ?? "").trim().replace(/\s+/g, " ");
}
function sha1(s) {
  return crypto.createHash("sha1").update(String(s ?? ""), "utf8").digest("hex");
}
function dictKey(bucket, sourceLang, text) {
  const base = normalizeText(text).toLowerCase();
  const sl = String(sourceLang || "AUTO").toUpperCase();
  return sha1(`${bucket}|${sl}|${base}`);
}

function baseProductContext() {
  return (
    "Context: This is a SHORT PRODUCT NAME for an online shop (retail/food). " +
    "Translate as a product label (a noun), not a verb and not a full sentence. " +
    "Prefer the food/retail meaning for ambiguous words. " +
    "Return only the product name, no extra words."
  );
}
function baseCategoryContext() {
  return (
    "Context: This is a PRODUCT CATEGORY label for an online shop. " +
    "Translate as a short category name (noun), not a sentence and not a verb."
  );
}
function productContextWithCategory(categoryText) {
  let ctx = baseProductContext();
  const cat = normalizeText(categoryText || "");
  if (cat) {
    ctx +=
      " Category (Arabic): " + cat + ". " +
      "The text to translate is a PRODUCT NAME within this category (food/retail).";
  }
  return ctx;
}
function enFoodContext(categoryText) {
  let ctx =
    "Context: Translate this as a FOOD product name (noun). " +
    "Use the food meaning (fruit/ingredient), not calendar dates and not a person name. " +
    "Return only the product name.";
  const cat = normalizeText(categoryText || "");
  if (cat) ctx += " Category (Arabic): " + cat + ".";
  return ctx;
}

function getGlossaryId(sourceLang, targetLang) {
  const s = String(sourceLang || "").toUpperCase();
  const t = String(targetLang || "").toUpperCase();
  if (s === "AR" && t === "EN") {
    const v = GLOSSARY_AR_EN.value?.();
    return typeof v === "string" && v.trim() ? v.trim() : null;
  }
  return null;
}

async function deeplRequest(params) {
  const authKey = DEEPL_AUTH_KEY.value();
  const res = await fetch(DEEPL_ENDPOINT, {
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
  if (!res.ok) throw new Error(`DeepL error ${res.status}: ${await res.text()}`);
  return res.json();
}

async function deeplDetectSourceLang(text, context) {
  const params = new URLSearchParams();
  params.append("text", text);
  params.append("target_lang", "EN");
  if (context) params.append("context", context);

  const json = await deeplRequest(params);
  const detected = json?.translations?.[0]?.detected_source_language;
  return typeof detected === "string" && detected.trim() ? detected.toUpperCase() : "AUTO";
}

async function deeplTranslate(text, sourceLang, targetLang, { context, glossaryId } = {}) {
  const params = new URLSearchParams();
  params.append("text", text);
  params.append("target_lang", String(targetLang).toUpperCase());

  if (sourceLang && sourceLang !== "AUTO") params.append("source_lang", String(sourceLang).toUpperCase());
  if (context) params.append("context", context);
  if (glossaryId && sourceLang && sourceLang !== "AUTO") params.append("glossary_id", glossaryId);

  const json = await deeplRequest(params);
  const out = json?.translations?.[0]?.text;
  return typeof out === "string" && out.trim() ? out.trim() : null;
}

// ---------- Central dictionary ----------
async function getOrCreateCentralTranslations(collection, bucket, originalText, opts = {}) {
  const text = normalizeText(originalText);

  const detectCtx =
    bucket === "product"
      ? productContextWithCategory(opts.categoryText)
      : baseCategoryContext();

  const sourceLang = await deeplDetectSourceLang(text, detectCtx);
  const key = dictKey(bucket, sourceLang, text);

  const cached = memCache[bucket].get(key);
  if (cached && Date.now() - cached.ts < MEM_TTL_MS) {
    return { key, sourceLang, translations: cached.translations };
  }
  if (pending[bucket].has(key)) {
    const t = await pending[bucket].get(key);
    return { key, sourceLang, translations: t };
  }

  const p = (async () => {
    const ref = db.collection(collection).doc(key);

    const snap = await ref.get();
    if (snap.exists) {
      const d = snap.data() || {};
      if (d.status === "ready" && d.translations) {
        memCache[bucket].set(key, { translations: d.translations, ts: Date.now() });
        return d.translations;
      }
    }

    try {
      await ref.create({
        status: "translating",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        textOriginal: text,
        sourceLang,
      });
    } catch (_) {}

    // build translations
    const translations = {};
    // Original exakt behalten
    const sl = sourceLang.toLowerCase();
    if (["ar","en","de","tr"].includes(sl)) translations[sl] = text;

    if (bucket === "category") {
      const ctx = baseCategoryContext();
      // Kategorien: direkt aus sourceLang übersetzen
      for (const tgt of ["AR","EN","DE","TR"]) {
        if (tgt === sourceLang) continue;
        const k = tgt.toLowerCase();
        if (translations[k]) continue;
        translations[k] = await deeplTranslate(text, sourceLang, tgt, { context: ctx });
      }
    } else {
      // Produkte: erst meaningEn (mit AR->EN Glossary), dann DE/TR aus EN
      const ctxProd = productContextWithCategory(opts.categoryText);
      const g = getGlossaryId(sourceLang, "EN");
      const meaningEn =
        sourceLang === "EN"
          ? text
          : (await deeplTranslate(text, sourceLang, "EN", { context: ctxProd, glossaryId: g })) || text;

      translations.en = meaningEn;

      const ctxEn = enFoodContext(opts.categoryText);

      if (sourceLang !== "DE") translations.de = await deeplTranslate(meaningEn, "EN", "DE", { context: ctxEn });
      if (sourceLang !== "TR") translations.tr = await deeplTranslate(meaningEn, "EN", "TR", { context: ctxEn });

      // AR nur dann aus EN erzeugen, wenn Original nicht AR
      if (sourceLang !== "AR") translations.ar = await deeplTranslate(meaningEn, "EN", "AR", { context: ctxProd });
    }

    await ref.set(
      {
        status: "ready",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        translations,
      },
      { merge: true }
    );

    memCache[bucket].set(key, { translations, ts: Date.now() });
    return translations;
  })();

  pending[bucket].set(key, p);
  try {
    const translations = await p;
    return { key, sourceLang, translations };
  } finally {
    pending[bucket].delete(key);
  }
}

// ---------- Trigger ----------
exports.translateProductNamePublic = onDocumentWritten(
  {
    region: REGION_PRIMARY,
    document: "stores_public/{storeId}/products/{productId}",
    secrets: [DEEPL_AUTH_KEY, GLOSSARY_AR_EN],
  },
  async (event) => {
    const after = event.data?.after;
    if (!after || !after.exists) return;

    const data = after.data() || {};

    const nameText = normalizeText(typeof data.name === "string" ? data.name : "");
    const nameHash = nameText ? sha1(nameText) : null;

    const catText = normalizeText(typeof data.category === "string" ? data.category : "");
    const catHash = catText ? sha1(catText) : null;

    const nameAlreadyOk =
      !!nameText &&
      data.nameTranslationHash === nameHash &&
      data.name_i18n &&
      typeof data.name_i18n === "object" &&
      data.nameTranslationStatus === "ready";

    const categoryAlreadyOk =
      !!catText &&
      data.categoryTranslationHash === catHash &&
      data.category_i18n &&
      typeof data.category_i18n === "object" &&
      data.categoryTranslationStatus === "ready";

    if ((nameText ? nameAlreadyOk : true) && (catText ? categoryAlreadyOk : true)) return;

    const updates = {};

    if (catText && !categoryAlreadyOk) {
      try {
        const { translations } = await getOrCreateCentralTranslations("i18n_category_names", "category", catText);
        updates.category_i18n = { ...(data.category_i18n || {}), ...translations };
        updates.categoryTranslationHash = catHash;
        updates.categoryTranslatedAt = admin.firestore.FieldValue.serverTimestamp();
        updates.categoryTranslationVersion = 20;
        updates.categoryTranslationStatus = "ready";
      } catch (e) {
        updates.categoryTranslationStatus = e?.code === 456 ? "quota_exceeded" : "error";
        updates.categoryTranslationHash = catHash;
        console.error("Category translation failed:", e);
      }
    }

    if (nameText && !nameAlreadyOk) {
      try {
        const { translations } = await getOrCreateCentralTranslations(
          "i18n_product_names",
          "product",
          nameText,
          { categoryText: catText }
        );

        updates.name_i18n = { ...(data.name_i18n || {}), ...translations };
        updates.nameTranslationHash = nameHash;
        updates.nameTranslatedAt = admin.firestore.FieldValue.serverTimestamp();
        updates.nameTranslationVersion = 20;
        updates.nameTranslationStatus = "ready";
      } catch (e) {
        updates.nameTranslationStatus = e?.code === 456 ? "quota_exceeded" : "error";
        updates.nameTranslationHash = nameHash;
        console.error("Name translation failed:", e);
      }
    }

    if (Object.keys(updates).length === 0) return;
    await after.ref.set(updates, { merge: true });
  }
);
