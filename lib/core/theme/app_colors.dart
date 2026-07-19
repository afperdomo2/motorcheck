import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF2563EB);
  static const primaryVariant = Color(0xFF1D4ED8);
  static const secondary = Color(0xFF7C3AED);
  static const secondaryVariant = Color(0xFF6D28D9);

  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1E293B);
  static const onSurfaceVariant = Color(0xFF64748B);
  static const outline = Color(0xFFCBD5E1);
  static const error = Color(0xFFDC2626);

  static const car = Color(0xFF2563EB);
  static const motorcycle = Color(0xFF7C3AED);
  static const bike = Color(0xFF059669);
  static const truck = Color(0xFFD97706);
  static const other = Color(0xFF64748B);

  static Color forVehicleType(String type) {
    return switch (type) {
      'car' => car,
      'motorcycle' => motorcycle,
      'bike' => bike,
      'truck' => truck,
      _ => other,
    };
  }
}
