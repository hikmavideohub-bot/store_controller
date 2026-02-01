import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import '../../../../main.dart'; // Für MyApp.setLocaleOf
import '../../../../app_theme_mode.dart';

class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Aktuelle Werte holen
    final currentTheme = MyApp.themeOf(context) ?? AppThemeMode.system;
    final currentLocale = MyApp.localeOf(context) ?? const Locale('ar');

    return Column(
      children: [
        // --- Theme Switcher ---
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.dark_mode_outlined, color: colors.primary),
          ),
          title: Text(
            s.drawerTheme,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<AppThemeMode>(
              value: currentTheme,
              borderRadius: BorderRadius.circular(12),
              items: [
                DropdownMenuItem(
                  value: AppThemeMode.system,
                  child: Text(s.themeSystem),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.light,
                  child: Text(s.themeLight),
                ),
                DropdownMenuItem(
                  value: AppThemeMode.dark,
                  child: Text(s.themeDark),
                ),
              ],
              onChanged: (val) {
                if (val != null) MyApp.setThemeOf(context, val);
              },
            ),
          ),
        ),

        const Divider(),

        // --- Language Switcher (NEU) ---
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.language, color: colors.secondary),
          ),
          title: Text(
            s.languageLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: _supportedLocale(currentLocale),
              borderRadius: BorderRadius.circular(12),
              items: [
                DropdownMenuItem(
                  value: const Locale('ar'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '🇸🇦 ',
                        style: TextStyle(fontSize: 16),
                      ), // Saudi-Arabien statt Syrien
                      Text('العربية'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🇺🇸 ', style: TextStyle(fontSize: 16)),
                      Text('English'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: const Locale('de'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🇩🇪 ', style: TextStyle(fontSize: 16)),
                      Text('Deutsch'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: const Locale('tr'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🇹🇷 ', style: TextStyle(fontSize: 16)),
                      Text('Türkçe'),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) MyApp.setLocaleOf(context, val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Hilfsmethode, falls das Locale Ländercodes hat (z.B. en_US), wir aber nur auf 'en' prüfen
  Locale _supportedLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const Locale('en');
      case 'de':
        return const Locale('de');
      case 'tr':
        return const Locale('tr');
      default:
        return const Locale('ar');
    }
  }
}
