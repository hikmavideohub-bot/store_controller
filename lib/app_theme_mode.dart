// lib/app_theme_mode.dart
import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

ThemeMode toThemeMode(AppThemeMode m) {
  switch (m) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
}