import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/crop_category_provider.dart';
import 'config/theme_config.dart';

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

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({required this.themeProvider, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<FarmProvider>(create: (_) => FarmProvider()),
        ChangeNotifierProvider<CropProvider>(create: (_) => CropProvider()),
        ChangeNotifierProvider<CropCategoryProvider>(create: (_) => CropCategoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'GreenGrow ERP',
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: theme.themeMode,
            home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
