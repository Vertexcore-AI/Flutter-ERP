import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/login_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/crop_category_provider.dart';
import 'providers/crop_cycle_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/task_provider.dart';
import 'providers/buyer_provider.dart';
import 'config/theme_config.dart';
import 'services/deep_link_service.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initTheme();

  // Initialize deep link service
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();

  runApp(MyApp(
    themeProvider: themeProvider,
    deepLinkService: deepLinkService,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final DeepLinkService deepLinkService;

  const MyApp({
    required this.themeProvider,
    required this.deepLinkService,
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupDeepLinking();

    // Set navigator key for ApiClient (for auto-logout on 401)
    ApiClient.navigatorKey = _navigatorKey;
  }

  void _setupDeepLinking() {
    // Handle warm start (app already running)
    widget.deepLinkService.setNavigationCallback(_handleVerificationLink);

    // Handle cold start (app opened from link)
    widget.deepLinkService.getInitialLink().then((uri) {
      if (uri != null) {
        final path = uri.path;
        if (path == '/govi_potha/verify-email' || path.endsWith('/verify-email')) {
          final token = uri.queryParameters['token'];
          if (token != null) {
            // Delay navigation until MaterialApp builds
            Future.delayed(const Duration(milliseconds: 500), () {
              _handleVerificationLink(token);
            });
          }
        }
      }
    });
  }

  void _handleVerificationLink(String token) {
    debugPrint('📧 Navigating to verification with token');
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => EmailVerificationScreen(token: token),
      ),
    );
  }

  @override
  void dispose() {
    widget.deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => widget.themeProvider),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<FarmProvider>(create: (_) => FarmProvider()),
        ChangeNotifierProvider<CropProvider>(create: (_) => CropProvider()),
        ChangeNotifierProvider<CropCategoryProvider>(create: (_) => CropCategoryProvider()),
        ChangeNotifierProvider<CropCycleProvider>(create: (_) => CropCycleProvider()),
        ChangeNotifierProvider<InventoryProvider>(create: (_) => InventoryProvider()),
        ChangeNotifierProvider<TaskProvider>(create: (_) => TaskProvider()),
        ChangeNotifierProvider<BuyerProvider>(create: (_) => BuyerProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'GreenGrow ERP',
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: theme.themeMode,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
