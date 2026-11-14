import 'package:flutter/material.dart';

/// Paleta cruda de MotorCheck.
///
/// Ningún widget debe consumir estos valores directamente: usa
/// [ColorScheme] o [AppSemanticColors] desde el tema.
class AppColors {
  AppColors._();

  // Grafito y superficies claras.
  static const graphite = Color(0xFF1F2328);
  static const ink = Color(0xFF1B1D21);
  static const warmBackground = Color(0xFFF5F4F1);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceContainerLowLight = Color(0xFFF0EEE9);
  static const surfaceContainerLight = Color(0xFFEAE7E0);
  static const surfaceContainerHighLight = Color(0xFFE2DED5);
  static const onSurfaceVariantLight = Color(0xFF5A5F66);
  static const outlineLight = Color(0xFF7F848B);
  static const outlineVariantLight = Color(0xFFD8D4CC);

  // Superficies oscuras.
  static const backgroundDark = Color(0xFF121417);
  static const surfaceDark = Color(0xFF1A1D21);
  static const surfaceContainerLowDark = Color(0xFF1E2227);
  static const surfaceContainerDark = Color(0xFF22262B);
  static const surfaceContainerHighDark = Color(0xFF2A2F35);
  static const onSurfaceDark = Color(0xFFE8E6E1);
  static const onSurfaceVariantDark = Color(0xFFA6A9AE);
  static const outlineDark = Color(0xFF6B7077);
  static const outlineVariantDark = Color(0xFF343941);

  // Señal ámbar.
  static const amber = Color(0xFFB45309);
  static const amberInk = Color(0xFF92400E);
  static const amberBright = Color(0xFFFBBF24);
  static const amberContainer = Color(0xFFFDE68A);
  static const amberContainerDark = Color(0xFF3A2A08);

  // Estados semánticos.
  static const successLight = Color(0xFF047857);
  static const successContainerLight = Color(0xFFD1FAE5);
  static const onSuccessContainerLight = Color(0xFF064E3B);
  static const successDark = Color(0xFF34D399);
  static const successContainerDark = Color(0xFF064E3B);
  static const onSuccessContainerDark = Color(0xFFA7F3D0);

  static const warningLight = Color(0xFFB45309);
  static const warningContainerLight = Color(0xFFFDE68A);
  static const onWarningContainerLight = Color(0xFF92400E);
  static const warningDark = Color(0xFFFBBF24);
  static const warningContainerDark = Color(0xFF4A3208);
  static const onWarningContainerDark = Color(0xFFFDE68A);

  static const dangerLight = Color(0xFFB91C1C);
  static const dangerContainerLight = Color(0xFFFEE2E2);
  static const onDangerContainerLight = Color(0xFF7F1D1D);
  static const dangerDark = Color(0xFFF87171);
  static const dangerContainerDark = Color(0xFF5C1A1A);
  static const onDangerContainerDark = Color(0xFFFECACA);

  // Identidad por tipo de vehículo.
  static const carLight = Color(0xFF1D4ED8);
  static const motorcycleLight = Color(0xFF6D28D9);
  static const bikeLight = Color(0xFF047857);
  static const truckLight = Color(0xFF0E7490);
  static const scooterLight = Color(0xFFBE185D);
  static const otherLight = Color(0xFF475569);

  static const carDark = Color(0xFF93B4FF);
  static const motorcycleDark = Color(0xFFC4B5FD);
  static const bikeDark = Color(0xFF6EE7B7);
  static const truckDark = Color(0xFF67E8F9);
  static const scooterDark = Color(0xFFF9A8D4);
  static const otherDark = Color(0xFFCBD5E1);
}
