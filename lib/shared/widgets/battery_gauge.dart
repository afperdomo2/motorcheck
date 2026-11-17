import 'package:flutter/material.dart';

import '../../core/theme/app_radii.dart';

/// Batería de progreso usada para presupuestos. El relleno se colorea según el
/// estado y el porcentaje se muestra aparte con un `StatusChip`.
class BatteryGauge extends StatelessWidget {
  const BatteryGauge({
    super.key,
    required this.ratio,
    required this.color,
    this.height = 22,
  });

  final double ratio;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: height,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: AppRadii.smAll,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio.clamp(0.0, 1.0),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 4,
          height: height / 2.2,
          decoration: BoxDecoration(
            color: scheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

/// Barra lineal de presupuesto, para el resumen de Gastos.
class BudgetBar extends StatelessWidget {
  const BudgetBar({
    super.key,
    required this.ratio,
    required this.color,
    this.semanticsLabel,
    this.semanticsValue,
  });

  final double ratio;
  final Color color;
  final String? semanticsLabel;
  final String? semanticsValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: LinearProgressIndicator(
        value: ratio.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: scheme.surfaceContainer,
        color: color,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      ),
    );
  }
}
