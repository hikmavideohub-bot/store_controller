import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

import '../app_theme_mode.dart';
import '../config.dart';
import '../theme.dart';

// =====================================================
// PRIVACY SERVICE
// -----------------------------------------------------
// Central location for privacy consent and
// privacy policy. Texts can be easily
// updated here.
// =====================================================

/// Callback for app initialization after consent
typedef OnConsentAccepted = Future<void> Function(Locale locale, AppThemeMode theme);

/// Saves and loads the consent status
class PrivacyConsentPrefs {
  static const _k = 'privacy_consent_accepted';
  static const _versionKey = 'privacy_consent_version';

  /// Current version of the privacy policy
  /// Increment on changes to require re-consent
  static const int currentVersion = 1;

  static Future<bool> hasAccepted() async {
    final sp = await SharedPreferences.getInstance();
    final accepted = sp.getBool(_k) ?? false;
    final version = sp.getInt(_versionKey) ?? 0;
    // If version has changed, ask again
    return accepted && version >= currentVersion;
  }

  static Future<void> setAccepted(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_k, value);
    if (value) {
      await sp.setInt(_versionKey, currentVersion);
    }
  }
}

/// The Privacy Policy - UPDATE SIMPLY HERE
class PrivacyPolicyContent {
  // =====================================================
  // PRIVACY POLICY TEXTS
  // Update these texts when changes occur
  // =====================================================

  /// Short summary for the consent dialog
  static String getConsentSummary(AppLocalizations s) {
    return s.privacyConsentMessage;
  }

  /// Full privacy policy (Markdown-like)
  /// Displayed in the detail dialog
  static List<PrivacySection> getFullPolicy(AppLocalizations s) {
    return [
      PrivacySection(
        title: '1. Responsible Party',
        content: '''
Aldeeb Tech
Email: contact.aldeebtech@gmail.com
''',
      ),
      PrivacySection(
        title: '2. Collected Data',
        content: '''
We collect and process the following data:

• Email address (for authentication)
• Device information (IP address, device type)
• Usage data (app interactions)
• Uploaded content (product images, texts)
''',
      ),
      PrivacySection(
        title: '3. Third-Party Services',
        content: '''
This app uses the following services from Google/Firebase:

• Firebase Authentication - User login
• Firebase Firestore - Data storage
• Firebase Storage - Image storage
• Firebase Analytics - Usage statistics

These services process your IP address and
User ID according to the Google Privacy Policy:
https://policies.google.com/privacy
''',
      ),
      PrivacySection(
        title: '4. Purpose of Processing',
        content: '''
Your data is used for:

• Providing app features
• User authentication
• Storing your product data
• Improving app performance
''',
      ),
      PrivacySection(
        title: '5. Data Storage',
        content: '''
Your data is stored on servers in the EU/USA
(Google Cloud). The storage duration
depends on your usage relationship.

Upon account deletion, your data will be removed
within 30 days.
''',
      ),
      PrivacySection(
        title: '6. Your Rights',
        content: '''
You have the right to:

• Information about your stored data
• Correction of incorrect data
• Deletion of your data
• Data portability
• Revocation of consent

Contact us at:
contact.aldeebtech@gmail.com
''',
      ),
      PrivacySection(
        title: '7. Changes',
        content: '''
This privacy policy may be updated.
In case of significant changes, you will be asked
for consent again.

Status: January 2025
''',
      ),
    ];
  }
}

/// A section of the privacy policy
class PrivacySection {
  final String title;
  final String content;

  PrivacySection({required this.title, required this.content});
}

// =====================================================
// UI COMPONENTS
// =====================================================

/// Minimal app that only shows the consent dialog
class PrivacyConsentApp extends StatelessWidget {
  final Locale initialLocale;
  final AppThemeMode initialTheme;
  final OnConsentAccepted onAccepted;

  const PrivacyConsentApp({
    super.key,
    required this.initialLocale,
    required this.initialTheme,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Privacy Consent',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: initialTheme == AppThemeMode.system
          ? ThemeMode.system
          : (initialTheme == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light),
      locale: initialLocale,
      supportedLocales: AppConfig.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: PrivacyConsentScreen(
        initialLocale: initialLocale,
        initialTheme: initialTheme,
        onAccepted: onAccepted,
      ),
    );
  }
}

/// The Consent Screen
class PrivacyConsentScreen extends StatelessWidget {
  final Locale initialLocale;
  final AppThemeMode initialTheme;
  final OnConsentAccepted onAccepted;

  const PrivacyConsentScreen({
    super.key,
    required this.initialLocale,
    required this.initialTheme,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.privacy_tip_outlined, size: 40, color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                s.privacyConsentTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  PrivacyPolicyContent.getConsentSummary(s),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // Link to full privacy policy
              TextButton.icon(
                onPressed: () => _showFullPrivacyPolicy(context, s),
                icon: Icon(Icons.description_outlined, size: 18, color: colors.primary),
                label: Text(
                  s.privacyPolicyTitle,
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 8),

              // Firebase/Google Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_outlined, size: 16, color: colors.outline),
                  const SizedBox(width: 8),
                  Text(
                    'Firebase • Google Cloud',
                    style: TextStyle(fontSize: 12, color: colors.outline),
                  ),
                ],
              ),

              const Spacer(),

              // Accept Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await PrivacyConsentPrefs.setAccepted(true);
                    await onAccepted(initialLocale, initialTheme);
                  },
                  icon: const Icon(Icons.check),
                  label: Text(s.privacyAcceptButton),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Decline Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showDeclineDialog(context, s),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(s.privacyDeclineButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, AppLocalizations s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.privacyConsentTitle),
        content: Text(s.privacyDeclineMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.okButton),
          ),
        ],
      ),
    );
  }

  void _showFullPrivacyPolicy(BuildContext context, AppLocalizations s) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sections = PrivacyPolicyContent.getFullPolicy(s);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.policy_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    s.privacyPolicyTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          section.content.trim(),
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}