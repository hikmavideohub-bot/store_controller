import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'services/api_service.dart';
import 'screens/settings.dart';
import 'screens/home_shell.dart';
import 'models/product.dart';
import 'screens/add_product.dart';
import 'theme.dart';
import 'screens/categories.dart';
import 'screens/products.dart';
import 'app_theme_mode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/customer_message.dart';
import 'screens/login.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/reset_password.dart';
import 'screens/verify_email.dart';
import 'screens/payment_screen.dart'; // NEU: Payment Screen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/paywall_messages.dart';
import 'core/access_manager.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1. Hive ZUERST initialisieren (wird von CacheStore benötigt)
  await Hive.initFlutter();
  await Hive.openBox('cache');

  // ✅ 2. TrialWelcomeManager laden
  await TrialWelcomeManager.load();

  // ✅ 3. Firebase initialisieren
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ 4. ApiService + Access initialisieren
  await ApiService.init();
  await AccessManager.loadFromCache();

  // ✅ 5. Auth-State beim App-Start laden
  await ApiService.bootstrapAuth();

  // ✅ 6. Theme laden
  final saved = await ThemePrefs.load();

  runApp(MyApp(initialTheme: saved));
}

class MyApp extends StatefulWidget {
  final AppThemeMode initialTheme;
  const MyApp({super.key, required this.initialTheme});


  // -------------------------
  // ✅ Router mit Payment-Route
  // -------------------------
  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    refreshListenable: ApiService.authTick,

    redirect: (context, state) {
      final loggedIn = ApiService.isLoggedIn;
      final emailVerified = ApiService.isEmailVerified;

      final storeId = (ApiService.storeId ?? '').trim();
      final hasStore = storeId.isNotEmpty;

      final loc = state.matchedLocation;

      bool isAt(String p) => loc == p;

      final goingLogin    = isAt('/login');
      final goingSetup    = isAt('/setup');
      final goingVerify   = isAt('/verify-email');
      final goingForgot   = isAt('/forgot-password');
      final goingReset    = isAt('/reset-password');
      final goingRegister = isAt('/register');
      final goingPayment  = isAt('/payment');

      // -------------------------
      // 1) 🔴 NOT logged in
      // -------------------------
      if (!loggedIn) {
        // Allow public routes:
        // - login/register/forgot/reset/setup immer
        // - verify-email nur, wenn wir einen storeId haben (Option A)
        if (goingLogin || goingRegister || goingForgot || goingReset || goingSetup) return null;
        if (goingVerify && hasStore) return null;

        // Optional: Wenn wir einen Store haben und Email nicht verified, direkt zu verify
        if (hasStore && !emailVerified) return '/verify-email';

        return '/login';
      }

      // -------------------------
      // 2) 🟠 Logged in, but email NOT verified
      // -------------------------
      if (!emailVerified) {
        // allow verify + forgot/reset + payment
        if (goingVerify || goingForgot || goingReset || goingPayment) return null;
        return '/verify-email';
      }

      // -------------------------
      // 3) 🟢 Logged in + email verified
      // -------------------------
      // block auth screens
      if (goingLogin || goingRegister || goingVerify) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShell(),
      ),

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
        builder: (context, state) {
          final Product? productToEdit = state.extra as Product?;
          return AddProductScreen(productToEdit: productToEdit);
        },
      ),

      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/customer-message',
        builder: (context, state) => const CustomerMessageScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra;
          String username = '';

          if (extra is Map) {
            username = (extra['username'] ?? '').toString();
          }

          return ResetPasswordScreen(username: username);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final extra = state.extra;

          String storeId = '';
          String username = '';

          if (extra is Map) {
            storeId = (extra['storeId'] ?? '').toString().trim();
            username = (extra['username'] ?? '').toString().trim();
          }

          // fallback: redirect kann ohne extra kommen
          if (storeId.isEmpty) {
            storeId = (ApiService.storeId ?? '').trim();
          }

          return EmailVerifyScreen(
            storeId: storeId,
            username: username.isEmpty ? null : username,
          );
        },
      ),

      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra;

          String plan = 'premium_monthly';
          String returnUrl = '/home';

          if (extra is Map) {
            plan = (extra['plan'] ?? plan).toString();
            returnUrl = (extra['returnUrl'] ?? returnUrl).toString();
          }

          return PaymentScreen(plan: plan, returnUrl: returnUrl);
        },
      ),
    ],
  );


  @override
  State<MyApp> createState() => _MyAppState();


  /// Theme lesen (optional)
  static AppThemeMode? themeOf(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()?.mode;

  /// Theme setzen (von überall in der App)
  static Future<void> setThemeOf(BuildContext context, AppThemeMode mode) async {
    final state = context.findAncestorStateOfType<_MyAppState>();
    if (state == null) return;
    await state.setTheme(mode);
  }
}

class _MyAppState extends State<MyApp> {
  late AppThemeMode _mode;

  AppThemeMode get mode => _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialTheme;
  }

  Future<void> setTheme(AppThemeMode mode) async {
    setState(() => _mode = mode);
    await ThemePrefs.save(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'إدارة المنتجات',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: toThemeMode(_mode),

      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final decoration = isDark
            ? const BoxDecoration(gradient: AppConfig.appGradient)
            : const BoxDecoration(color: Color(0xFFF6F5F2));

        return Directionality(
          textDirection: AppConfig.textDirection,
          child: Container(
            decoration: decoration,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },

      routerConfig: MyApp._router,
    );
  }

}

class LocalePrefs {
  static const _k = 'app_locale';

  static Future<Locale?> load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_k);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  static Future<void> save(Locale locale) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, locale.languageCode);
  }
}