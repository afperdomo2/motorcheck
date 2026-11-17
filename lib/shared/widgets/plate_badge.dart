import 'package:flutter/material.dart';

import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';

/// Placa de vehículo en formato de insignia. Se usa en el carrusel, el mosaico
/// y la ficha del vehículo.
class PlateBadge extends StatelessWidget {
  const PlateBadge({super.key, required this.plate});

  final String? plate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.smAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        plate ?? 'Sin placa',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
