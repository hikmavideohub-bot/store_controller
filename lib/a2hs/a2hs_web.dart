import 'dart:html' as html;
import 'package:flutter/material.dart';

class A2HSImpl {
  static const _flagKey = 'a2hs_shown_v1';

  static bool get _isIOS {
    final ua = html.window.navigator.userAgent;
    return ua.contains('iPhone') || ua.contains('iPad') || ua.contains('iPod');
  }

  static bool get _isStandalone {
    final mql = html.window.matchMedia('(display-mode: standalone)');
    final displayModeStandalone = mql.matches;

    // iOS Safari: navigator.standalone
    final nav = html.window.navigator as dynamic;
    final iosStandalone = (nav.standalone == true);

    return displayModeStandalone || iosStandalone;
  }

  static bool get _alreadyShown => html.window.localStorage[_flagKey] == '1';
  static void _markShown() => html.window.localStorage[_flagKey] = '1';

  static Future<void> maybeShow(BuildContext context) async {
    if (!_isIOS) return;
    if (_isStandalone) return;
    if (_alreadyShown) return;

    _markShown(); // sofort setzen, damit es nicht doppelt kommt

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Zum Home-Bildschirm hinzufügen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              '1) Tippe unten auf Teilen (⤴︎)\n'
                  '2) Wähle „Zum Home-Bildschirm“\n'
                  '3) Tippe „Hinzufügen“',
            ),
            SizedBox(height: 12),
            Text('Tipp: Falls die Option fehlt, öffne die Seite direkt in Safari.'),
          ],
        ),
      ),
    );
  }
}
