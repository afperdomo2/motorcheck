import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import 'tonal_avatar.dart';

/// Fila icono + etiqueta + monto. Se usa en el gasto de la flota y en el
/// resumen financiero del vehículo.
class MoneyRow extends StatelessWidget {
  const MoneyRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.xs),
  });

  final IconData icon;
  final String label;
  final double value;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          TonalAvatar(icon: icon, size: 28, iconSize: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                formatCurrency(value),
                maxLines: 1,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
