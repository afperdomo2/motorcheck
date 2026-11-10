import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/theme/app_colors.dart';
import 'package:motorcheck/core/theme/app_semantic_colors.dart';
import 'package:motorcheck/core/theme/app_theme.dart';

double _channel(double value) => value <= 0.03928
    ? value / 12.92
    : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color color) =>
    0.2126 * _channel(color.r) +
    0.7152 * _channel(color.g) +
    0.0722 * _channel(color.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const semanticLight = AppSemanticColors.light;
  const semanticDark = AppSemanticColors.dark;

  group('contraste de texto', () {
    final pairs = <String, (Color, Color)>{
      'onSurface / background': (AppColors.ink, AppColors.warmBackground),
      'onSurfaceVariant / surface': (
        AppColors.onSurfaceVariantLight,
        AppColors.surfaceLight,
      ),
      'white / amber': (Colors.white, AppColors.amber),
      'graphite / amber bright': (AppColors.graphite, AppColors.amberBright),
      'dark onSurface / dark bg': (
        AppColors.onSurfaceDark,
        AppColors.backgroundDark,
      ),
      'dark onSurfaceVariant / dark surface': (
        AppColors.onSurfaceVariantDark,
        AppColors.surfaceDark,
      ),
      'success text / white': (semanticLight.success, Colors.white),
      'warning text / white': (semanticLight.warning, Colors.white),
      'danger text / white': (semanticLight.danger, Colors.white),
      'success on container': (
        semanticLight.onSuccessContainer,
        semanticLight.successContainer,
      ),
      'warning on container': (
        semanticLight.onWarningContainer,
        semanticLight.warningContainer,
      ),
      'danger on container': (
        semanticLight.onDangerContainer,
        semanticLight.dangerContainer,
      ),
      'dark success on container': (
        semanticDark.onSuccessContainer,
        semanticDark.successContainer,
      ),
      'dark warning on container': (
        semanticDark.onWarningContainer,
        semanticDark.warningContainer,
      ),
      'dark danger on container': (
        semanticDark.onDangerContainer,
        semanticDark.dangerContainer,
      ),
    };

    for (final entry in pairs.entries) {
      test('${entry.key} cumple AA', () {
        expect(
          _contrast(entry.value.$1, entry.value.$2),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  });

  group('contraste de componentes', () {
    test('outline claro sobre fondo', () {
      expect(
        _contrast(AppColors.outlineLight, AppColors.warmBackground),
        greaterThanOrEqualTo(3),
      );
    });

    test('outline oscuro sobre superficie', () {
      expect(
        _contrast(AppColors.outlineDark, AppColors.surfaceDark),
        greaterThanOrEqualTo(3),
      );
    });
  });

  group('tema', () {
    test('la navegación siempre muestra etiquetas', () {
      expect(
        AppTheme.light.navigationBarTheme.labelBehavior,
        NavigationDestinationLabelBehavior.alwaysShow,
      );
    });

    test('usa Barlow como familia principal', () {
      expect(AppTheme.light.textTheme.bodyLarge?.fontFamily, 'Barlow');
      expect(
        AppTheme.light.textTheme.headlineMedium?.fontFamily,
        'BarlowSemiCondensed',
      );
    });
  });
}
