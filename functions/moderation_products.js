const admin = require("firebase-admin");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────────────────────────
// In-memory cache (version invalidation + TTL safety)
// ─────────────────────────────────────────────────────────────
let blacklistCache = null; // { version, normalizedTerms }
let whitelistCache = null;
let cacheLoadedAtMs = 0;
const CACHE_TTL_MS = 5 * 60 * 1000;

// ─────────────────────────────────────────────────────────────
// helpers
// ─────────────────────────────────────────────────────────────
function isTimestamp(v) {
  return v && typeof v.toDate === "function" && typeof v.toMillis === "function";
}

function deepEqual(a, b) {
  if (a === b) return true;
  if (a == null || b == null) return a === b;
  if (typeof a !== typeof b) return false;

  if (isTimestamp(a) && isTimestamp(b)) return a.toMillis() === b.toMillis();

  if (Array.isArray(a)) {
    if (!Array.isArray(b) || a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) if (!deepEqual(a[i], b[i])) return false;
    return true;
  }

  if (typeof a === "object") {
    const ak = Object.keys(a).sort();
    const bk = Object.keys(b).sort();
    if (ak.length !== bk.length) return false;
    for (let i = 0; i < ak.length; i++) if (ak[i] !== bk[i]) return false;
    for (const k of ak) if (!deepEqual(a[k], b[k])) return false;
    return true;
  }

  return false;
}

function stripForContentCompare(data) {
  if (!data || typeof data !== "object") return data;
  const clone = JSON.parse(JSON.stringify(data));
  delete clone.moderation;
  delete clone.updated_at;
  return clone;
}

function isModerationOnlyWrite(before, after) {
  if (!before) return false;
  const contentSame = deepEqual(stripForContentCompare(before), stripForContentCompare(after));
  const moderationChanged = !deepEqual(before?.moderation ?? null, after?.moderation ?? null);
  return contentSame && moderationChanged;
}

function normalizeArabic(s) {
  const diacritics = /[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]/g; // tashkeel etc.
  const tatweel = /\u0640/g;

  let out = s.replace(diacritics, "").replace(tatweel, "");
  out = out
    .replace(/[أإآ]/g, "ا")
    .replace(/ى/g, "ي")
    .replace(/ة/g, "ه");
  return out;
}

function normalizeText(input) {
  if (typeof input !== "string") return "";
  let s = input.toLowerCase().trim();
  s = s.replace(/[^\p{L}\p{N}\s]+/gu, " "); // remove symbols/emojis -> spaces
  s = normalizeArabic(s);
  s = s.replace(/\s+/g, " ").trim();
  return s;
}

async function loadTermsCached(kind) {
  const now = Date.now();
  const useTTL = now - cacheLoadedAtMs < CACHE_TTL_MS;

  const cache = kind === "blacklist" ? blacklistCache : whitelistCache;
  if (cache && useTTL) return cache;

  const snap = await db.doc(`moderation/${kind}`).get();
  const data = snap.exists ? snap.data() : {};
  const version = typeof data?.version === "number" ? data.version : 0;
  const terms = Array.isArray(data?.terms) ? data.terms.filter((t) => typeof t === "string") : [];

  if (cache && cache.version === version) {
    cacheLoadedAtMs = now;
    return cache;
  }

  const normalizedTerms = terms.map(normalizeText).filter((t) => t.length >= 2);
  const updated = { version, normalizedTerms };

  if (kind === "blacklist") blacklistCache = updated;
  else whitelistCache = updated;

  cacheLoadedAtMs = now;
  return updated;
}

function matchTerms(haystack, terms) {
  if (!haystack || !terms || !terms.length) return [];
  const hits = [];
  for (const t of terms) if (t && haystack.includes(t)) hits.push(t);
  return hits;
}

// ─────────────────────────────────────────────────────────────
// Cloud Function
// ─────────────────────────────────────────────────────────────
exports.moderateProductAfterWrite = onDocumentWritten(
  {
    document: "stores_public/{storeId}/products/{productId}",
    region: "europe-west3",
  },
  async (event) => {
    if (!event.data?.after?.exists) return; // ignore deletes

    const beforeExists = !!event.data.before?.exists;
    const before = beforeExists ? event.data.before.data() : null;
    const after = event.data.after.data();
    const ref = event.data.after.ref;

    // loop-guard: second trigger from our own moderation write
    if (beforeExists && isModerationOnlyWrite(before, after)) return;

    const storeId = event.params.storeId;
    const productId = event.params.productId;

    const nowTs = admin.firestore.Timestamp.now();

    // detect merchant content change (ignore moderation + updated_at)
    const contentChanged = !beforeExists
      ? true
      : !deepEqual(stripForContentCompare(before), stripForContentCompare(after));

    // updated_at server-managed
    let willPatchUpdatedAt = false;
    if (contentChanged) {
      const afterUpdatedAt = after?.updated_at;
      if (!isTimestamp(afterUpdatedAt)) {
        willPatchUpdatedAt = true;
      } else {
        const beforeUpdatedAt = before?.updated_at;
        const beforeMillis = isTimestamp(beforeUpdatedAt) ? beforeUpdatedAt.toMillis() : 0;
        const afterMillis = afterUpdatedAt.toMillis();
        if (!beforeExists || afterMillis === beforeMillis) willPatchUpdatedAt = true;
      }
    }

    const effectiveUpdatedAt = willPatchUpdatedAt
      ? nowTs
      : (isTimestamp(after?.updated_at) ? after.updated_at : nowTs);

    const mod = (after?.moderation && typeof after.moderation === "object") ? after.moderation : {};
    const hasModeration = !!after?.moderation && typeof after.moderation === "object";
    const modUpdatedAt = isTimestamp(mod?.updatedAt) ? mod.updatedAt : null;

    // RE-CHECK logic
    const needsCheck = !modUpdatedAt || (effectiveUpdatedAt.toMillis() > modUpdatedAt.toMillis());

    if (!needsCheck) {
      if (willPatchUpdatedAt) await ref.update({ updated_at: nowTs });
      return;
    }

    // match in name/description/category
    const haystack = [
      normalizeText(after?.name),
      normalizeText(after?.description),
      normalizeText(after?.category),
    ].filter(Boolean).join(" ");

    const [whitelist, blacklist] = await Promise.all([
      loadTermsCached("whitelist"),
      loadTermsCached("blacklist"),
    ]);

    // whitelist wins
    const whitelistHits = matchTerms(haystack, whitelist.normalizedTerms);

    let violationHits = [];
    let autoBlocked = false;
    if (whitelistHits.length === 0) {
      violationHits = matchTerms(haystack, blacklist.normalizedTerms);
      autoBlocked = violationHits.length > 0;
    }

    // manualBlocked: NEVER overwrite
    const manualBlocked = mod?.manualBlocked === true;

    const prevAuto = mod?.autoBlocked === true;
    const nextAuto = autoBlocked;
    const nextMessageKey = nextAuto ? "product_policy_mismatch" : null;

    // minimal update payload
    const updatePayload = {};
    if (willPatchUpdatedAt) updatePayload["updated_at"] = nowTs;

    if (!hasModeration) {
      updatePayload["moderation.manualBlocked"] = false;
      updatePayload["moderation.autoBlocked"] = nextAuto;
      updatePayload["moderation.messageKey"] = nextMessageKey;
      updatePayload["moderation.updatedAt"] = nowTs;
      updatePayload["moderation.updatedBy"] = "system";
    } else {
      if ((mod?.autoBlocked === true) !== nextAuto) updatePayload["moderation.autoBlocked"] = nextAuto;
      if ((mod?.messageKey ?? null) !== nextMessageKey) updatePayload["moderation.messageKey"] = nextMessageKey;
      updatePayload["moderation.updatedAt"] = nowTs;
      if (mod?.updatedBy !== "system") updatePayload["moderation.updatedBy"] = "system";

      // default manualBlocked if missing (safe)
      if (typeof mod?.manualBlocked !== "boolean") updatePayload["moderation.manualBlocked"] = false;
    }

    if (Object.keys(updatePayload).length === 0) return;

    await ref.update(updatePayload);

    // Audit: ONLY here matchedTerms (never in product doc)
    const shouldLog = (!hasModeration) || (prevAuto !== nextAuto);
    if (shouldLog) {
      const action = manualBlocked
        ? "checked_while_manual_blocked"
        : (nextAuto ? "auto_blocked" : "auto_unblocked");

      await db.doc("moderation/events").collection("items").add({
        storeId,
        productId,
        action,
        ts: nowTs,
        prevAutoBlocked: prevAuto,
        nextAutoBlocked: nextAuto,
        matchedTerms: violationHits,
        blacklistVersion: blacklist.version,
        whitelistVersion: whitelist.version,
      });
    }

    logger.info("Product moderation finished", { storeId, productId, nextAuto, manualBlocked });
  }
);
