import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bgCanvas,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GoPlacesApp());
}

class GoPlacesApp extends StatelessWidget {
  const GoPlacesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeNotifier.instance,
      builder: (context, _) {
        final isDark = AppColors.isDark;

        return MaterialApp(
          key: ValueKey(isDark),
          title: 'Go places',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: AppColors.bgCanvas,
            primaryColor: AppColors.accentCoral,
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: AppColors.accentCoral,
              onPrimary: Colors.white,
              secondary: AppColors.textPrimary,
              onSecondary: AppColors.textInverse,
              error: Colors.red,
              onError: Colors.white,
              surface: AppColors.surfaceCard,
              onSurface: AppColors.textPrimary,
            ),
            useMaterial3: true,
          ),
          home: const OnboardingScreen(),
        );
      },
    );
  }
}
