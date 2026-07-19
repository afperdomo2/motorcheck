import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _base = TextStyle(
    fontFamily: 'Roboto',
    color: AppColors.onSurface,
  );

  static TextStyle get headlineLarge =>
      _base.copyWith(fontSize: 32, fontWeight: FontWeight.w600);

  static TextStyle get headlineMedium =>
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w600);

  static TextStyle get titleLarge =>
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w500);

  static TextStyle get titleMedium =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get bodyLarge =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle get bodyMedium => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get labelLarge =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  static TextStyle get labelMedium =>
      _base.copyWith(fontSize: 12, fontWeight: FontWeight.w500);
}
