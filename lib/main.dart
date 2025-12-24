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
import 'app_theme_mode.dart'; // ✅ Neuer Import
import './screens/customer_message.dart';
import 'screens/login.dart';



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

// ✅ _toThemeMode wurde in app_theme_mode.dart verschoben

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ StoreId / Basis-Init
  await ApiService.init();

  // ✅ AUTH beim App-Start laden (Token + Login-State)
  await ApiService.bootstrapAuth();

  // ✅ Theme laden
  final saved = await ThemePrefs.load();

  runApp(MyApp(initialTheme: saved));
}


class MyApp extends StatefulWidget {
  final AppThemeMode initialTheme;
  const MyApp({super.key, required this.initialTheme});

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',

    refreshListenable: ApiService.authTick, // ⭐ wichtig

    redirect: (context, state) {
      final loggedIn = ApiService.isLoggedIn;
      final loc = state.matchedLocation;

      final goingLogin = loc == '/login';
      final goingSetup = loc == '/setup';

      // 🔓 Nicht eingeloggt:
      // Erlaube /login und /setup
      if (!loggedIn) {
        if (goingLogin || goingSetup) return null;
        return '/login';
      }

      // 🔒 Eingeloggt:
      // Blockiere /login und /setup
      if (loggedIn && (goingLogin || goingSetup)) {
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


    ],
  );

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late AppThemeMode _mode = widget.initialTheme;

  AppThemeMode get mode => _mode;

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
      themeMode: toThemeMode(_mode), // ✅ Verwende die importierte Funktion

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