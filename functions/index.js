/**
 * Firebase Cloud Functions - FINAL PROD VERSION (v2 Migration)
 * Location: functions/index.js
 */
//firebase deploy --only "functions:syncAccessToPublic,functions:syncStoreNameToPublic,functions:syncStoreNameToPrivate,functions:learnProductCategory,functions:seedDictionary"
//firebase deploy --only "functions:checkTrialExpiration,functions:cleanupExpiredAccounts,functions:refreshFxRates,functions:onStoreCreated,functions:onStoreActivated"
//firebase deploy --only "functions:getStoreBySlug,functions:getProductsBySlug,functions:cdnImageProxy,functions:reverseGeocode"
//firebase deploy --only "functions:stripeWebhook,functions:createStripeCheckoutSession,functions:verifyStorePayment,functions:confirmEmailVerification,functions:requestAccountDeletion,functions:finalizeStoreSetup,functions:resolveUserRegion,functions:syncStoreAccessToPublic"
//firebase deploy --only "functions:syncStoresOnProductDictUpdate,functions:syncStoresOnCategoryDictUpdate"
//firebase deploy --only "functions:checkTrialExpiration,functions:cleanupExpiredAccounts,functions:refreshFxRates,functions:onStoreCreated,functions:onStoreActivated,functions:syncAccessToPublic,functions:syncStoreNameToPublic,functions:syncStoreNameToPrivate,functions:learnProductCategory,functions:seedDictionary"
//firebase deploy --only "functions:translateProductDescription,runPendingDescTranslations"
require("dotenv").config();

// =============================================================================
// v2 IMPORTS
// =============================================================================
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated, onDocumentUpdated, onDocumentWritten } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const trackingSecret = defineSecret("TRACKING_SECRET__ew3");

// --- WICHTIG: DIESE ZEILE HINZUFÜGEN ---
const { setGlobalOptions } = require("firebase-functions/v2/options");
// ----------------------------------------

const admin = require("firebase-admin");
const axios = require("axios");

// 1. GLOBALE EINSTELLUNGEN SETZEN
// Niedrige globale Limits - individuelle Functions bekommen höhere Werte

admin.initializeApp();
const db = admin.firestore();

// =============================================================================
// STRIPE CONFIGURATION
// =============================================================================

const stripeSecret = defineSecret("STRIPE_SECRET__ew3");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET__ew3");
const googleMapsApiKey = defineSecret("GOOGLE_MAPS_API_KEY__ew3");
const seedSecret = defineSecret("SEED_SECRET__ew3");
const seedData = require("./seed_data.json");


const REGION_PRIMARY = "europe-west3"; // bleibt für App/Traffic
  //  const REGION_BG = "europe-west1";    Background

const GRACE_PERIODS = [7, 14];


// =============================================================================
// MULTILINGUAL EMAIL TEMPLATES (Unverändert)
// =============================================================================

const EMAIL_TEMPLATES = {
  // Plan Namen für alle Sprachen
  planNames: {
    ar: { yearly: 'السنة', biannual: '6 أشهر', monthly: 'شهر' },
    en: { yearly: '1 Year', biannual: '6 Months', monthly: '1 Month' },
    de: { yearly: '1 Jahr', biannual: '6 Monate', monthly: '1 Monat' },
    tr: { yearly: '1 Yıl', biannual: '6 Ay', monthly: '1 Ay' }
  },

  // 1. Trial/Abo Warnung (7 Tage vor Ablauf)
  trialWarning: {
    ar: {
      subject: 'تنبيه: اشتراك متجرك ينتهي خلال 7 أيام - Aldeeb',
      html: (storeName) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff;">
          <h2 style="color: #f0ad4e;">⚠️ تنبيه انتهاء التفعيل</h2>
          <p style="font-size: 18px; color: #444;">مرحباً <b>${storeName}</b>،</p>
          <p style="font-size: 16px; color: #555;">سينتهي تفعيل متجرك خلال <b style="color: #d9534f;">7 أيام</b>.</p>
          <p style="font-size: 14px; color: #777;">يرجى تجديد اشتراكك لضمان استمرار خدمات متجرك دون انقطاع.</p>
          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 14px;">فريق الديب تك - Aldeeb</p>
          </div>
        </div>
      `
    },
    en: {
      subject: 'Notice: Your store subscription expires in 7 days - Aldeeb',
      html: (storeName) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff;">
          <h2 style="color: #f0ad4e;">⚠️ Subscription Expiration Notice</h2>
          <p style="font-size: 18px; color: #444;">Hello <b>${storeName}</b>,</p>
          <p style="font-size: 16px; color: #555;">Your store subscription will expire in <b style="color: #d9534f;">7 days</b>.</p>
          <p style="font-size: 14px; color: #777;">Please renew your subscription to ensure uninterrupted service.</p>
          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 14px;">Aldeeb Team</p>
          </div>
        </div>
      `
    },
    de: {
      subject: 'Hinweis: Ihr Shop-Abonnement läuft in 7 Tagen ab - Aldeeb',
      html: (storeName) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff;">
          <h2 style="color: #f0ad4e;">⚠️ Ablaufhinweis</h2>
          <p style="font-size: 18px; color: #444;">Hallo <b>${storeName}</b>,</p>
          <p style="font-size: 16px; color: #555;">Ihr Shop-Abonnement läuft in <b style="color: #d9534f;">7 Tagen</b> ab.</p>
          <p style="font-size: 14px; color: #777;">Bitte verlängern Sie Ihr Abonnement, um eine unterbrechungsfreie Nutzung zu gewährleisten.</p>
          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 14px;">Ihr Aldeeb Team</p>
          </div>
        </div>
      `
    },
    tr: {
      subject: 'Uyarı: Mağaza aboneliğiniz 7 gün içinde sona eriyor - Aldeeb',
      html: (storeName) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff;">
          <h2 style="color: #f0ad4e;">⚠️ Abonelik Sona Erme Uyarısı</h2>
          <p style="font-size: 18px; color: #444;">Merhaba <b>${storeName}</b>,</p>
          <p style="font-size: 16px; color: #555;">Mağaza aboneliğiniz <b style="color: #d9534f;">7 gün</b> içinde sona erecek.</p>
          <p style="font-size: 14px; color: #777;">Kesintisiz hizmet için lütfen aboneliğinizi yenileyin.</p>
          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 14px;">Aldeeb Ekibi</p>
          </div>
        </div>
      `
    }
  },

  // 2. Aktivierung erfolgreich (nach Stripe-Zahlung)
  activationSuccess: {
    ar: {
      subject: (storeName) => `تهانينا! تم تفعيل متجر ${storeName} بنجاح`,
      html: (storeName, planName, endDate) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 تهانينا!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">تم تفعيل متجرك بنجاح</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">مرحباً <b>${storeName}</b>،</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">لقد تم تفعيل اشتراكك بنجاح في خطة: <br><span style="color: #28a745; font-weight: bold; font-size: 22px;">${planName}</span></p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">تاريخ انتهاء الاشتراك: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">يمكنك الآن البدء باستخدام كافة مميزات المنصة وزيادة مبيعاتك.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">شكراً لثقتكم بنا</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">فريق الديب  - Aldeeb</p>
          </div>
        </div>
      `
    },
    en: {
      subject: (storeName) => `Congratulations! ${storeName} has been successfully activated`,
      html: (storeName, planName, endDate) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 Congratulations!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">Your store has been successfully activated</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">Hello <b>${storeName}</b>,</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">Your subscription has been activated for: <br><span style="color: #28a745; font-weight: bold; font-size: 22px;">${planName}</span></p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">Subscription expires: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">You can now start using all platform features to grow your sales.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">Thank you for your trust</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">Aldeeb Team</p>
          </div>
        </div>
      `
    },
    de: {
      subject: (storeName) => `Herzlichen Glückwunsch! ${storeName} wurde erfolgreich aktiviert`,
      html: (storeName, planName, endDate) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 Herzlichen Glückwunsch!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">Ihr Shop wurde erfolgreich aktiviert</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">Hallo <b>${storeName}</b>,</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">Ihr Abonnement wurde aktiviert für: <br><span style="color: #28a745; font-weight: bold; font-size: 22px;">${planName}</span></p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">Abonnement endet am: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">Sie können jetzt alle Plattform-Funktionen nutzen, um Ihren Umsatz zu steigern.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">Vielen Dank für Ihr Vertrauen</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">Ihr Aldeeb Team</p>
          </div>
        </div>
      `
    },
    tr: {
      subject: (storeName) => `Tebrikler! ${storeName} başarıyla etkinleştirildi`,
      html: (storeName, planName, endDate) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 Tebrikler!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">Mağazanız başarıyla etkinleştirildi</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">Merhaba <b>${storeName}</b>,</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">Aboneliğiniz etkinleştirildi: <br><span style="color: #28a745; font-weight: bold; font-size: 22px;">${planName}</span></p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">Abonelik bitiş tarihi: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">Artık tüm platform özelliklerini kullanarak satışlarınızı artırabilirsiniz.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">Güveniniz için teşekkürler</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">Aldeeb Ekibi</p>
          </div>
        </div>
      `
    }
  },

  // 3. Manuelle Aktivierung (durch Admin)
  manualActivation: {
    ar: {
      subject: (storeName) => `تهانينا! تم تفعيل متجر ${storeName} بنجاح`,
      html: (storeName, endDate) => `
        <div dir="rtl" style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 تهانينا!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">تم تفعيل متجرك بنجاح</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">مرحباً <b>${storeName}</b>،</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">تم تأكيد دفعتك وتفعيل اشتراكك بنجاح.</p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">تاريخ انتهاء الاشتراك: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">يمكنك الآن الاستمتاع بجميع مميزات المنصة.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">شكراً لثقتكم بنا</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">فريق الديب  - Aldeeb</p>
          </div>
        </div>
      `
    },
    en: {
      subject: (storeName) => `Congratulations! ${storeName} has been successfully activated`,
      html: (storeName, endDate) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 Congratulations!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">Your store has been successfully activated</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">Hello <b>${storeName}</b>,</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">Your payment has been confirmed and your subscription is now active.</p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">Subscription expires: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">You can now enjoy all platform features.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">Thank you for your trust</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">Aldeeb Team</p>
          </div>
        </div>
      `
    },
    de: {
      subject: (storeName) => `Herzlichen Glückwunsch! ${storeName} wurde erfolgreich aktiviert`,
      html: (storeName, endDate) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 Herzlichen Glückwunsch!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">Ihr Shop wurde erfolgreich aktiviert</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">Hallo <b>${storeName}</b>,</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">Ihre Zahlung wurde bestätigt und Ihr Abonnement ist jetzt aktiv.</p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">Abonnement endet am: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">Sie können jetzt alle Plattform-Funktionen nutzen.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">Vielen Dank für Ihr Vertrauen</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">Ihr Aldeeb Team</p>
          </div>
        </div>
      `
    },
    tr: {
      subject: (storeName) => `Tebrikler! ${storeName} başarıyla etkinleştirildi`,
      html: (storeName, endDate) => `
        <div style="font-family: Arial, sans-serif; text-align: center; border: 1px solid #eeeeee; padding: 30px; border-radius: 20px; max-width: 550px; margin: auto; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
          <h1 style="color: #28a745; font-size: 50px; margin-bottom: 10px; font-weight: bold;">🎉 Tebrikler!</h1>
          <h2 style="color: #333333; margin-top: 0; font-size: 24px;">Mağazanız başarıyla etkinleştirildi</h2>
          <div style="background-color: #f1fcf4; padding: 20px; border-radius: 15px; margin: 25px 0; border: 1px dashed #28a745;">
            <p style="font-size: 20px; color: #444444; margin: 10px 0;">Merhaba <b>${storeName}</b>,</p>
            <p style="font-size: 18px; color: #555555; margin: 10px 0;">Ödemeniz onaylandı ve aboneliğiniz etkinleştirildi.</p>
            <p style="font-size: 16px; color: #666666; margin: 10px 0;">Abonelik bitiş tarihi: <b>${endDate}</b></p>
          </div>
          <p style="font-size: 16px; color: #555555;">Artık tüm platform özelliklerinin keyfini çıkarabilirsiniz.</p>
          <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eeeeee;">
            <p style="color: #999999; font-size: 14px; margin: 0;">Güveniniz için teşekkürler</p>
            <p style="color: #333333; font-size: 16px; font-weight: bold; margin: 5px 0;">Aldeeb Ekibi</p>
          </div>
        </div>
      `
    }
  }
};

// =============================================================================
// HELPER FUNCTIONS (Unverändert)
// =============================================================================

/**
 * Verbesserte arabische Slug-Generierung
 * - Token-basiert (Wörter sauber trennen)
 * - Dictionary nur auf ganze Wörter
 * - Artikel "ال" nur am Wortanfang als Prefix
 * - Diakritika + Tatweel komplett entfernen
 * - Unicode normalisieren
 * - Konsistente Transliteration
 * - MaxLen & sauberes Kürzen
 */
const ALLOWED_EVENTS = new Set([
  "page_view",
  "product_view",
  "add_to_cart",
  "checkout_intent",
  "whatsapp_click",
]);

function dayKeyUTC(d = new Date()) {
  return d.toISOString().slice(0, 10); // YYYY-MM-DD (UTC)
}

// ✅ TTL: 366 Tage ab Tagesbeginn (UTC)
const ONE_YEAR_MS = 366 * 24 * 60 * 60 * 1000;

exports.trackEventBySlug = onRequest(
  {
    region: REGION_PRIMARY,
    cors: true,
    secrets: [trackingSecret],
    maxInstances: 20,
  },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Cache-Control", "no-store");

    if (req.method === "OPTIONS") return res.status(204).send("");
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");

    // ✅ optional: Secret-Header Check (empfohlen)
    const required = trackingSecret.value();
    if (required) {
      const provided = String(req.get("x-aldeeb-track") || "");
      if (provided !== required) {
        return res.status(401).json({ success: false, error: "unauthorized" });
      }
    }

    const body = req.body || {};
    const slug = String(body.slug || "").trim();
    const event = String(body.event || "").trim();
    const productId = body.productId ? String(body.productId) : null;

    if (!slug || !ALLOWED_EVENTS.has(event)) {
      return res.status(400).json({ success: false, error: "bad_request" });
    }

    try {
      // 1) slug → storeId
      const slugDoc = await db.collection("slugs").doc(slug).get();
      if (!slugDoc.exists) {
        return res.status(404).json({ success: false, error: "slug_not_found" });
      }

      const storeId = slugDoc.data().store_id;

      // 2) Tagesdoc
      const day = dayKeyUTC();
      const ref = db
        .collection("stores_private")
        .doc(storeId)
        .collection("analytics_daily")
        .doc(day);

      // 3) increment + TTL (✅ ersetzt)
      // day ist "YYYY-MM-DD"
      const dayStart = new Date(`${day}T00:00:00.000Z`);
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(dayStart.getTime() + ONE_YEAR_MS)
      );

      const inc = admin.firestore.FieldValue.increment(1);
      const updates = {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt, // ✅ TTL Feld (in Firestore TTL aktivieren)
        [event]: inc,
      };

      // optional: wenn du später pro Produkt tracken willst (Achtung Doc-Size!)
      // if (productId && (event === "product_view" || event === "add_to_cart")) {
      //   updates[`products.${productId}.${event}`] = inc;
      // }

      await ref.set(updates, { merge: true });

      return res.status(200).json({ success: true });
    } catch (e) {
      console.error("trackEventBySlug error:", e);
      return res.status(500).json({ success: false, error: "internal_error" });
    }
  }
);

function generateArabicSlug(name, maxLen = 60) {
  if (!name) return null;

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. UNICODE NORMALISIEREN & DIAKRITIKA ENTFERNEN
  // ═══════════════════════════════════════════════════════════════════════════
  let normalized = name.normalize('NFKD');

  // Alle arabischen Diakritika entfernen (Harakat, Tanwin, Sukun, Shadda, Tatweel, etc.)
  // Range: U+064B - U+0652 (Fatha, Damma, Kasra, Tanwin, Sukun, Shadda)
  // Plus: U+0640 (Tatweel), U+0670 (Superscript Alef), andere Quranic marks
  normalized = normalized.replace(/[\u064B-\u065F\u0640\u0670\u06D6-\u06ED]/g, '');

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. HAMZA/ALEF VARIANTEN NORMALISIEREN
  // ═══════════════════════════════════════════════════════════════════════════
  // أ إ آ ٱ → ا
  normalized = normalized.replace(/[أإآٱ]/g, 'ا');

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. TOKENISIEREN (Wörter trennen)
  // ═══════════════════════════════════════════════════════════════════════════
  // Alle nicht-alphanumerischen Zeichen (inkl. arabisch) als Trenner
  const tokens = normalized.split(/[\s\-_.,;:!?'"()\[\]{}\/\\]+/).filter(t => t.length > 0);

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. DICTIONARY (nur ganze Wörter, mit Artikel-Varianten)
  // ═══════════════════════════════════════════════════════════════════════════
  const dictionary = {
    // Orte (mit und ohne Artikel)
    'الرياض': 'riyadh', 'رياض': 'riyadh',
    'جدة': 'jeddah', 'الجدة': 'jeddah',
    'مكة': 'makkah', 'المكة': 'makkah',
    'دبي': 'dubai', 'الدبي': 'dubai',
    'دمشق': 'damascus', 'الدمشق': 'damascus',
    'حلب': 'aleppo', 'الحلب': 'aleppo',
    'بغداد': 'baghdad', 'البغداد': 'baghdad',
    'القاهرة': 'cairo', 'قاهرة': 'cairo',
    // Geschäftstypen
    'متجر': 'store', 'المتجر': 'store',
    'محل': 'shop', 'المحل': 'shop',
    'سوق': 'souq', 'السوق': 'souq',
    'مركز': 'center', 'المركز': 'center',
    'بيت': 'bait', 'البيت': 'bait',
    // Namen
    'محمد': 'muhammad', 'احمد': 'ahmad', 'علي': 'ali',
    'عمر': 'omar', 'خالد': 'khaled', 'سعيد': 'saeed',
    'يوسف': 'yusuf', 'نور': 'noor', 'فاطمة': 'fatima',
    'عبدالله': 'abdullah', 'عبدالرحمن': 'abdulrahman',
    // Präpositionen/Verbinder (als eigene Wörter)
    'بن': 'bin', 'ابن': 'ibn', 'بو': 'bu', 'ابو': 'abu', 'ام': 'um',
  };

  // Stopwords: Diese Wörter werden entfernt wenn sie alleine stehen
  const stopwords = new Set(['و', 'في', 'من', 'الى', 'على', 'عن', 'مع', 'هذا', 'هذه', 'ذلك', 'تلك']);

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. TRANSLITERATIONS-MAP (konsistent)
  // ═══════════════════════════════════════════════════════════════════════════
  const charMap = {
    // Alef-Varianten (bereits normalisiert, aber als Fallback)
    'ا': 'a', 'أ': 'a', 'إ': 'a', 'آ': 'a', 'ٱ': 'a',
    'ى': 'a',  // Alef Maksura
    'ئ': 'y', 'ؤ': 'w',  // Hamza auf Träger
    // Konsonanten
    'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j', 'ح': 'h', 'خ': 'kh',
    'د': 'd', 'ذ': 'dh', 'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh',
    'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z',
    'ع': '',   // Ayn: oft stumm in Transliteration
    'غ': 'gh',
    'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l',
    'م': 'm', 'ن': 'n', 'ه': 'h',
    'و': 'w',  // Waw
    'ي': 'y',  // Ya (y ist üblicher als i)
    'ة': 'a',  // Ta Marbuta: am Wortende meist 'a' (z.B. مكة → makkah ist Ausnahme im Dict)
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. TOKENS VERARBEITEN
  // ═══════════════════════════════════════════════════════════════════════════
  const processedTokens = tokens.map(token => {
    // 6a. Stopwords überspringen
    if (stopwords.has(token)) {
      return null;
    }

    // 6b. Dictionary-Lookup (exakte Übereinstimmung)
    if (dictionary[token]) {
      return dictionary[token];
    }

    // 6c. Artikel "ال" am Wortanfang behandeln
    let hasArticle = false;
    let core = token;
    if (token.startsWith('ال') && token.length > 2) {
      hasArticle = true;
      core = token.substring(2);
      // Nochmal Dictionary-Check ohne Artikel
      if (dictionary[core]) {
        return hasArticle ? 'al-' + dictionary[core] : dictionary[core];
      }
    }

    // 6d. Zeichenweise Transliteration
    let transliterated = '';
    for (const char of core) {
      if (charMap[char] !== undefined) {
        transliterated += charMap[char];
      } else if (/[a-z0-9]/i.test(char)) {
        // Lateinische Buchstaben/Zahlen behalten
        transliterated += char.toLowerCase();
      }
      // Alle anderen Zeichen werden ignoriert
    }

    // 6e. Artikel-Prefix hinzufügen wenn vorhanden
    if (hasArticle && transliterated.length > 0) {
      transliterated = 'al-' + transliterated;
    }

    return transliterated.length > 0 ? transliterated : null;
  }).filter(t => t !== null);

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. ZUSAMMENFÜGEN & CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════
  let slug = processedTokens.join('-');

  // Cleanup
  slug = slug.toLowerCase()
    .replace(/[^a-z0-9-]/g, '')  // Nur a-z, 0-9, - erlauben
    .replace(/-+/g, '-')          // Mehrfache Bindestriche zusammenfassen
    .replace(/^-|-$/g, '');       // Bindestriche am Anfang/Ende entfernen

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. LÄNGENBESCHRÄNKUNG (sauber am letzten Bindestrich kürzen)
  // ═══════════════════════════════════════════════════════════════════════════
  if (slug.length > maxLen) {
    slug = slug.substring(0, maxLen);
    // Am letzten vollständigen Wort abschneiden
    const lastDash = slug.lastIndexOf('-');
    if (lastDash > maxLen * 0.5) {  // Nur wenn mindestens 50% erhalten bleibt
      slug = slug.substring(0, lastDash);
    }
    slug = slug.replace(/-$/, '');  // Trailing dash entfernen
  }

  return slug || null;
}

const SUPPORTED_LANGS = ['ar', 'en', 'de', 'tr'];

function normalizeLang(lang) {
  return (lang && SUPPORTED_LANGS.includes(lang)) ? lang : 'ar';
}

/**
 * admin_app_lang + store_name liegen bei dir in stores_public.
 * Diese Helper holt Public-Daten einmalig (Cache) und liefert Language + StoreName.
 */
async function resolveStoreLocale(storeId, privateData, cache) {
  const c = cache || new Map();
  let publicData = c.get(storeId);

  if (publicData === undefined) {
    const publicDoc = await db.collection("stores_public").doc(storeId).get();
    publicData = publicDoc.exists ? publicDoc.data() : null;
    c.set(storeId, publicData);
  }

  const lang = normalizeLang(publicData?.admin_app_lang || privateData?.admin_app_lang);
  const storeName =
    publicData?.store_name ||
    publicData?.name ||
    privateData?.store_name ||
    privateData?.storeName ||
    "Store";

  return { lang, storeName, publicData, cache: c };
}


function getLocalizedPlanName(planId, lang) {
  const plans = EMAIL_TEMPLATES.planNames[lang] || EMAIL_TEMPLATES.planNames['ar'];
  if (planId === 'premium_biannual') return plans.biannual;
  if (planId === 'premium_monthly') return plans.monthly;
  return plans.yearly;
}

function formatDateForLang(date, lang) {
  const localeMap = {
    'ar': 'ar-EG',
    'en': 'en-US',
    'de': 'de-DE',
    'tr': 'tr-TR'
  };
  return date.toLocaleDateString(localeMap[lang] || 'ar-EG', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}

// =============================================================================
// MAIN FUNCTIONS
// =============================================================================

/*********
 * RESOLVE USER REGION V2 (API Address Country)
 * Replaces: functions.region().https.onCall
 **********/
exports.resolveUserRegion = onCall({ region: REGION_PRIMARY }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be logged in.");
  }

  const uid = request.auth.uid;

  // ✅ Kostenlos & ohne externen Dienst: Google setzt oft x-appengine-country (2-letter ISO) im Request.
  // Falls nicht vorhanden, nutzen wir (wie bisher) IP Lookup als Fallback.
  const headerCountry = request.rawRequest?.headers?.["x-appengine-country"];
  let ipCountry = (headerCountry && headerCountry !== "ZZ") ? headerCountry : "GLOBAL";

  // IP ermitteln (v2 nutzt request.rawRequest)
  let clientIp = request.rawRequest?.headers?.["x-forwarded-for"]
    ? String(request.rawRequest.headers["x-forwarded-for"]).split(",")[0].trim()
    : request.rawRequest?.connection?.remoteAddress;

  // Fallback: kostenloser HTTPS-Dienst (kein API Key). Läuft nur, wenn headerCountry fehlt.
  if (ipCountry === "GLOBAL" && clientIp) {
    try {
      const response = await axios.get(`https://ipwho.is/${encodeURIComponent(clientIp)}?fields=success,country_code`);
      if (response.data && response.data.success && response.data.country_code) {
        ipCountry = response.data.country_code;
      }
    } catch (error) {
      console.error("GeoIP Lookup failed", error);
    }
  }

  await db.collection("stores_public").doc(uid).set({
    api_address_country: ipCountry,
    last_ip_check: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });

  console.log(`📍 Region detected for ${uid}: ${ipCountry} (Saved to api_address_country)`);

  return { success: true, country: ipCountry };
});


/**
 * LOGIC for Cron Job (Separated for clarity)
 */
/**
 * LOGIC for Cron Job (Separated for clarity)
 * FIX: Nutzt jetzt stores_private für Status-Checks
 */
async function updateTrialAndExpiredStores() {
  const now = new Date();
  const nowIso = now.toISOString();

  const sevenDaysFromNow = new Date();
  sevenDaysFromNow.setDate(now.getDate() + 7);
  const sevenDaysIso = sevenDaysFromNow.toISOString().split('T')[0];

  let batch = db.batch();
  let operationCount = 0;
  const BATCH_LIMIT = 400;

  const publicCache = new Map();


  // --- 1. TRIAL STORES (in stores_private) ---
  const trialStores = await db.collection("stores_private").where("access.status", "==", "trial").get();
  for (const doc of trialStores.docs) {
    const store = doc.data();
    const trialEnd = store.access?.trial_end_at;

    if (!trialEnd) continue;
    const daysLeft = Math.ceil((new Date(trialEnd) - now) / (1000 * 60 * 60 * 24));

    // Status Updates passieren nur in Private
    if (daysLeft <= 0) {
      batch.update(doc.ref, {
        "access.status": "expired",
        "access.stage": 1,
        "access.daysRemaining": 0,
        "access.expired_at": nowIso
      });
    } else {
      batch.update(doc.ref, { "access.daysRemaining": daysLeft });
    }

    operationCount++;
    if (operationCount >= BATCH_LIMIT) {
      await batch.commit();
      batch = db.batch();
      operationCount = 0;
    }
  }

  // --- 2. ACTIVE STORES (in stores_private) ---
  const activeStores = await db.collection("stores_private").where("access.status", "==", "active").get();
  for (const doc of activeStores.docs) {
    const store = doc.data();
    const subEnd = store.access?.subscription_end_at;

    if (!subEnd) continue;
    const endDate = new Date(subEnd);
    const daysLeft = Math.ceil((endDate - now) / (1000 * 60 * 60 * 24));

    if (daysLeft <= 0) {
      batch.update(doc.ref, {
        "access.status": "expired",
        "access.stage": 1,
        "access.expired_at": nowIso,
        "access.daysRemaining": 0
      });
    } else {
      batch.update(doc.ref, { "access.daysRemaining": daysLeft });

      // Email Alarm: E-Mail kommt aus Private, Sprache/Name aus Public
      if (daysLeft === 7) {
        const toEmail = store.email_login || store.owner_email;
        if (toEmail) {
          const { lang, storeName } = await resolveStoreLocale(doc.id, store, publicCache);
          const template = EMAIL_TEMPLATES.trialWarning[lang];

          const mailRef = db.collection("mail").doc();
          batch.set(mailRef, {
            to: toEmail,
            message: {
              subject: template.subject,
              html: template.html(storeName),
            }
          });

          // ✅ WICHTIG: batch.set zählt auch als Write!
          operationCount++;
          if (operationCount >= BATCH_LIMIT) {
            await batch.commit();
            batch = db.batch();
            operationCount = 0;
          }
        }
      }

    }

    operationCount++;
    if (operationCount >= BATCH_LIMIT) {
      await batch.commit();
      batch = db.batch();
      operationCount = 0;
    }
  }

  // --- 3. EXPIRED STORES PROGRESSION (in stores_private) ---
  const expiredStores = await db.collection("stores_private").where("access.status", "==", "expired").get();
  for (const doc of expiredStores.docs) {
    const store = doc.data();
    const expiredAt = store.access?.expired_at;
    const currentStage = store.access?.stage || 1;

    if (!expiredAt || currentStage >= 3) continue;
    const daysSinceExpired = Math.floor((now - new Date(expiredAt)) / (1000 * 60 * 60 * 24));
    let newStage = currentStage;
    if (daysSinceExpired >= GRACE_PERIODS[1]) {
      newStage = 3;
    } else if (daysSinceExpired >= GRACE_PERIODS[0] && currentStage < 2) {
      newStage = 2;
    }

    if (newStage !== currentStage) {
      batch.update(doc.ref, { "access.stage": newStage });
      operationCount++;
      if (operationCount >= BATCH_LIMIT) {
        await batch.commit();
        batch = db.batch();
        operationCount = 0;
      }
    }
  }

  if (operationCount > 0) await batch.commit();
}

/**
 * CRON JOB (v2 Schedule)
 * Replaces: functions.pubsub.schedule
 */
exports.checkTrialExpiration = onSchedule(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Cron-Job braucht nur 1 Instanz
    schedule: "0 3 * * *",
    timeZone: "UTC"
  },
  updateTrialAndExpiredStores
);

/**
 * Trigger: New Store Created (v2 Firestore)
 * GEÄNDERT: Erstellt KEINEN Slug mehr - Store bleibt als "draft"
 * Slug wird erst bei finalizeStoreSetup erstellt
 */
exports.onStoreCreated = onDocumentCreated(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Firestore-Trigger - nur bei Registrierungen
    document: "stores_private/{storeId}"
  },
  async (event) => {
    const privateData = event.data.data();
    const id = event.params.storeId;
    const batch = db.batch();

    const publicStoreRef = db.collection("stores_public").doc(id);

    // Zeitberechnung
    const now = new Date();
    const trialEndDate = new Date(now.getTime() + (14 * 24 * 60 * 60 * 1000));

    // Store Name
    const storeName = privateData.store_name || "Store";

    try {
      // UPDATE PRIVATE - status = "draft" (kein Slug)
      batch.update(event.data.ref, {
        "status": "draft",
        "access.status": "trial",
        "access.stage": 0,
        "access.trial_start_at": now.toISOString(),
        "access.trial_end_at": trialEndDate.toISOString(),
        "access.daysRemaining": 14,
      });

      // UPDATE PUBLIC - status = "draft" (nicht öffentlich sichtbar)
      const initialPublicAccess = {
        status: 'trial',
        stage: 0,
        daysRemaining: 14,
        trial_start_at: now.toISOString(),
        trial_end_at: trialEndDate.toISOString()
      };

      batch.set(publicStoreRef, {
        store_name: storeName,
        status: 'draft',
        has_products: false,
        access: initialPublicAccess,
        created_at: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

      await batch.commit();
      console.log(`✅ Store ${id} als DRAFT initialisiert`);

    } catch (error) {
      console.error("❌ Fehler bei der Initialisierung des Stores:", error);
    }
  }
);

/**
 * Trigger: Store Activated (v2 Firestore)
 * Replaces: functions.firestore.document().onUpdate
 */
/**
 * Trigger: Store Activated (v2 Firestore)
 * FIX: Lauscht auf stores_private
 */
exports.onStoreActivated = onDocumentUpdated(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Firestore-Trigger - Aktivierungen
    document: "stores_private/{storeId}"
  },
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.access?.status !== "active" && after.access?.status === "active") {
      if (after.access?.subscription_end_at) {
          console.log("Date already set by Webhook or Admin, skipping trigger logic.");
          return;
      }

      const subEnd = new Date();
      subEnd.setFullYear(subEnd.getFullYear() + 1);

      await event.data.after.ref.update({
        "access.stage": 0,
        "access.activated_at": new Date().toISOString(),
        "access.subscription_end_at": subEnd.toISOString(),
        "access.expired_at": admin.firestore.FieldValue.delete()
      });
    }
  }
);

/**
 * API: Create Stripe Checkout Session (v2 Callable)
 * Replaces: functions.https.onCall (v1) / mixed v2
 */
exports.createStripeCheckoutSession = onCall(
  {
    region: REGION_PRIMARY,
    secrets: [stripeSecret]
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }

    const uid = request.auth.uid;
    const stripe = require("stripe")(stripeSecret.value());

    // Daten aus der App (In v2: request.data)
    const { planId, amount, currency, platform, lang } = request.data;

    // SCHRITT A: DATEN LADEN
    const publicDoc = await db.collection("stores_public").doc(uid).get();
    const publicData = publicDoc.exists ? publicDoc.data() : {};

    // SCHRITT B: LAND BESTIMMEN
    let effectiveCountry = 'GLOBAL';
    if (publicData.api_address_country && publicData.api_address_country !== 'GLOBAL') {
      effectiveCountry = publicData.api_address_country.toUpperCase();
    } else {
      const privateDoc = await db.collection("stores_private").doc(uid).get();
      if (privateDoc.exists) {
         const privateData = privateDoc.data();
         if (privateData.address_country) {
           effectiveCountry = privateData.address_country.toUpperCase();
         }
      }
    }

    if (effectiveCountry === 'SY') {
      console.warn(`⚠️ Payment blocked for store ${uid}. Detected region: SY`);
      throw new HttpsError(
        "failed-precondition",
        "Online payments are not available in your region. Please contact support."
      );
    }

    // SCHRITT C: SPRACHE
    let selectedLang = 'ar';
    if (lang) {
      selectedLang = lang;
    }
    else if (publicData.admin_app_lang) {
      selectedLang = publicData.admin_app_lang;
    }

    // SCHRITT D: PRODUKTNAMEN
    const productNames = {
      ar: {
        premium_yearly: "تفعيل المتجر لمدة سنة كاملة",
        premium_biannual: "تفعيل المتجر لمدة 6 أشهر",
        default: "تفعيل المتجر"
      },
      de: {
        premium_yearly: "Shop-Aktivierung (1 Jahr)",
        premium_biannual: "Shop-Aktivierung (6 Monate)",
        default: "Shop-Aktivierung"
      },
      en: {
        premium_yearly: "Store Activation (1 Year)",
        premium_biannual: "Store Activation (6 Months)",
        default: "Store Activation"
      },
      tr: {
        premium_yearly: "Mağaza Aktivasyonu (1 Yıl)",
        premium_biannual: "Mağaza Aktivasyonu (6 Ay)",
        default: "Mağaza Aktivasyonu"
      }
    };
    const langDict = productNames[selectedLang] || productNames['ar'];
    const productName = langDict[planId] || langDict['default'];

    // SCHRITT E: STRIPE SESSION
        let returnBaseUrl;

        // Prüfen, ob die Zahlung vom Webbrowser oder von der Handy-App kommt
        if (platform === 'web') {
          returnBaseUrl = "https://admin.aldeebtech.de/payment";
        } else {
          // Das ist der magische Deep-Link, der deine App wieder öffnet!
          returnBaseUrl = "aldeebtech://payment";
        }

    try {
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        line_items: [{
          price_data: {
            currency: (currency || 'eur').toLowerCase(),
            product_data: { name: productName },
            unit_amount: Math.round(parseFloat(amount))
          },
          quantity: 1
        }],
        mode: "payment",
        success_url: `${returnBaseUrl}?success=true&session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${returnBaseUrl}?success=false`,
        client_reference_id: uid,
        metadata: {
          storeId: uid,
          planId: planId,
          platform: platform || 'unknown',
          lang: selectedLang
        },
        locale: ['de','en','tr'].includes((selectedLang || '').toLowerCase()) ? selectedLang.toLowerCase() : 'auto'
      });
      return { url: session.url };
    } catch (err) {
      console.error("Stripe Checkout Error:", err);
      throw new HttpsError("internal", err.message);
    }
  }
);

/**
 * API: Stripe Webhook (v2 Request)
 * Replaces: functions.https.onRequest (v1)
 */
/**
 * API: Stripe Webhook (v2 Request)
 * Replaces: functions.https.onRequest (v1)
 */
/**
 * API: Stripe Webhook (v2 Request)
 * FIX: Schreibt in stores_private
 */
exports.stripeWebhook = onRequest(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // 15 High traffic - Payment webhooks kritisch
    secrets: [stripeWebhookSecret, stripeSecret]
  },
  async (req, res) => {
    const sig = req.headers["stripe-signature"];
    const endpointSecret = stripeWebhookSecret.value();

    // ✅ Stripe korrekt initialisieren (Secret Key aus Secret Manager)
    const stripe = require("stripe")(stripeSecret.value());

    let event;
    try {
      event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
    } catch (err) {
      console.error(`Webhook Signature Error: ${err.message}`);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    const publicCache = new Map();

    if (event.type === "checkout.session.completed") {
      const session = event.data.object;
      const sessionId = session.id;
      const storeId = session.client_reference_id;
      const planId = session.metadata?.planId;

      if (storeId) {
        try {
          const paymentMarkerRef = db.collection("processed_payments").doc(sessionId);
          const alreadyProcessed = await paymentMarkerRef.get();

          if (alreadyProcessed.exists) {
            return res.json({ received: true, status: "already_processed" });
          }

          const now = new Date();
          let endDate = new Date();

          if (planId === 'premium_biannual') endDate.setMonth(endDate.getMonth() + 6);
          else if (planId === 'premium_monthly') endDate.setMonth(endDate.getMonth() + 1);
          else endDate.setFullYear(endDate.getFullYear() + 1);

          // FIX: Hauptziel ist stores_private
          const storeRef = db.collection("stores_private").doc(storeId);
          const storeDoc = await storeRef.get();

          // Daten laden (Hybrid: Private bevorzugt, Public als Fallback für Name/Sprache)
          let storeData = storeDoc.exists ? storeDoc.data() : null;
          if (!storeData || !storeData.store_name) {
             const publicDoc = await db.collection("stores_public").doc(storeId).get();
             if (publicDoc.exists) {
                 storeData = { ...storeData, ...publicDoc.data() };
             }
          }

          await paymentMarkerRef.set({
            processed_at: admin.firestore.FieldValue.serverTimestamp(),
            storeId: storeId,
            planId: planId || 'yearly',
            amount: session.amount_total
          });

          await storeRef.update({
              "access.status": "active",
              "access.stage": 0,
              "access.plan": planId || 'premium_yearly',
              "access.activated_at": now.toISOString(),
              "access.subscription_end_at": endDate.toISOString(),
              "access.expired_at": admin.firestore.FieldValue.delete(),
              "access.daysRemaining": Math.ceil((endDate - now) / (1000 * 60 * 60 * 24))
          });

          const toEmail = storeData?.email_login || storeData?.owner_email || session.customer_details?.email;
          const { lang, storeName } = await resolveStoreLocale(storeId, storeData, publicCache);
          const localizedPlanName = getLocalizedPlanName(planId, lang);
          const formattedEndDate = formatDateForLang(endDate, lang);
          const template = EMAIL_TEMPLATES.activationSuccess[lang];

          if (toEmail) {
              await db.collection("mail").add({
                  to: toEmail,
                  message: {
                      subject: template.subject(storeName),
                      html: template.html(storeName, localizedPlanName, formattedEndDate),
                  }
              });
          }
          console.log(`✅ Erfolgreich verarbeitet: ${sessionId} für Store: ${storeId}`);
        } catch (dbError) {
            console.error(`Database error during webhook:`, dbError);
        }
      }
    }

    res.json({ received: true });
  }
);

/**
 * PUBLIC API: Get Store Info (v2 Request)
 */
/**
 * PUBLIC API: Get Store Info (v2 Request)
 */
/**
 * PUBLIC API: Get Store Info (v2 Request)
 * FIX: Liest aus stores_public + Syntax Fix
 */
exports.getStoreBySlug = onRequest(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, //10 Public API - Kundentraffic
    cors: true
  },
  async (req, res) => {
    const slug = req.query.slug;
    if (!slug) return res.status(400).send("Slug required");

    try {
      const slugDoc = await db.collection("slugs").doc(slug).get();
      if (!slugDoc.exists) return res.status(404).send("Not found");

      const storeId = slugDoc.data().store_id;

      // WICHTIG: Nur stores_public lesen!
      const storeDoc = await db.collection("stores_public").doc(storeId).get();
      if (!storeDoc.exists) return res.status(404).send("Store data missing");

      res.json({
        success: true,
        store: { id: storeId, ...storeDoc.data() }
      });
    } catch (error) {
      console.error(error);
      res.status(500).send(error.message);
    }
  }
);

exports.getAllSlugs = onRequest(
  { region: "europe-west3", cors: true },
  async (req, res) => {
    try {
      const limit = Math.min(parseInt(req.query.limit || "5000", 10), 20000);
      const cursor = req.query.cursor ? String(req.query.cursor) : null;

      let q = db
        .collection("slugs")
        .orderBy(admin.firestore.FieldPath.documentId())
        .limit(limit);

      if (cursor) q = q.startAfter(cursor);

      const snap = await q.get();

      const slugs = snap.docs.map((d) => ({
        slug: d.id,
        updatedAt: d.get("updatedAt")?.toDate?.()?.toISOString?.() || null,
      }));

      const nextCursor = snap.size === limit ? snap.docs[snap.docs.length - 1].id : null;

      res.set("Cache-Control", "public, max-age=60");
      return res.status(200).json({ success: true, slugs, nextCursor });
    } catch (e) {
      console.error(e);
      return res.status(500).json({ success: false, error: "internal_error" });
    }
  }
);

/**
 * PUBLIC API: Get Products (v2 Request)
 * FIX: Liest aus stores_public/products
 */
exports.getProductsBySlug = onRequest(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // 10 Public API - Kundentraffic
    cors: true
  },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    const slug = req.query.slug;
    if (!slug) return res.json({ success: false });

    try {
      const slugDoc = await db.collection("slugs").doc(slug).get();
      if (!slugDoc.exists) return res.json({ success: false });

      const storeId = slugDoc.data().store_id;

      // Produkte liegen unter stores_public
      const snap = await db.collection("stores_public").doc(storeId)
          .collection("products").where("product_active", "==", true).get();

      const products = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      res.json({ success: true, products });
    } catch (e) {
      res.json({ success: false, error: e.message });
    }
  }
);

// =============================================================================
// SERVER-SIDE ONLY FUNCTIONS
// =============================================================================

/**
 * SECURE: Confirm Email Verification (v2 Callable)
 */
/**
 * SECURE: Confirm Email Verification (v2 Callable)
 * FIX: Update stores_private
 */
exports.confirmEmailVerification = onCall(
  { region: REGION_PRIMARY },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
    const uid = request.auth.uid;

    try {
      const userRecord = await admin.auth().getUser(uid);
      if (!userRecord.emailVerified) {
        throw new HttpsError("failed-precondition", "Email not verified yet.");
      }

      // Ziel: stores_private
      const storeRef = db.collection("stores_private").doc(uid);

      await storeRef.update({
        is_verified: true,
        verified_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`✅ Store ${uid} marked as verified.`);
      return { success: true, message: "Store verified successfully." };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      console.error("confirmEmailVerification Error:", error);
      throw new HttpsError("internal", error.message);
    }
  }
);

/**
 * SECURE: Manual Payment Verification (v2 Callable)
 * FIX: Update stores_private
 */
/**
 * SECURE: Manual Payment Verification (v2 Callable)
 * FIX: Update stores_private & Security Logic Restored
 */
exports.verifyStorePayment = onCall(
  { region: REGION_PRIMARY },
  async (request) => {
    // 1. Auth Check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }

    // 2. ADMIN CHECK (WICHTIG: War durch Platzhalter ersetzt!)
    const callerUid = request.auth.uid;
    const adminEmails = [
        'nsem338@gmail.com',
        'aminamuhammed655@gmail.com',
        'kadour.abdull@gmail.com'
    ];
    let isAdmin = false;

    if (request.auth.token.admin === true) {
      isAdmin = true;
    }

    const callerEmail = request.auth.token.email;
    if (adminEmails.includes(callerEmail)) {
      isAdmin = true;
    }

    if (!isAdmin) {
      console.warn(`⚠️ Unauthorized payment verification attempt by ${callerEmail} (${callerUid})`);
      throw new HttpsError(
        "permission-denied",
        "Only admins can verify payments."
      );
    }

    // 3. Parameter & Logik
    const { storeId, planId, customEndDate } = request.data;
    if (!storeId) {
      throw new HttpsError("invalid-argument", "storeId is required.");
    }

    try {
      const storeRef = db.collection("stores_private").doc(storeId);
      const storeDoc = await storeRef.get();
      if (!storeDoc.exists) throw new HttpsError("not-found", "Store not found.");

      const now = new Date();
      let endDate = new Date();
      let planName = "premium_yearly";

      if (customEndDate) {
        endDate = new Date(customEndDate);
        planName = planId || "custom";
      } else if (planId === 'premium_biannual') {
        endDate.setMonth(endDate.getMonth() + 6);
        planName = "premium_biannual";
      } else if (planId === 'premium_monthly') {
        endDate.setMonth(endDate.getMonth() + 1);
        planName = "premium_monthly";
      } else {
        endDate.setFullYear(endDate.getFullYear() + 1);
      }

      // Update in Private
      await storeRef.update({
        "access.status": "active",
        "access.stage": 0,
        "access.plan": planName,
        "access.activated_at": now.toISOString(),
        "access.subscription_end_at": endDate.toISOString(),
        "access.expired_at": admin.firestore.FieldValue.delete(),
        "access.daysRemaining": Math.ceil((endDate - now) / (1000 * 60 * 60 * 24)),
        "access.verified_by": callerEmail,
        "access.verified_at": admin.firestore.FieldValue.serverTimestamp(),
      });

      // 4. E-Mail senden (Daten evtl. aus Public holen, falls in Private leer)
      // Wir versuchen es erst aus dem bereits geladenen Private Doc
      let storeData = storeDoc.data();
      if (!storeData.store_name) {
         const publicDoc = await db.collection("stores_public").doc(storeId).get();
         if (publicDoc.exists) storeData = { ...storeData, ...publicDoc.data() };
      }

      const toEmail = storeData.email_login || storeData.owner_email;
      const { lang, storeName } = await resolveStoreLocale(storeId, storeData, new Map());
      const formattedEndDate = formatDateForLang(endDate, lang);
      const template = EMAIL_TEMPLATES.manualActivation[lang];

      if (toEmail) {
        await db.collection("mail").add({
          to: toEmail,
          message: {
            subject: template.subject(storeName),
            html: template.html(storeName, formattedEndDate),
          }
        });
      }

      console.log(`✅ Store ${storeId} activated by admin ${callerEmail}`);
      return {
        success: true,
        message: "Payment verified and store activated.",
        endDate: endDate.toISOString()
      };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      console.error("verifyStorePayment Error:", error);
      throw new HttpsError("internal", error.message);
    }
  }
);

/**
 * SECURE: Cleanup Expired Unverified Accounts (v2 Schedule)
 */
/**
 * SECURE: Cleanup Expired Unverified Accounts (v2 Schedule)
 * FIX: Sucht in Private, löscht in Private UND Public
 */
exports.cleanupExpiredAccounts = onSchedule(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Cron-Job braucht nur 1 Instanz
    schedule: "0 4 * * *",
    timeZone: "UTC"
  },
  async (event) => {
    const now = new Date();
    const cutoffTime = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    let deletedCount = 0;

    try {
      // 1. Suche in Private
      const expiredStores = await db.collection("stores_private")
        .where("is_verified", "==", false)
        .get();

      for (const doc of expiredStores.docs) {
        const storeData = doc.data();
        const createdAt = storeData.created_at;

        // ... (Datumsprüfung unverändert) ...
        let createdDate = createdAt?.toDate ? createdAt.toDate() : new Date(createdAt);

        if (createdDate < cutoffTime) {
          const storeId = doc.id;
          try {
            // LÖSCHEN: Private
            await db.collection("stores_private").doc(storeId).delete();
            // LÖSCHEN: Public
            await db.collection("stores_public").doc(storeId).delete();

            const slug = storeData.store_slug;
            if (slug) await db.collection("slugs").doc(slug).delete().catch(() => {});

            try { await admin.auth().deleteUser(storeId); } catch (e) {}

            // Produkte aus Public löschen
            const productsSnap = await db.collection("stores_public").doc(storeId)
              .collection("products").get();
            const batch = db.batch();
            productsSnap.docs.forEach(d => batch.delete(d.ref));
            if (productsSnap.size > 0) await batch.commit();

            deletedCount++;
          } catch (deleteError) {
            console.error(`❌ Failed to delete store ${storeId}:`, deleteError);
          }
        }
      }
      console.log(`✅ Cleanup complete. Deleted: ${deletedCount}`);
    } catch (error) {
      console.error("Cleanup failed:", error);
    }
  }
);

/**
 * SECURE: Cleanup Incomplete Setups (v2 Schedule)
 * Löscht alle Stores, die im Status "draft" feststecken (Setup-Wizard nicht abgeschlossen)
 * und älter als 24 Stunden sind.
 */
exports.cleanupIncompleteSetups = onSchedule(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Cron-Job braucht nur 1 Instanz
    schedule: "30 4 * * *", // Läuft täglich um 04:30 UTC (30 Min nach dem anderen Cleanup)
    timeZone: "UTC"
  },
  async (event) => {
    const now = new Date();
    // 24 Stunden zurückrechnen
    const cutoffTime = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    let deletedCount = 0;

    try {
      // 1. Suche in Private nach allen unfertigen Stores
      const incompleteStores = await db.collection("stores_private")
        .where("status", "==", "draft")
        .get();

      for (const doc of incompleteStores.docs) {
        const storeData = doc.data();
        const createdAt = storeData.created_at;

        if (!createdAt) continue; // Überspringen, falls kein Datum existiert

        // Datum konvertieren (Firestore Timestamp -> JS Date)
        let createdDate = createdAt?.toDate ? createdAt.toDate() : new Date(createdAt);

        if (createdDate < cutoffTime) {
          const storeId = doc.id;
          try {
            console.log(`🗑️ Lösche unfertigen Store: ${storeId}`);

            // LÖSCHEN: Private
            await db.collection("stores_private").doc(storeId).delete();
            // LÖSCHEN: Public
            await db.collection("stores_public").doc(storeId).delete();

            // LÖSCHEN: Auth User aus Firebase Authentication
            try {
              await admin.auth().deleteUser(storeId);
            } catch (e) {
              console.warn(`Auth-User ${storeId} war bereits gelöscht.`);
            }

            // LÖSCHEN: Produkte (falls sie im Draft-Status überhaupt angelegt wurden)
            const productsSnap = await db.collection("stores_public").doc(storeId)
              .collection("products").get();
            if (productsSnap.size > 0) {
              const batch = db.batch();
              productsSnap.docs.forEach(d => batch.delete(d.ref));
              await batch.commit();
            }

            deletedCount++;
          } catch (deleteError) {
            console.error(`❌ Failed to delete incomplete store ${storeId}:`, deleteError);
          }
        }
      }
      console.log(`✅ Incomplete Setup Cleanup complete. Deleted: ${deletedCount} unfertige Accounts.`);
    } catch (error) {
      console.error("Cleanup incomplete setups failed:", error);
    }
  }
);

exports.requestAccountDeletion = onCall(
  { region: REGION_PRIMARY },
  async (request) => {
    if (!request.auth) throw new HttpsError("unauthenticated", "Login required.");
    const uid = request.auth.uid;
    // Update Private
    await db.collection("stores_private").doc(uid).update({
        deletion_requested: true,
        deletion_requested_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true, message: "Deletion request submitted." };
  }
);

/**
 * CDN Image Proxy (v2 Request)
 */
exports.cdnImageProxy = onRequest(
  { region: "europe-west3", maxInstances: 2 },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    if (req.method === "OPTIONS") return res.status(204).send("");

    try {
      let storagePath = req.path;
      if (storagePath.startsWith("/images/")) storagePath = storagePath.replace("/images/", "");
      if (storagePath.startsWith("/")) storagePath = storagePath.substring(1);
      storagePath = decodeURIComponent(storagePath);

      const bucketName = "aldeebtech-1ec64.firebasestorage.app";
      const bucket = admin.storage().bucket(bucketName);
      const file = bucket.file(storagePath);

      // ✅ RETRY: kurze Propagation abfangen
      let exists = false;
      for (let i = 0; i < 6; i++) {
        const [e] = await file.exists();
        exists = e;
        if (exists) break;
        await new Promise(r => setTimeout(r, 300)); // 0.3s * 6 = 1.8s max
      }

      if (!exists) {
        // ✅ 404 NICHT CACHEN
        res.set("Cache-Control", "no-store, max-age=0");
        return res.status(404).send("Image not found");
      }

      const [metadata] = await file.getMetadata();

      // ✅ ok für Assets, aber wenn du oft überschreibst: lieber cache-bust per ?v=...
      res.set("Cache-Control", "public, max-age=31536000, s-maxage=31536000, immutable");
      res.set("Content-Type", metadata.contentType || "image/jpeg");

      return file.createReadStream().pipe(res);
    } catch (error) {
      console.error("CDN Error:", error);
      res.set("Cache-Control", "no-store, max-age=0");
      return res.status(500).send("Internal Server Error");
    }
  }
);

// =============================================================================
// ACCESS SYNC: stores_private -> stores_public
// =============================================================================

/**
 * ERLAUBTE ACCESS-FELDER für Public (Whitelist)
 */
const ALLOWED_PUBLIC_ACCESS_KEYS = [
  'status',
  'stage',
  'daysRemaining',
  'trial_start_at',
  'trial_end_at'
];

/**
 * Konvertiert einen Wert in einen vergleichbaren primitiven Wert.
 * Timestamps → Millisekunden, null/undefined → null, Rest unverändert.
 */
function toComparableValue(val) {
  if (val === null || val === undefined) return null;
  // Firestore Timestamp
  if (val && typeof val.toMillis === 'function') {
    return val.toMillis();
  }
  // JS Date
  if (val instanceof Date) {
    return val.getTime();
  }
  return val;
}

/**
 * Prüft ob sich relevante Access-Felder geändert haben.
 * Robust gegen Timestamp-Objekte, null vs undefined, number vs string.
 */
function hasAccessChanged(beforeAccess, afterAccess) {
  // Beide leer = keine Änderung
  if (!beforeAccess && !afterAccess) return false;
  // Einer leer, anderer nicht = Änderung
  if (!beforeAccess || !afterAccess) return true;

  for (const key of ALLOWED_PUBLIC_ACCESS_KEYS) {
    const beforeVal = toComparableValue(beforeAccess[key]);
    const afterVal = toComparableValue(afterAccess[key]);

    // Spezialfall stage: beide zu int normalisieren
    if (key === 'stage') {
      const beforeStage = beforeVal !== null ? parseInt(String(beforeVal), 10) : null;
      const afterStage = afterVal !== null ? parseInt(String(afterVal), 10) : null;
      if (beforeStage !== afterStage) return true;
      continue;
    }

    // Spezialfall status: beide trimmen und lowercase
    if (key === 'status') {
      const beforeStatus = beforeVal !== null ? String(beforeVal).trim().toLowerCase() : null;
      const afterStatus = afterVal !== null ? String(afterVal).trim().toLowerCase() : null;
      if (beforeStatus !== afterStatus) return true;
      continue;
    }

    // Standard-Vergleich
    if (beforeVal !== afterVal) return true;
  }

  return false;
}

/**
 * Extrahiert nur erlaubte Access-Felder für Public.
 * Gibt null NUR zurück wenn weder status noch stage vorhanden sind.
 * Normalisiert stage (int 0-3) und status (lowercase trimmed).
 */
function extractPublicAccessFields(accessData) {
  if (!accessData || typeof accessData !== 'object') return null;

  const result = {};

  // Status (required für sinnvolles Ergebnis)
  if (accessData.status !== undefined && accessData.status !== null) {
    result.status = String(accessData.status).trim().toLowerCase();
  }

  // Stage (required für sinnvolles Ergebnis)
  if (accessData.stage !== undefined && accessData.stage !== null) {
    let stage = parseInt(String(accessData.stage), 10);
    if (isNaN(stage)) stage = 0;
    // Clamp 0-3
    stage = Math.max(0, Math.min(3, stage));
    result.stage = stage;
  }

  // Wenn weder status noch stage → null (kein sinnvolles Access-Objekt)
  if (result.status === undefined && result.stage === undefined) {
    return null;
  }

  // Optionale Felder (nur wenn vorhanden)
  if (accessData.daysRemaining !== undefined && accessData.daysRemaining !== null) {
    const days = parseInt(String(accessData.daysRemaining), 10);
    if (!isNaN(days)) result.daysRemaining = days;
  }

  if (accessData.trial_start_at !== undefined && accessData.trial_start_at !== null) {
    // Timestamp → ISO String, String → behalten
    if (typeof accessData.trial_start_at.toDate === 'function') {
      result.trial_start_at = accessData.trial_start_at.toDate().toISOString();
    } else {
      result.trial_start_at = String(accessData.trial_start_at);
    }
  }

  if (accessData.trial_end_at !== undefined && accessData.trial_end_at !== null) {
    if (typeof accessData.trial_end_at.toDate === 'function') {
      result.trial_end_at = accessData.trial_end_at.toDate().toISOString();
    } else {
      result.trial_end_at = String(accessData.trial_end_at);
    }
  }

  return result;
}

/**
 * Trigger: Sync Access auf stores_private Update
 */
exports.syncAccessToPublic = onDocumentUpdated(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Firestore-Trigger - Access-Sync
    document: "stores_private/{storeId}"
  },
  async (event) => {
    const storeId = event.params.storeId;
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    const beforeAccess = beforeData?.access;
    const afterAccess = afterData?.access;

    // DEBUG LOGS
    console.log("[syncAccessToPublic] storeId=", storeId);
    console.log("[syncAccessToPublic] beforeAccess=", JSON.stringify(beforeAccess));
    console.log("[syncAccessToPublic] afterAccess=", JSON.stringify(afterAccess));

    // Prüfe ob sich Access geändert hat
    const accessChanged = hasAccessChanged(beforeAccess, afterAccess);
    console.log("[syncAccessToPublic] hasAccessChanged=", accessChanged);

    if (!accessChanged) {
      console.log("[syncAccessToPublic] SKIP: Keine Access-Änderung erkannt");
      return null;
    }

    const publicAccess = extractPublicAccessFields(afterAccess);
    console.log("[syncAccessToPublic] publicAccess=", JSON.stringify(publicAccess));

    if (!publicAccess) {
      console.log(`⚠️ [syncAccessToPublic] SKIP: Weder status noch stage vorhanden für ${storeId}`);
      return null;
    }

    // Immer nur access mergen, keine anderen Felder
    const publicRef = db.collection("stores_public").doc(storeId);

    try {
      await publicRef.set({ access: publicAccess }, { merge: true });
      console.log(`✅ [syncAccessToPublic] Access gespiegelt für ${storeId}:`, JSON.stringify(publicAccess));
    } catch (writeError) {
      console.error(`❌ [syncAccessToPublic] Schreibfehler für ${storeId}:`, writeError);
    }

    return null;
  }
);

/**
 * HINWEIS: Kein separater onCreate-Trigger nötig.
 * onStoreCreated setzt access via batch.update() → triggert syncAccessToPublic.
 */

/**
 * ADMIN CALLABLE: Manuelles Sync/Repair
 */
exports.syncStoreAccessToPublic = onCall(
  { region: REGION_PRIMARY },
  async (request) => {
    // 1. Auth Check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }

    // 2. Admin Check
    const adminEmails = [
      'nsem338@gmail.com',
      'aminamuhammed655@gmail.com',
      'kadour.abdull@gmail.com'
    ];
    const callerEmail = request.auth.token.email;
    const isAdmin = request.auth.token.admin === true || adminEmails.includes(callerEmail);

    if (!isAdmin) {
      throw new HttpsError("permission-denied", "Only admins can call this function.");
    }

    // 3. Parameter
    const { storeId } = request.data;
    if (!storeId) {
      throw new HttpsError("invalid-argument", "storeId is required.");
    }

    console.log(`[syncStoreAccessToPublic] Manual sync requested for ${storeId} by ${callerEmail}`);

    // 4. Private Daten laden
    const privateRef = db.collection("stores_private").doc(storeId);
    const privateDoc = await privateRef.get();

    if (!privateDoc.exists) {
      throw new HttpsError("not-found", `Store ${storeId} not found in stores_private.`);
    }

    const privateData = privateDoc.data();
    const accessData = privateData?.access;

    console.log(`[syncStoreAccessToPublic] accessData from private=`, JSON.stringify(accessData));

    if (!accessData) {
      throw new HttpsError("failed-precondition", `Store ${storeId} has no access data.`);
    }

    // 5. Nur erlaubte Felder extrahieren (robuste Funktion)
    const publicAccess = extractPublicAccessFields(accessData);
    console.log(`[syncStoreAccessToPublic] publicAccess=`, JSON.stringify(publicAccess));

    if (!publicAccess) {
      throw new HttpsError("failed-precondition", "No valid access fields (status/stage) to sync.");
    }

    // 6. In Public schreiben - IMMER nur access mergen
    const publicRef = db.collection("stores_public").doc(storeId);
    await publicRef.set({ access: publicAccess }, { merge: true });

    console.log(`✅ [syncStoreAccessToPublic] Manual sync SUCCESS for ${storeId}:`, JSON.stringify(publicAccess));

    return {
      success: true,
      storeId: storeId,
      syncedFields: Object.keys(publicAccess),
      access: publicAccess
    };
  }
);

// =============================================================================
// REVERSE GEOCODING (Cloud Function Proxy für Web)
// =============================================================================

/**
 * Reverse Geocoding via Google Maps API (serverseitig)
 * - Sicher: API-Key bleibt serverseitig (Secret Manager)
 * - Web-kompatibel: CORS für admin.aldeebtech.de
 * - Input: lat, lng, (optional: language)
 * - Output: formattedAddress, city, postalCode, countryCode, placeId
 */
exports.reverseGeocode = onCall(
  {
    region: REGION_PRIMARY,
    secrets: [googleMapsApiKey],
    cors: [
      "https://admin.aldeebtech.de",
      "https://aldeebtech.de",
      "http://localhost:*",  // Für lokale Entwicklung
    ]
  },
  async (request) => {
    // 1. Input-Validierung
    const { lat, lng, language } = request.data || {};

    if (lat === undefined || lng === undefined) {
      throw new HttpsError("invalid-argument", "lat and lng are required.");
    }

    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    if (isNaN(latitude) || isNaN(longitude)) {
      throw new HttpsError("invalid-argument", "lat and lng must be valid numbers.");
    }

    // Validiere Koordinaten-Bereiche
    if (latitude < -90 || latitude > 90) {
      throw new HttpsError("invalid-argument", "lat must be between -90 and 90.");
    }
    if (longitude < -180 || longitude > 180) {
      throw new HttpsError("invalid-argument", "lng must be between -180 and 180.");
    }

    // 2. Sprache (Standard: de)
    const lang = language || 'en';

    // 3. Google Geocoding API aufrufen
    const apiKey = googleMapsApiKey.value();
    const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${apiKey}&language=${lang}`;

    console.log(`🌍 [reverseGeocode] Request: lat=${latitude}, lng=${longitude}, lang=${lang}`);

    try {
      const response = await axios.get(url, { timeout: 10000 });
      const data = response.data;

      // 4. API-Status prüfen
      if (data.status !== 'OK') {
        console.error(`❌ [reverseGeocode] Google API Error: ${data.status}`, data.error_message);

        if (data.status === 'ZERO_RESULTS') {
          throw new HttpsError("not-found", "No address found for these coordinates.");
        }
        if (data.status === 'REQUEST_DENIED') {
          throw new HttpsError("internal", "Geocoding service configuration error.");
        }
        if (data.status === 'OVER_QUERY_LIMIT') {
          throw new HttpsError("resource-exhausted", "Geocoding quota exceeded. Please try later.");
        }

        throw new HttpsError("internal", `Geocoding failed: ${data.status}`);
      }

      // 5. Ergebnis parsen
      const results = data.results;
      if (!results || results.length === 0) {
        throw new HttpsError("not-found", "No address found for these coordinates.");
      }

      const firstResult = results[0];
      const addressComponents = firstResult.address_components || [];

      // Komponenten extrahieren
      let streetNumber = '';
      let route = '';
      let sublocality = '';
      let locality = '';
      let adminArea = '';
      let country = '';
      let countryCode = '';
      let postalCode = '';

      for (const component of addressComponents) {
        const types = component.types || [];

        if (types.includes('street_number')) {
          streetNumber = component.long_name;
        } else if (types.includes('route')) {
          route = component.long_name;
        } else if (types.includes('sublocality') || types.includes('sublocality_level_1')) {
          sublocality = component.long_name;
        } else if (types.includes('locality')) {
          locality = component.long_name;
        } else if (types.includes('administrative_area_level_1')) {
          adminArea = component.long_name;
        } else if (types.includes('country')) {
          country = component.long_name;
          countryCode = component.short_name;
        } else if (types.includes('postal_code')) {
          postalCode = component.long_name;
        }
      }

      // Kompakte Adresse bauen (ohne Land, ohne Duplikate)
      const street = streetNumber ? `${route} ${streetNumber}`.trim() : route;
      const addressParts = [street, sublocality, locality, adminArea]
        .filter(p => p && p.trim().length > 0)
        .filter((v, i, a) => a.indexOf(v) === i); // Deduplizieren

      const formattedAddress = addressParts.join(', ');

      console.log(`✅ [reverseGeocode] Success: "${formattedAddress}" (${countryCode})`);

      return {
        success: true,
        formattedAddress: formattedAddress || firstResult.formatted_address,
        fullAddress: firstResult.formatted_address,
        city: locality || adminArea,
        postalCode: postalCode,
        countryCode: countryCode,
        country: country,
        placeId: firstResult.place_id
      };

    } catch (error) {
      if (error instanceof HttpsError) throw error;

      console.error(`❌ [reverseGeocode] Network Error:`, error.message);
      throw new HttpsError("internal", "Failed to connect to geocoding service.");
    }
  }
);

// =============================================================================
// STORE NAME SYNC: stores_private <-> stores_public
// =============================================================================

/**
 * Sync store_name von stores_private nach stores_public
 * Trigger: Wenn store_name in stores_private geändert wird
 */
exports.syncStoreNameToPublic = onDocumentUpdated(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Firestore-Trigger - Name-Sync
    document: "stores_private/{storeId}"
  },
  async (event) => {
    const storeId = event.params.storeId;
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    const beforeName = beforeData?.store_name?.toString().trim();
    const afterName = afterData?.store_name?.toString().trim();

    // Keine Änderung -> Skip
    if (beforeName === afterName) {
      return null;
    }

    // Endlosschleifen verhindern: Check ob es ein Sync-Update war
    const lastSyncSource = afterData?._sync_source;
    if (lastSyncSource === 'public_to_private') {
      console.log(`[syncStoreNameToPublic] SKIP: Update was from public sync for ${storeId}`);
      // Sync-Flag zurücksetzen
      await event.data.after.ref.update({ _sync_source: admin.firestore.FieldValue.delete() });
      return null;
    }

    if (!afterName) {
      console.log(`[syncStoreNameToPublic] SKIP: No store_name for ${storeId}`);
      return null;
    }

    console.log(`[syncStoreNameToPublic] Syncing "${beforeName}" → "${afterName}" for ${storeId}`);

    try {
      const publicRef = db.collection("stores_public").doc(storeId);
      await publicRef.set({
        store_name: afterName,
        _sync_source: 'private_to_public',
        _synced_at: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

      console.log(`✅ [syncStoreNameToPublic] Synced store_name to public for ${storeId}`);
    } catch (error) {
      console.error(`❌ [syncStoreNameToPublic] Error for ${storeId}:`, error);
    }

    return null;
  }
);

/**
 * Sync store_name von stores_public nach stores_private
 * Trigger: Wenn store_name in stores_public geändert wird
 */
exports.syncStoreNameToPrivate = onDocumentUpdated(
  {
    region: REGION_PRIMARY,
    maxInstances: 1, // Firestore-Trigger - Name-Sync
    document: "stores_public/{storeId}"
  },
  async (event) => {
    const storeId = event.params.storeId;
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    const beforeName = beforeData?.store_name?.toString().trim();
    const afterName = afterData?.store_name?.toString().trim();

    // Keine Änderung -> Skip
    if (beforeName === afterName) {
      return null;
    }

    // Endlosschleifen verhindern: Check ob es ein Sync-Update war
    const lastSyncSource = afterData?._sync_source;
    if (lastSyncSource === 'private_to_public') {
      console.log(`[syncStoreNameToPrivate] SKIP: Update was from private sync for ${storeId}`);
      // Sync-Flag zurücksetzen
      await event.data.after.ref.update({ _sync_source: admin.firestore.FieldValue.delete() });
      return null;
    }

    if (!afterName) {
      console.log(`[syncStoreNameToPrivate] SKIP: No store_name for ${storeId}`);
      return null;
    }

    console.log(`[syncStoreNameToPrivate] Syncing "${beforeName}" → "${afterName}" for ${storeId}`);

    try {
      const privateRef = db.collection("stores_private").doc(storeId);
      await privateRef.set({
        store_name: afterName,
        _sync_source: 'public_to_private',
        _synced_at: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

      console.log(`✅ [syncStoreNameToPrivate] Synced store_name to private for ${storeId}`);
    } catch (error) {
      console.error(`❌ [syncStoreNameToPrivate] Error for ${storeId}:`, error);
    }

    return null;
  }
);

// =============================================================================
// FINALIZE STORE SETUP - Slug atomar reservieren
// =============================================================================

/**
 * SECURE: Finalisiert Store-Setup und reserviert Slug atomar
 *
 * Wird aufgerufen wenn User im Wizard "Abschließen" drückt.
 * Macht in einer Transaction:
 * 1. Prüft ob Slug frei ist
 * 2. Erstellt slugs/{slug} Dokument
 * 3. Updated stores_private mit slug + status = "active"
 * 4. Updated stores_public mit slug + public_store_url + status = "active"
 *
 * Input: { storeName: string, desiredSlug?: string }
 * Output: { success: true, slug: string, publicUrl: string } oder { success: false, error: string }
 */
exports.finalizeStoreSetup = onCall(
  { region: REGION_PRIMARY },
  async (request) => {
    // 1. Auth Check
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Login required.");
    }

    const uid = request.auth.uid;
    const { storeName, desiredSlug } = request.data || {};

    if (!storeName || storeName.trim().length === 0) {
      throw new HttpsError("invalid-argument", "storeName is required.");
    }
    if (storeName.trim().length > 40) {
      throw new HttpsError("invalid-argument", "storeName must not exceed 40 characters.");
    }

    console.log(`[finalizeStoreSetup] Starting for store ${uid}, name="${storeName}", desiredSlug="${desiredSlug || 'auto'}"`);

    // 2. Prüfen ob Store bereits finalisiert ist
    const privateRef = db.collection("stores_private").doc(uid);
    const privateDoc = await privateRef.get();

    if (!privateDoc.exists) {
      throw new HttpsError("not-found", "Store not found.");
    }

    const privateData = privateDoc.data();
    if (privateData.status === 'active' && privateData.store_slug) {
      const existingSlug = privateData.store_slug;
      console.log(`[finalizeStoreSetup] Store ${uid} already finalized with slug: ${existingSlug}`);

      // IDEMPOTENT: Prüfen ob slugs/{slug} existiert, falls nicht → anlegen
      const slugDocRef = db.collection("slugs").doc(existingSlug);
      const slugDoc = await slugDocRef.get();
      if (!slugDoc.exists) {
        console.log(`[finalizeStoreSetup] REPAIR: slugs/${existingSlug} fehlt, wird angelegt...`);
        await slugDocRef.set({
          store_id: uid,
          store_name: privateData.store_name || storeName,
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        console.log(`[finalizeStoreSetup] ✅ slugs/${existingSlug} repariert`);
      }

      return {
        success: true,
        slug: existingSlug,
        publicUrl: `https://aldeebtech.de/s/${existingSlug}`,
        message: "Store already finalized."
      };
    }

    // 3. Slug generieren oder validieren
    let finalSlug;
    const MAX_SLUG_ATTEMPTS = 100;

    if (desiredSlug && desiredSlug.trim().length > 0) {
      // User hat einen Slug gewünscht - validieren
      const cleanSlug = desiredSlug.trim().toLowerCase()
        .replace(/[^a-z0-9-]/g, '')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '');

      if (cleanSlug.length < 3) {
        throw new HttpsError("invalid-argument", "Slug must be at least 3 characters.");
      }
      if (cleanSlug.length > 50) {
        throw new HttpsError("invalid-argument", "Slug must be less than 50 characters.");
      }

      // Reservierte Slugs prüfen
      const reserved = ['admin', 'api', 'login', 'register', 'store', 'stores', 'user', 'users', 'app', 'www', 'mail', 'support', 'help', 'dashboard', 'settings', 'payment', 'checkout'];
      if (reserved.includes(cleanSlug)) {
        throw new HttpsError("invalid-argument", "This slug is reserved.");
      }

      finalSlug = cleanSlug;
    } else {
      // Slug aus Store-Name generieren
      let baseSlug = generateArabicSlug(storeName.trim());

      if (!baseSlug || baseSlug.length < 2) {
        baseSlug = "store";
      }

      // Verfügbaren Slug finden
      for (let suffix = 1; suffix <= MAX_SLUG_ATTEMPTS; suffix++) {
        const candidateSlug = suffix === 1 ? baseSlug : `${baseSlug}-${suffix}`;
        const slugDoc = await db.collection("slugs").doc(candidateSlug).get();

        if (!slugDoc.exists) {
          finalSlug = candidateSlug;
          break;
        }
      }

      if (!finalSlug) {
        // Fallback mit Timestamp
        finalSlug = `${baseSlug.substring(0, 20)}-${Date.now()}`;
      }
    }

    console.log(`[finalizeStoreSetup] Using slug: ${finalSlug}`);

    // 4. ATOMARE TRANSACTION: Slug reservieren + Store updaten
    const publicUrl = `https://aldeebtech.de/s/${finalSlug}`;

    try {
      await db.runTransaction(async (transaction) => {
        // A. Prüfen ob Slug noch frei ist
        const slugRef = db.collection("slugs").doc(finalSlug);
        const slugDoc = await transaction.get(slugRef);

        if (slugDoc.exists) {
          throw new Error("SLUG_TAKEN");
        }

        // B. Slug-Dokument erstellen
        transaction.set(slugRef, {
          store_id: uid,
          store_name: storeName.trim(),
          created_at: admin.firestore.FieldValue.serverTimestamp()
        });

        // C. stores_private updaten
        transaction.update(privateRef, {
          status: 'active',
          store_slug: finalSlug,
          setup_complete: true, // WICHTIG: Router prüft dieses Flag!
          setup_completed_at: admin.firestore.FieldValue.serverTimestamp()
        });

        // D. stores_public updaten
        const publicRef = db.collection("stores_public").doc(uid);
        transaction.update(publicRef, {
          status: 'active',
          store_slug: finalSlug,
          public_store_url: publicUrl,
          store_name: storeName.trim(),
          setup_complete: true // WICHTIG: Router prüft dieses Flag!
        });
      });

      console.log(`✅ [finalizeStoreSetup] Success for ${uid}: slug="${finalSlug}"`);

      return {
        success: true,
        slug: finalSlug,
        publicUrl: publicUrl
      };

    } catch (error) {
      if (error.message === "SLUG_TAKEN") {
        console.warn(`⚠️ [finalizeStoreSetup] Slug "${finalSlug}" was taken during transaction for ${uid}`);
        throw new HttpsError("already-exists", "This slug was just taken. Please try again.");
      }

      console.error(`❌ [finalizeStoreSetup] Transaction failed for ${uid}:`, error);
      throw new HttpsError("internal", "Failed to finalize store setup. Please try again.");
    }
  }
);

// =============================================================================
// FX RATES - Wechselkurse für Stripe Fixed Local Currency
// =============================================================================

const FX_CACHE_DOC = "system/fx_rates";
const FX_TTL_HOURS = 24;
const FX_API_URL = "https://open.er-api.com/v6/latest/EUR";

/**
 * SCHEDULED: Aktualisiert FX-Kurse täglich um 04:00 UTC
 * Quelle: ExchangeRate-API (kostenlos, tägliches Update)
 * Attribution required: https://www.exchangerate-api.com
 */
exports.refreshFxRates = onSchedule(
  {
    schedule: "0 4 * * *", // Täglich 04:00 UTC
    timeZone: "UTC",
    region: REGION_PRIMARY,
    maxInstances: 1, // Cron-Job braucht nur 1 Instanz
  },
  async () => {
    console.log("[refreshFxRates] Starting scheduled FX refresh...");

    try {
      const response = await axios.get(FX_API_URL, { timeout: 10000 });

      // ExchangeRate-API response validation
      if (!response.data || response.data.result !== 'success' || !response.data.rates) {
        throw new Error(`Invalid response from FX API: ${response.data?.result || 'no data'}`);
      }

      const rates = {};
      for (const [code, rate] of Object.entries(response.data.rates)) {
        rates[code.toLowerCase()] = rate;
      }

      // Cache in Firestore speichern
      await db.doc(FX_CACHE_DOC).set({
        base_currency: response.data.base_code?.toLowerCase() || "eur",
        rates: rates,
        last_updated: admin.firestore.FieldValue.serverTimestamp(),
        source: "er-api-open",
        provider: "https://www.exchangerate-api.com",
        ttl_hours: FX_TTL_HOURS,
        time_last_update_utc: response.data.time_last_update_utc || null,
        time_next_update_utc: response.data.time_next_update_utc || null,
      });

      console.log(`✅ [refreshFxRates] Updated ${Object.keys(rates).length} rates from ExchangeRate-API`);

    } catch (error) {
      // Bei Fehler: Alten Cache NICHT überschreiben!
      console.error(`❌ [refreshFxRates] Failed to refresh:`, error.message);
      // Optional: Alerting wenn Cache zu alt wird
    }
  }
);

// HINWEIS: getFxRate Callable wurde entfernt.
// Client liest jetzt direkt aus /system/fx_rates (Firestore).
// Das ist schneller und reduziert Cloud Function Aufrufe.

// =============================================================================
// CATEGORY RECOMMENDATION SYSTEM
// =============================================================================

/**
 * normalizeText — Firestore-safe DocID from any language text
 */
function normalizeText(text) {
  if (!text || typeof text !== 'string') return '';
  return text.trim().toLowerCase()
    .replace(/[/\\._~#[\]*]+/g, ' ')
    .replace(/[^\p{L}\p{N}\s-]/gu, '')
    .replace(/\s+/g, '-')
    .replace(/-{2,}/g, '-')
    .replace(/^-|-$/g, '');
}

/**
 * findCanonicalCategory — Direct match on doc ID, then alias search
 */
async function findCanonicalCategory(normalizedCategory) {
  if (!normalizedCategory) return null;

  // 1. Direct match on doc ID
  const directDoc = await db.collection('global_categories').doc(normalizedCategory).get();
  if (directDoc.exists) {
    return { id: directDoc.id, labels: directDoc.data().labels };
  }

  // 2. Alias search via array-contains
  const aliasSnap = await db.collection('global_categories')
    .where('aliasesNormalized', 'array-contains', normalizedCategory)
    .limit(1)
    .get();

  if (!aliasSnap.empty) {
    const doc = aliasSnap.docs[0];
    return { id: doc.id, labels: doc.data().labels };
  }

  // 3. Label scan — compare normalized label values across all languages
  const allCats = await db.collection('global_categories').get();
  for (const doc of allCats.docs) {
    const labels = doc.data().labels;
    if (!labels || typeof labels !== 'object') continue;
    for (const val of Object.values(labels)) {
      if (typeof val === 'string' && normalizeText(val) === normalizedCategory) {
        return { id: doc.id, labels };
      }
    }
  }

  return null;
}

/**
 * addDictionaryVote — Transaction to update product→category mapping
 */
async function addDictionaryVote(normalizedName, displayName, newCatId) {
  const ref = db.collection('global_product_category_dictionary').doc(normalizedName);
  await db.runTransaction(async (t) => {
    const doc = await t.get(ref);
    const data = doc.exists ? doc.data() : {};
    const counts = data.categoryCounts || {};
    counts[newCatId] = (counts[newCatId] || 0) + 1;

    let topId = newCatId, topCount = 0, totalCount = 0;
    for (const [catId, cnt] of Object.entries(counts)) {
      totalCount += cnt;
      if (cnt > topCount) { topCount = cnt; topId = catId; }
    }

    t.set(ref, {
      displayName,
      normalizedName,
      categoryCounts: counts,
      topCategoryId: topId,
      topCount,
      totalCount,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  });
}

/**
 * learnProductCategory — onWrite trigger for products
 * Learns product→category mapping from active products (create + update)
 */
exports.learnProductCategory = onDocumentWritten(
  {
    document: 'stores_public/{storeId}/products/{productId}',
    region: REGION_PRIMARY,
    maxInstances: 1,
  },
  async (event) => {
    try {
      const after = event.data?.after;
      if (!after || !after.exists) return; // deleted

      const data = after.data();
      if (!data) return;

      // Skip inactive products (spam protection)
      if (data.product_active !== true) return;

      const rawName = data.name;
      const rawCategory = data.category;
      if (!rawName || !rawCategory) return;

      // On update: skip if name and category unchanged
      const before = event.data?.before;
      if (before && before.exists) {
        const prev = before.data() || {};
        if (prev.name === rawName && prev.category === rawCategory) return;
      }

      const normalizedName = normalizeText(rawName);
      const normalizedCategory = normalizeText(rawCategory);
      if (!normalizedName || !normalizedCategory) return;

      // Only learn if category is in our canonical whitelist
      const canonical = await findCanonicalCategory(normalizedCategory);
      if (!canonical) {
        console.log(`[learnProductCategory] Category "${rawCategory}" not in whitelist, skipping`);
        return;
      }

      await addDictionaryVote(normalizedName, rawName, canonical.id);
      console.log(`[learnProductCategory] Learned: "${rawName}" → "${canonical.id}"`);
    } catch (error) {
      console.error('[learnProductCategory] Error:', error.message);
    }
  }
);

/**
 * seedDictionary — HTTPS endpoint to seed initial categories + products
 * POST only, token via x-seed-token header
 */
exports.seedDictionary = onRequest(
  {
    region: REGION_PRIMARY,
    maxInstances: 1,
    secrets: [seedSecret],
    cors: false,
  },
  async (req, res) => {
    // Only POST
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");

    // Auth via secret header
    const token =
      req.get("x-seed-token") ??
      (req.get("authorization")?.replace("Bearer ", "") ?? "");

    if (!token || token !== seedSecret.value()) {
      return res.status(403).send("Forbidden");
    }

    try {
      const categories = Array.isArray(seedData.categories) ? seedData.categories : [];
      const products = Array.isArray(seedData.products) ? seedData.products : [];

      if (categories.length === 0) {
        return res.status(400).json({ error: "seedData.categories is empty" });
      }

      const validCategoryIds = new Set(categories.map((c) => c.id));
      const fallbackCategoryId = validCategoryIds.has("sonstiges")
        ? "sonstiges"
        : categories[0].id;

      // ---- Seed categories (upsert / merge) ----
      {
        const batch = db.batch();
        for (const c of categories) {
          if (!c?.id || !c?.labels) continue;

          const aliasesNormalized = (c.aliases ?? [])
            .map((a) => normalizeText(String(a)))
            .filter(Boolean);

          batch.set(
            db.collection("global_categories").doc(c.id),
            {
              normalizedName: c.id,
              labels: c.labels,
              aliasesNormalized,
            },
            { merge: true }
          );
        }
        await batch.commit();
      }

      // ---- Prepare products (dedupe by normalized name) ----
      const seen = new Set();
      const rows = [];
      for (const p of products) {
        const displayName = String(p?.name ?? "").trim();
        if (!displayName) continue;

        const normalizedName = normalizeText(displayName);
        if (!normalizedName || seen.has(normalizedName)) continue;
        seen.add(normalizedName);

        const categoryId = validCategoryIds.has(p?.categoryId)
          ? p.categoryId
          : fallbackCategoryId;

        rows.push({ normalizedName, displayName, categoryId });
      }

      // ---- Seed products (ONLY create missing docs; don’t overwrite learned data) ----
      let created = 0;
      let skippedExisting = 0;

      // read+write in chunks
      const CHUNK = 300;
      for (let i = 0; i < rows.length; i += CHUNK) {
        const chunk = rows.slice(i, i + CHUNK);

        const refs = chunk.map((r) =>
          db.collection("global_product_category_dictionary").doc(r.normalizedName)
        );

        const snaps = await db.getAll(...refs);

        const batch = db.batch();
        for (let j = 0; j < chunk.length; j++) {
          const row = chunk[j];
          const snap = snaps[j];

          if (snap.exists) {
            skippedExisting++;
            continue;
          }

          batch.set(refs[j], {
            displayName: row.displayName,
            normalizedName: row.normalizedName,
            categoryCounts: { [row.categoryId]: 1 },
            topCategoryId: row.categoryId,
            topCount: 1,
            totalCount: 1,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            seeded: true,
          });

          created++;
        }

        await batch.commit();
      }

      // optional: meta marker (nice to have)
      await db.collection("global_dictionary_meta").doc("seed").set(
        {
          seededAt: admin.firestore.FieldValue.serverTimestamp(),
          categories: categories.length,
          productsCreated: created,
          productsSkippedExisting: skippedExisting,
        },
        { merge: true }
      );

      return res.status(200).json({
        success: true,
        categories: categories.length,
        productsTotalInSeed: rows.length,
        productsCreated: created,
        productsSkippedExisting: skippedExisting,
      });
    } catch (error) {
      console.error("[seedDictionary] Error:", error);
      return res.status(500).json({ error: error.message });
    }
  }


);

exports.translateProductNamePublic =
  require("./i18n_product_names").translateProductNamePublic;
exports.syncStoresOnProductDictUpdate =
  require("./i18n_product_names").syncStoresOnProductDictUpdate;
exports.syncStoresOnCategoryDictUpdate =
  require("./i18n_product_names").syncStoresOnCategoryDictUpdate;

exports.translateProductDescription =
  require("./i18n_product_descriptions").translateProductDescription;
exports.runPendingDescTranslations =
  require("./i18n_product_descriptions").runPendingDescTranslations;
exports.moderateProductAfterWrite =
  require("./moderation_products").moderateProductAfterWrite;
