/**
 * Firebase Cloud Functions - FINAL PROD VERSION (v2 Migration)
 * Location: functions/index.js
 */

require("dotenv").config();

// =============================================================================
// v2 IMPORTS
// =============================================================================
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");

// --- WICHTIG: DIESE ZEILE HINZUFÜGEN ---
const { setGlobalOptions } = require("firebase-functions/v2/options");
// ----------------------------------------

const admin = require("firebase-admin");
const axios = require("axios");

// 1. GLOBALE EINSTELLUNGEN SETZEN
// Setzt für ALLE v2 Funktionen die Region und das Limit
setGlobalOptions({
  region: "europe-west3",
  maxInstances: 20, // Das ist jetzt sicher für deinen Shop
});

admin.initializeApp();
const db = admin.firestore();

// =============================================================================
// STRIPE CONFIGURATION
// =============================================================================

const stripeSecret = defineSecret("STRIPE_SECRET");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
const googleMapsApiKey = defineSecret("GOOGLE_MAPS_API_KEY");

const REGION = "europe-west3";
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

function generateArabicSlug(name) {
  if (!name) return null;

  const dictionary = {
      'متجر': 'matjar', 'محل': 'mahal', 'سوق': 'souq', 'مركز': 'markaz',
      'محمد': 'muhammad', 'أحمد': 'ahmad', 'احمد': 'ahmad', 'علي': 'ali',
      'عمر': 'omar', 'خالد': 'khaled', 'سعيد': 'saeed', 'يوسف': 'yusuf',
      'عبدالله': 'abdullah', 'عبد الله': 'abdullah', 'نور': 'noor',
      'الرياض': 'riyadh', 'جدة': 'jeddah', 'مكة': 'makkah', 'دبي': 'dubai',
      'ال': 'al', 'و': 'wa', 'بو': 'bu', 'بن': 'bin'
    };


  const charMap = {
    'ا': 'a', 'أ': 'a', 'إ': 'e', 'آ': 'a', 'ى': 'a', 'ئ': 'e', 'ؤ': 'o',
    'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j', 'ح': 'h', 'خ': 'kh',
    'د': 'd', 'ذ': 'dh', 'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh',
    'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z', 'ع': 'a', 'غ': 'gh',
    'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l',
    'م': 'm', 'ن': 'n', 'ه': 'h', 'و': 'w', 'ي': 'y', 'ة': 'h',
    'َ': 'a', 'ُ': 'u', 'ِ': 'i'
  };

  let processedName = name;

  // 1. Dictionary Ersetzungen
  Object.keys(dictionary).forEach(key => {
     const regex = new RegExp(key, 'g');
     processedName = processedName.replace(regex, ' ' + dictionary[key] + ' ');
  });

  // 2. Zeichenweise Transliteration
  processedName = processedName.split('').map(char => charMap[char] || char).join('');

  // 3. Cleanup: Alles außer a-z, 0-9 entfernen, Leerzeichen zu Bindestrichen
  return processedName.toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '') // Sonderzeichen weg
    .replace(/\s+/g, '-')         // Leerzeichen zu Bindestrich
    .replace(/-+/g, '-')          // Doppelte Bindestriche weg (z.B. al--wasail -> al-wasail)
    .replace(/^-|-$/g, '');       // Bindestriche am Anfang/Ende weg
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

/**
 * Entfernt rekursiv nur 'undefined' (ohne Firestore-Typen kaputt zu machen).
 */
function stripUndefined(value) {
  if (value === undefined) return undefined;
  if (value === null) return null;

  // Firestore Special Types nicht anfassen
  if (value instanceof admin.firestore.Timestamp) return value;
  if (value instanceof admin.firestore.GeoPoint) return value;
  if (value instanceof admin.firestore.DocumentReference) return value;

  if (Array.isArray(value)) {
    const arr = value
      .map(stripUndefined)
      .filter((v) => v !== undefined);
    return arr;
  }

  if (typeof value === "object") {
    const out = {};
    for (const [k, v] of Object.entries(value)) {
      const cleaned = stripUndefined(v);
      if (cleaned !== undefined) out[k] = cleaned;
    }
    return out;
  }

  return value;
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
exports.resolveUserRegion = onCall({ region: REGION }, async (request) => {
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
    region: REGION,
    schedule: "0 3 * * *",
    timeZone: "UTC"
  },
  updateTrialAndExpiredStores
);

/**
 * Trigger: New Store Created (v2 Firestore)
 * Replaces: functions.firestore.document().onCreate
 */
/**
 * Trigger: New Store Created (v2 Firestore)
 * Replaces: functions.firestore.document().onCreate
 */
exports.onStoreCreated = onDocumentCreated(
  {
    region: REGION,
    document: "stores_private/{storeId}"
  },
  async (event) => {
    const privateData = event.data.data();
    const id = event.params.storeId;
    const batch = db.batch();

    const publicStoreRef = db.collection("stores_public").doc(id);

    // 1. Template-Daten laden [cite: 177]
    const templateStoreDoc = await db.collection("_defaults").doc("sample_store").get();
    const templateStoreData = templateStoreDoc.exists ? templateStoreDoc.data() : {};

    // 2. Zeitberechnung [cite: 178]
    const now = new Date();
    const trialEndDate = new Date(now.getTime() + (14 * 24 * 60 * 60 * 1000));

    // 3. ZENTRALE NAMEN & SLUG LOGIK (FIX)
    // Wir legen den Namen hier EINMAL fest, damit Slug und DB-Eintrag garantiert identisch sind.
    const storeName = privateData.store_name || "Store";
    let slug = privateData.store_slug;

    if (!slug) {
      // Nutze die existierende Helper-Funktion auf den oben definierten Namen
      let baseSlug = generateArabicSlug(storeName); // [cite: 133, 179]

      // Fallback: Wenn Transliteration leer ist ODER der Name nur "Store" war
      if (!baseSlug || baseSlug.length < 2 || storeName === "Store") {
        baseSlug = "store"; // [cite: 180]
      }

      // ID anhängen für Eindeutigkeit (die ersten 4 Zeichen)
      slug = baseSlug + '-' + id.substring(0, 4); // [cite: 181]
    }

    // 4. Slug in Collection registrieren
    // WICHTIG: Wir nutzen hier die Variable 'storeName' von oben
    batch.set(db.collection("slugs").doc(slug), {
      store_id: id,
      store_name: storeName,
      created_at: admin.firestore.FieldValue.serverTimestamp()
    });

    try {
      // 5. Produkte kopieren (Sample Data) [cite: 183]
      // 5. Produkte kopieren (Sample Data) – OHNE BATCH
      const defaultProductsSnapshot = await db
        .collection("_defaults")
        .doc("sample_store")
        .collection("products")
        .get();

      console.log(`📦 Gefundene Produkte zum Kopieren: ${defaultProductsSnapshot.size}`);

      // ✅ Chunked writes (stabiler) + Firestore-Typen bleiben erhalten
      const docs = defaultProductsSnapshot.docs;
      const CHUNK_SIZE = 25;

      for (let i = 0; i < docs.length; i += CHUNK_SIZE) {
        const chunk = docs.slice(i, i + CHUNK_SIZE);

        const results = await Promise.allSettled(
          chunk.map((d) => {
            const productData = d.data();
            const cleanData = stripUndefined(productData);

            const newProductRef = publicStoreRef.collection("products").doc();
            return newProductRef.set({
              ...cleanData,
              id: newProductRef.id,
              created_at: admin.firestore.FieldValue.serverTimestamp()
            });
          })
        );

        const failed = results
          .map((r, idx) => ({ r, templateId: chunk[idx].id }))
          .filter((x) => x.r.status === "rejected");

        if (failed.length) {
          console.error("❌ Fehler beim Kopieren einiger Sample-Produkte:", failed.map(f => ({
            templateId: f.templateId,
            error: String(f.r.reason)
          })));
          // Nicht abbrechen: wir wollen trotzdem den Store anlegen
        }
      }

      console.log("✅ Sample-Produkte erfolgreich kopiert");


      // 6. UPDATE PRIVATE [cite: 186]
      // Wir setzen hier KEIN 'region' Feld, da 'address_country' das führende Feld ist.
      batch.update(event.data.ref, {
        "access.status": "trial",
        "access.stage": 0,          // Sicherstellen, dass Stage gesetzt ist
        "access.trial_start_at": now.toISOString(),
        "access.trial_end_at": trialEndDate.toISOString(),
        "access.daysRemaining": 14,
        "store_slug": slug          // Den generierten Slug speichern
      });

      // 7. UPDATE PUBLIC [cite: 187]
      // Initiales Access-Mirror (nur erlaubte Felder)
      const initialPublicAccess = {
        status: 'trial',
        stage: 0,
        daysRemaining: 14,
        trial_start_at: now.toISOString(),
        trial_end_at: trialEndDate.toISOString()
      };

      batch.set(publicStoreRef, {
        ...templateStoreData,
        store_name: storeName,
        store_slug: slug,
        public_store_url: `https://aldeebtech.de/s/${slug}`,
        has_products: defaultProductsSnapshot.size > 0,
        access: initialPublicAccess,  // Access sofort gespiegelt
        created_at: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

      await batch.commit(); // [cite: 188]
      console.log(`✅ Store ${id} erfolgreich initialisiert. Slug: ${slug}`);

    } catch (error) {
      console.error("❌ Fehler bei der Initialisierung des Stores:", error); // [cite: 188]
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
    region: REGION,
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
    region: REGION,
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
    let returnBaseUrl = "https://admin.aldeebtech.de/payment";
    if (platform === 'web') returnBaseUrl = "https://aldeebtech.de/#/payment";

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
    region: REGION,
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
    region: REGION,
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

/**
 * PUBLIC API: Get Products (v2 Request)
 * FIX: Liest aus stores_public/products
 */
exports.getProductsBySlug = onRequest(
  {
    region: REGION,
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
  { region: REGION },
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
  { region: REGION },
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
    region: REGION,
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

exports.requestAccountDeletion = onCall(
  { region: REGION },
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
  { region: "europe-west3" },
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

      const [exists] = await file.exists();
      if (!exists) return res.status(404).send("Image not found");

      const [metadata] = await file.getMetadata();
      res.set("Cache-Control", "public, max-age=31536000, s-maxage=31536000, immutable");
      res.set("Content-Type", metadata.contentType || "image/jpeg");

      file.createReadStream().pipe(res);
    } catch (error) {
      console.error("CDN Error:", error);
      res.status(500).send("Internal Server Error");
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
    region: REGION,
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
  { region: REGION },
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
    region: REGION,
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
    const lang = language || 'de';

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
    region: REGION,
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
    region: REGION,
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
    region: REGION,
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