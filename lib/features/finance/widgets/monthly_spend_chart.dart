import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers.dart';

class MonthlySpendChart extends StatelessWidget {
  const MonthlySpendChart({super.key, required this.points});

  final List<MonthlyFinancePoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxValue = points
        .expand((point) => [point.maintenance, point.fuel, point.expenses])
        .fold<double>(0, (max, value) => value > max ? value : max);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final monthFormat = DateFormat('MMM', 'es_CO');
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final scaleFactor = (textScale - 1).clamp(0.0, 2.0).toDouble();
    final chartHeight = 150.0 + scaleFactor * 60.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Últimos 6 meses',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _MonthBars(
                              point: point,
                              maxValue: safeMax,
                              maintenanceColor: scheme.primary,
                              fuelColor: scheme.tertiary,
                              expensesColor: scheme.secondary,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              monthFormat.format(point.month),
                              style: theme.textTheme.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                _Legend(color: scheme.primary, label: 'Mantenimiento'),
                _Legend(color: scheme.tertiary, label: 'Combustible'),
                _Legend(color: scheme.secondary, label: 'Gastos'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthBars extends StatelessWidget {
  const _MonthBars({
    required this.point,
    required this.maxValue,
    required this.maintenanceColor,
    required this.fuelColor,
    required this.expensesColor,
  });

  final MonthlyFinancePoint point;
  final double maxValue;
  final Color maintenanceColor;
  final Color fuelColor;
  final Color expensesColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Bar(
            value: point.maintenance,
            maxValue: maxValue,
            color: maintenanceColor,
          ),
          const SizedBox(width: 2),
          _Bar(value: point.fuel, maxValue: maxValue, color: fuelColor),
          const SizedBox(width: 2),
          _Bar(value: point.expenses, maxValue: maxValue, color: expensesColor),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final height = (value / maxValue * 100).clamp(2.0, 100.0);
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: value > 0 ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
