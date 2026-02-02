import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle get labelText => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.2,
      );

  static TextStyle get title => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.2,
      );

  static TextStyle get subtitle => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.25,
      );

  static TextStyle get body => const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.3,
      );

  static TextStyle get button => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.1,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  static TextStyle get overline => const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      );
}

class AppIconThemes {
  static IconThemeData get primary => const IconThemeData(
        size: 22,
        opacity: 1.0,
      );

  static IconThemeData get secondary => const IconThemeData(
        size: 18,
        opacity: 0.9,
      );

  static IconThemeData get small => const IconThemeData(
        size: 14,
        opacity: 1.0,
      );

  static IconThemeData get large => const IconThemeData(
        size: 56,
        opacity: 1.0,
      );
}

class AppTheme {
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 32),
      displayMedium: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 28),
      displaySmall: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 24),
      headlineLarge: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
      headlineMedium: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
      headlineSmall: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
      titleLarge: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: AppTextStyles.title.copyWith(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: AppTextStyles.body.copyWith(color: colorScheme.onSurface, fontSize: 16),
      bodyMedium: AppTextStyles.body.copyWith(color: colorScheme.onSurface, fontSize: 14),
      bodySmall: AppTextStyles.body.copyWith(color: colorScheme.onSurface, fontSize: 12),
      labelLarge: AppTextStyles.button.copyWith(color: colorScheme.onSurface),
      labelMedium: AppTextStyles.button.copyWith(color: colorScheme.onSurface),
      labelSmall: AppTextStyles.button.copyWith(color: colorScheme.onSurface),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: null,
      fontFamilyFallback: ['Microsoft YaHei', 'SimSun', 'PingFang SC', 'Noto Sans CJK SC', 'Source Han Sans SC'],
      textTheme: _buildTextTheme(colorScheme),
    );

    return baseTheme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: AppTextStyles.labelText.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: const OutlineInputBorder(),
      ),
      iconTheme: AppIconThemes.primary.copyWith(color: colorScheme.onSurface),
      primaryIconTheme: AppIconThemes.primary.copyWith(color: colorScheme.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.button,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: AppTextStyles.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: null,
      fontFamilyFallback: ['Microsoft YaHei', 'SimSun', 'PingFang SC', 'Noto Sans CJK SC', 'Source Han Sans SC'],
      textTheme: _buildTextTheme(colorScheme),
    );

    // Make the dark theme background slightly lighter than pure black and
    // unify icon colors so playback/playlist icons render consistently.
    final adjustedScheme = colorScheme.copyWith(
      background: const Color(0xFF0B1220),
      surface: const Color(0xFF0F1620),
      surfaceVariant: const Color(0xFF1F2732),
    );

    final adjustedBase = baseTheme.copyWith(
      colorScheme: adjustedScheme,
      scaffoldBackgroundColor: adjustedScheme.background,
      canvasColor: adjustedScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: AppTextStyles.labelText.copyWith(
          color: adjustedScheme.onSurfaceVariant,
        ),
        border: const OutlineInputBorder(),
      ),
      iconTheme: AppIconThemes.primary.copyWith(color: adjustedScheme.onSurfaceVariant),
      primaryIconTheme: AppIconThemes.primary.copyWith(color: adjustedScheme.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: adjustedScheme.surface,
        foregroundColor: adjustedScheme.onSurface,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: adjustedScheme.surface,
        selectedItemColor: adjustedScheme.primary,
        unselectedItemColor: adjustedScheme.onSurfaceVariant,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.button,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: AppTextStyles.button,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppTextStyles.button,
        ),
      ),
    );

    return adjustedBase;
  }
}

