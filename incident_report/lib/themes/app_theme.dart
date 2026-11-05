import 'package:flutter/material.dart';

/// 1. Create a quick-access extension for clean syntax in your widgets
extension AppThemeX on ThemeData {
  AppColors get appColors => extension<AppColors>()!;
}

/// 2. Define the Custom Theme Extension adhering to the 60:30:10 Color Rule for high contrast and visibility
class AppColors extends ThemeExtension<AppColors> {
  final Map<int, Color> text;
  final Map<int, Color> background;
  final Map<int, Color> primary;
  final Map<int, Color> secondary;
  final Map<int, Color> accent;

  const AppColors({
    required this.text,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  // Light Theme Color Map (60% Dominant clean background, 30% Secondary crisp white cards & dark slate text, 10% Accent brand purple)
  static const lightColors = AppColors(
    text: {
      50: Color(0xFFF8FAFC), 100: Color(0xFFF1F5F9), 200: Color(0xFFE2E8F0),
      300: Color(0xFFCBD5E1), 400: Color(0xFF94A3B8), 500: Color(0xFF64748B),
      600: Color(0xFF475569), 700: Color(0xFF334155), 800: Color(0xFF1E293B),
      900: Color(0xFF0F172A), 950: Color(0xFF020617),
    },
    background: {
      50: Color(0xFFF8FAFC),  // 60% Dominant Canvas
      100: Color(0xFFFFFFFF), // 30% Secondary Card Surface
      200: Color(0xFFF1F5F9),
      300: Color(0xFFE2E8F0), // Card borders
      400: Color(0xFFCBD5E1),
      500: Color(0xFF94A3B8),
      600: Color(0xFF64748B),
      700: Color(0xFF334155),
      800: Color(0xFF1E293B),
      900: Color(0xFF0F172A),
      950: Color(0xFF020617),
    },
    primary: {
      50: Color(0xFFEEF2FF), 100: Color(0xFFE0E7FF), 200: Color(0xFFC7D2FE),
      300: Color(0xFFA5B4FC), 400: Color(0xFF818CF8), 500: Color(0xFF4C36C9), // 10% Accent Brand
      600: Color(0xFF4338CA), 700: Color(0xFF3730A3), 800: Color(0xFF312E81),
      900: Color(0xFF1E1B4B), 950: Color(0xFF0F172A),
    },
    secondary: {
      50: Color(0xFFF0FDFA), 100: Color(0xFFCCFBF1), 200: Color(0xFF99F6E4),
      300: Color(0xFF5EEAD4), 400: Color(0xFF2DD4BF), 500: Color(0xFF14B8A6),
      600: Color(0xFF0D9488), 700: Color(0xFF0F766E), 800: Color(0xFF115E59),
      900: Color(0xFF134E4A), 950: Color(0xFF042F2E),
    },
    accent: {
      50: Color(0xFFFAF5FF), 100: Color(0xFFF3E8FF), 200: Color(0xFFE9D5FF),
      300: Color(0xFFD8B4FE), 400: Color(0xFFC084FC), 500: Color(0xFF4025DA),
      600: Color(0xFF9333EA), 700: Color(0xFF7E22CE), 800: Color(0xFF6B21A8),
      900: Color(0xFF581C87), 950: Color(0xFF3B0764),
    },
  );

  // Dark Theme Color Map
  static const darkColors = AppColors(
    text: {
      50: Color(0xFF090712), 100: Color(0xFF120E25), 200: Color(0xFF251D49),
      300: Color(0xFF372B6E), 400: Color(0xFF4A3993), 500: Color(0xFF5C47B8),
      600: Color(0xFF7D6CC6), 700: Color(0xFF9D91D4), 800: Color(0xFFBEB6E2),
      900: Color(0xFFDEDAF1), 950: Color(0xFFEFEDF8),
    },
    background: {
      50: Color(0xFF050514), 100: Color(0xFF0A0A29), 200: Color(0xFF141452),
      300: Color(0xFF1F1F7A), 400: Color(0xFF2929A3), 500: Color(0xFF3333CC),
      600: Color(0xFF5C5CD6), 700: Color(0xFF8585E0), 800: Color(0xFFADADEB),
      900: Color(0xFFD6D6F5), 950: Color(0xFFEBEBFA),
    },
    primary: {
      50: Color(0xFF080514), 100: Color(0xFF0F0B28), 200: Color(0xFF1E1551),
      300: Color(0xFF2D2079), 400: Color(0xFF3D2BA1), 500: Color(0xFF4C36C9),
      600: Color(0xFF705ED4), 700: Color(0xFF9386DF), 800: Color(0xFFB7AEEA),
      900: Color(0xFFDBD7F4), 950: Color(0xFFEDEBFA),
    },
    secondary: {
      50: Color(0xFF070515), 100: Color(0xFF0E092A), 200: Color(0xFF1C1254),
      300: Color(0xFF2A1C7D), 400: Color(0xFF3825A7), 500: Color(0xFF462ED1),
      600: Color(0xFF6B58DA), 700: Color(0xFF9082E3), 800: Color(0xFFB5ABED),
      900: Color(0xFFDAD5F6), 950: Color(0xFFEDEAEA),
    },
    accent: {
      50: Color(0xFF060416), 100: Color(0xFF0D072C), 200: Color(0xFF1A0F57),
      300: Color(0xFF261683), 400: Color(0xFF331EAE), 500: Color(0xFF4025DA),
      600: Color(0xFF6651E1), 700: Color(0xFF8C7CE9), 800: Color(0xFFB3A8F0),
      900: Color(0xFFD9D3F8), 950: Color(0xFFECE9FB),
    },
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Map<int, Color>? text,
    Map<int, Color>? background,
    Map<int, Color>? primary,
    Map<int, Color>? secondary,
    Map<int, Color>? accent,
  }) {
    return AppColors(
      text: text ?? this.text,
      background: background ?? this.background,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      text: _lerpMap(text, other.text, t),
      background: _lerpMap(background, other.background, t),
      primary: _lerpMap(primary, other.primary, t),
      secondary: _lerpMap(secondary, other.secondary, t),
      accent: _lerpMap(accent, other.accent, t),
    );
  }

  Map<int, Color> _lerpMap(Map<int, Color> a, Map<int, Color> b, double t) {
    return a.map((key, value) => MapEntry(key, Color.lerp(value, b[key], t)!));
  }
}

/// 3. Define the actual ThemeData configurations for your MaterialApp
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightColors.background[50],
      extensions: const [AppColors.lightColors],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkColors.background[50],
      extensions: const [AppColors.darkColors],
    );
  }
}
