import 'package:flutter/material.dart';

/// Escala tipográfica Material 3 con la familia Barlow.
class AppTextStyles {
  AppTextStyles._();

  static const _bodyFamily = 'Barlow';
  static const _displayFamily = 'BarlowSemiCondensed';
  static const _fallback = <String>['Roboto', 'sans-serif'];

  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return TextTheme(
      displayLarge: _display(
        fontSize: 57,
        height: 64,
        weight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.5,
      ),
      displayMedium: _display(
        fontSize: 45,
        height: 52,
        weight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.4,
      ),
      displaySmall: _display(
        fontSize: 36,
        height: 44,
        weight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.3,
      ),
      headlineLarge: _display(
        fontSize: 32,
        height: 40,
        weight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.2,
      ),
      headlineMedium: _display(
        fontSize: 28,
        height: 36,
        weight: FontWeight.w600,
        color: onSurface,
        letterSpacing: -0.2,
      ),
      headlineSmall: _display(
        fontSize: 24,
        height: 32,
        weight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: _display(
        fontSize: 22,
        height: 28,
        weight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: _display(
        fontSize: 16,
        height: 24,
        weight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: _display(
        fontSize: 14,
        height: 20,
        weight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: _body(
        fontSize: 16,
        height: 24,
        weight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: _body(
        fontSize: 14,
        height: 20,
        weight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      bodySmall: _body(
        fontSize: 12,
        height: 16,
        weight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      labelLarge: _body(
        fontSize: 14,
        height: 20,
        weight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: _body(
        fontSize: 12,
        height: 16,
        weight: FontWeight.w600,
        color: onSurfaceVariant,
        letterSpacing: 0.1,
      ),
      labelSmall: _body(
        fontSize: 11,
        height: 16,
        weight: FontWeight.w600,
        color: onSurfaceVariant,
        letterSpacing: 0.2,
      ),
    );
  }

  static TextStyle _display({
    required double fontSize,
    required double height,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _fallback,
      fontSize: fontSize,
      height: height / fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _body({
    required double fontSize,
    required double height,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _bodyFamily,
      fontFamilyFallback: _fallback,
      fontSize: fontSize,
      height: height / fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
