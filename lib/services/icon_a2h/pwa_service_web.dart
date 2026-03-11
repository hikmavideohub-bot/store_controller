// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class PwaService {
  static final PwaService instance = PwaService._internal();
  PwaService._internal();

  final ValueNotifier<bool> canInstall = ValueNotifier(false);
  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    _checkPrompt();

    // Hört auf das JS-Event aus der index.html
    html.window.addEventListener('pwaPromptAvailable', (event) {
      _checkPrompt();
    });

    // Versteckt das Icon, wenn die App installiert wurde
    html.window.addEventListener('pwaInstalled', (event) {
      canInstall.value = false;
    });
  }

  void _checkPrompt() {
    try {
      final hasPrompt = js.context.callMethod('canPrompt') as bool;
      canInstall.value = hasPrompt;
    } catch (_) {}
  }

  void promptInstall() {
    try {
      js.context.callMethod('promptInstall');
    } catch (_) {}
  }
}