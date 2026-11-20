import 'package:flutter/material.dart';

/// AppThemeNotifier: Manages Light Mode and Dark Mode across the entire app.
class AppThemeNotifier extends ChangeNotifier {
  static final AppThemeNotifier instance = AppThemeNotifier._();
  AppThemeNotifier._();

  bool _isDark = false;
  bool get isDark => _isDark;

  void setDarkMode(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

/// Dynamic Color System
/// All getters automatically return the active light or dark color palette.
class AppColors {
  // Brand Accent: Warm Terracotta Sunset (tasteful 80% saturation, calm & editorial)
  static const Color accentCoral = Color(0xFFE04928);
  static const Color accentCoralHover = Color(0xFFC73D1E);
  static const Color accentCoralSubtle = Color(0x14E04928);

  // Status Colors (restrained, nature-inspired)
  static const Color statusLiveGreen = Color(0xFF059669);
  static const Color statusAmber = Color(0xFFD97706);
  static const Color statusBlue = Color(0xFF2563EB);

  static const Color textInverse = Color(0xFFFFFFFF);

  // Light Palette (Warm Editorial Paper)
  static const Color lightBgCanvas = Color(0xFFFAF9F6);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF3F1EC);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorderHairline = Color(0xFFEBE8E1);
  static const Color lightBorderStrong = Color(0xFFD6D2C8);
  static const Color lightTextPrimary = Color(0xFF141414);
  static const Color lightTextSecondary = Color(0xFF64635E);
  static const Color lightTextMuted = Color(0xFF9E9C95);
  static const Color lightButtonPrimary = Color(0xFF141414);
  static const Color lightButtonSecondary = Color(0xFFF3F1EC);

  // Dark Palette (Midnight Obsidian OLED)
  static const Color darkBgCanvas = Color(0xFF0F1117);
  static const Color darkSurfaceCard = Color(0xFF1A1D27);
  static const Color darkSurfaceSubtle = Color(0xFF242836);
  static const Color darkSurfaceElevated = Color(0xFF242836);
  static const Color darkBorderHairline = Color(0xFF2A2F40);
  static const Color darkBorderStrong = Color(0xFF3B4257);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkButtonPrimary = Color(0xFFF1F5F9);
  static const Color darkButtonSecondary = Color(0xFF242836);

  // Active Mode State
  static bool get isDark => AppThemeNotifier.instance.isDark;

  // Reactive Dynamic Color Getters
  static Color get bgCanvas => isDark ? darkBgCanvas : lightBgCanvas;
  static Color get surfaceCard => isDark ? darkSurfaceCard : lightSurfaceCard;
  static Color get surfaceSubtle => isDark ? darkSurfaceSubtle : lightSurfaceSubtle;
  static Color get surfaceElevated => isDark ? darkSurfaceElevated : lightSurfaceElevated;
  static Color get borderHairline => isDark ? darkBorderHairline : lightBorderHairline;
  static Color get borderStrong => isDark ? darkBorderStrong : lightBorderStrong;
  static Color get textPrimary => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => isDark ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => isDark ? darkTextMuted : lightTextMuted;
  static Color get buttonPrimary => isDark ? darkButtonPrimary : lightButtonPrimary;
  static Color get buttonSecondary => isDark ? darkButtonSecondary : lightButtonSecondary;
}
