import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

// Services & Core
import 'services/api_service.dart';
import 'services/store_config_service.dart';
import 'services/version_service.dart';
import 'services/privacy_service.dart';
import 'core/paywall_messages.dart';
import 'core/access_manager.dart';
import 'firebase_options.dart';
import 'app_theme_mode.dart';
import 'theme.dart';
import 'config.dart'; // Wichtig für AppConfig.supportedLocales

// Screens (Alle Imports bleiben gleich...)
import 'screens/settings/settings_screen.dart';
import 'screens/home_shell.dart';
import 'screens/add_product.dart';
import 'screens/categories.dart';
import 'screens/products.dart';
import 'screens/customer_message.dart';
import 'screens/login.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/reset_password.dart';
import 'screens/verify_email.dart';
import 'screens/payment_screen.dart';
import 'screens/subscription_info.dart';

// Models
import 'models/product.dart';

// --- NEU: Helper für Sprache speichern ---
class LocalePrefs {
  static const _k = 'app_locale';
  static Future<Locale> load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_k);
    if (code == null) return const Locale('ar'); // Standard: Arabisch
    return Locale(code);
  }

  static Future<void> save(Locale locale) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, locale.languageCode);
  }
}

class ThemePrefs {
  static const _k = 'theme_mode';
  static Future<AppThemeMode> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_k) ?? 'system';
    return AppThemeMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AppThemeMode.system,
    );
  }

  static Future<void> save(AppThemeMode mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, mode.name);
  }
}

String? _sessionValidationResult;

class SessionMessageHelper {
  static String? _pendingMessage;
  static void setMessage(String msg) => _pendingMessage = msg;
  static String? consumeMessage() {
    final msg = _pendingMessage;
    _pendingMessage = null;
    return msg;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('cache');

  // Register third-party licenses (ExchangeRate-API for FX rates)
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['ExchangeRate-API'],
      '''Exchange rate data provided by ExchangeRate-API.

This application uses exchange rate data from:
https://www.exchangerate-api.com

Terms of Use: https://www.exchangerate-api.com/terms
Documentation: https://www.exchangerate-api.com/docs/free

The exchange rates are updated daily and are used for
currency conversion in subscription pricing.''',
    );
  });

  // Prüfe Privacy Consent BEVOR Firebase initialisiert wird
  final hasPrivacyConsent = await PrivacyConsentPrefs.hasAccepted();
  final savedLocale = await LocalePrefs.load();
  final savedTheme = await ThemePrefs.load();

  if (!hasPrivacyConsent) {
    // Zeige Consent-Dialog ohne Firebase
    runApp(
      PrivacyConsentApp(
        initialLocale: savedLocale,
        initialTheme: savedTheme,
        onAccepted: _initializeApp,
      ),
    );
    return;
  }

  // Normale App-Initialisierung mit Firebase
  await _initializeApp(savedLocale, savedTheme);
}

Future<void> _initializeApp(Locale savedLocale, AppThemeMode savedTheme) async {
  await TrialWelcomeManager.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialisiere VersionService
  await VersionService.init();

  // Firebase Auth Sprache setzen basierend auf gespeicherter Locale
  await FirebaseAuth.instance.setLanguageCode(savedLocale.languageCode);

  await ApiService.init();
  await AccessManager.loadFromCache();
  await ApiService.bootstrapAuth();
  _sessionValidationResult = await ApiService.validateSession();

  await StoreConfigService.load();

  runApp(
    MyApp(
      initialTheme: savedTheme,
      initialLocale: savedLocale,
      sessionResult: _sessionValidationResult,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppThemeMode initialTheme;
  final Locale initialLocale; // NEU
  final String? sessionResult;

  const MyApp({
    super.key,
    required this.initialTheme,
    required this.initialLocale, // NEU
    this.sessionResult,
  });

  // Router bleibt unverändert...
  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    refreshListenable: ApiService.authTick,
    redirect: (context, state) {
      // ... (Router Logik unverändert lassen) ...
      // Um Platz zu sparen, kopiere ich hier nicht den ganzen Router-Block erneut,
      // da er sich nicht geändert hat. Bitte den bestehenden Router-Code beibehalten.

      final uri = state.uri;
      if (uri.toString().startsWith('aldeebtech://')) {
        final success = uri.queryParameters['success'];
        return '/payment?success=$success';
      }
      if (ApiService.isProcessingAuth) return null;
      final loggedIn = ApiService.isLoggedIn;
      final emailVerified = ApiService.isEmailVerified;
      final hasStore = ApiService.hasStore;
      final hasPendingCredential = ApiService.hasPendingGoogleCredential;
      final isNewUser = ApiService.isCurrentUserNew;
      final loc = state.matchedLocation;

      if (!loggedIn) {
        if ([
          '/login',
          '/register',
          '/forgot-password',
          '/reset-password',
        ].contains(loc)) {
          return null;
        }
        return '/login';
      }
      if (!hasStore) {
        if (['/login', '/register'].contains(loc)) return null;
        if (hasPendingCredential || isNewUser) {
          if (loc != '/register') return '/register';
          return null;
        }
        return '/login';
      }
      if (!emailVerified &&
          loc != '/verify-email' &&
          loc != '/payment' &&
          loc != '/setup') {
        return '/verify-email';
      }
      final storeName =
          StoreConfigService.store?['store_name']?.toString().trim() ?? '';
      final setupCompleteFlag =
          StoreConfigService.store?['setup_complete'] == true;
      final bool setupComplete = storeName.isNotEmpty && setupCompleteFlag;

      if (!setupComplete) {
        if (['/setup', '/verify-email', '/payment'].contains(loc)) return null;
        return '/setup';
      }
      if (['/login', '/register', '/verify-email', '/setup'].contains(loc)) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, _) => '/home', // Leitet automatisch weiter
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SettingsScreen(firstSetup: true),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(firstSetup: false),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) =>
            AddProductScreen(productToEdit: state.extra as Product?),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/customer-message',
        builder: (context, state) => const CustomerMessageScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          username: (state.extra as Map?)?['username'] ?? '',
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => EmailVerifyScreen(
          storeId: ApiService.storeId ?? '',
          username: ApiService.currentUserEmail,
        ),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionInfoScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extras = state.extra as Map?;
          return PaymentScreen(
            initialPlanId:
                extras?['plan']?.toString() ??
                state.uri.queryParameters['plan'],
            returnUrl: extras?['returnUrl']?.toString() ?? '/home',
            paymentSuccess: state.uri.queryParameters['success'] == 'true',
          );
        },
      ),
    ],
  );

  @override
  State<MyApp> createState() => _MyAppState();

  // Statische Accessors für Child-Widgets
  static AppThemeMode? themeOf(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()?.mode;
  static Locale? localeOf(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()?._locale; // NEU

  static Future<void> setThemeOf(
    BuildContext context,
    AppThemeMode mode,
  ) async =>
      await context.findAncestorStateOfType<_MyAppState>()?.setTheme(mode);
  static Future<void> setLocaleOf(BuildContext context, Locale locale) async =>
      await context.findAncestorStateOfType<_MyAppState>()?.setLocale(
        locale,
      ); // NEU
}

class _MyAppState extends State<MyApp> {
  late AppThemeMode _mode;
  late Locale _locale; // NEU

  AppThemeMode get mode => _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialTheme;
    _locale = widget.initialLocale; // NEU

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final res = widget.sessionResult;
      // Hier nutzen wir noch statische Texte für Systemfehler, das ist okay
      if (res == 'expired') {
        SessionMessageHelper.setMessage(
          'انتهت مهلة تفعيل الحساب. يرجى التسجيل من جديد.',
        );
      }
      if (res == 'no_store') {
        SessionMessageHelper.setMessage(
          'الحساب غير مسجل. يرجى إنشاء متجر جديد.',
        );
      }
    });
  }

  Future<void> setTheme(AppThemeMode mode) async {
    setState(() => _mode = mode);
    await ThemePrefs.save(mode);
  }

  // NEU: Methode zum Ändern der Sprache
  Future<void> setLocale(Locale locale) async {
    setState(() => _locale = locale);
    await LocalePrefs.save(locale);
    // Firebase Auth E-Mail-Sprache aktualisieren
    await FirebaseAuth.instance.setLanguageCode(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Store Controller',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode == AppThemeMode.system
          ? ThemeMode.system
          : (_mode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light),

      locale: _locale, // HIER WIRD DIE SPRACHE GESETZT

      supportedLocales: AppConfig.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        // Directionality wird jetzt automatisch durch das Locale gesteuert
        return child!;
      },
      routerConfig: MyApp._router,
    );
  }
}
