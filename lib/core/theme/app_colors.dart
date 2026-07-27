import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF3B82F6);
  static const primaryVariant = Color(0xFF2563EB);
  static const secondary = Color(0xFF8B5CF6);
  static const secondaryVariant = Color(0xFF7C3AED);

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF1E293B);
  static const lightOnSurfaceVariant = Color(0xFF64748B);
  static const lightOutline = Color(0xFFCBD5E1);
  static const lightOutlineVariant = Color(0xFFE2E8F0);

  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkOnSurface = Color(0xFFF1F5F9);
  static const darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const darkOutline = Color(0xFF475569);
  static const darkOutlineVariant = Color(0xFF334155);

  static const error = Color(0xFFEF4444);

  static const car = Color(0xFF3B82F6);
  static const motorcycle = Color(0xFF8B5CF6);
  static const bike = Color(0xFF10B981);
  static const truck = Color(0xFFF59E0B);
  static const other = Color(0xFF64748B);
  static const otherDark = Color(0xFF94A3B8);

  static const background = lightBackground;
  static const surface = lightSurface;
  static const onSurface = lightOnSurface;
  static const onSurfaceVariant = lightOnSurfaceVariant;
  static const outline = lightOutline;
  static const outlineVariant = lightOutlineVariant;

  static Color forVehicleType(String type, {bool isDark = false}) {
    return switch (type) {
      'car' => car,
      'motorcycle' => motorcycle,
      'bike' => bike,
      'truck' => truck,
      _ => isDark ? otherDark : other,
    };
  }
}
