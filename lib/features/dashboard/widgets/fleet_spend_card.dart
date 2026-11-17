import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/money_row.dart';
import '../../finance/providers.dart';

/// Gasto del mes sumando todos los vehículos y los gastos globales.
class FleetSpendCard extends ConsumerWidget {
  const FleetSpendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final breakdownAsync = ref.watch(fleetMonthBreakdownProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gasto de ${formatMonthYear(DateTime.now())}',
                style: theme.textTheme.titleMedium,
              ),
              Text('Todos los vehículos', style: theme.textTheme.bodySmall),
              breakdownAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.lg),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) => _Error(
                  onRetry: () => ref.invalidate(fleetMonthBreakdownProvider),
                ),
                data: (breakdown) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCurrency(breakdown.total),
                        maxLines: 1,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    MoneyRow(
                      icon: Icons.build_outlined,
                      label: 'Mantenimiento',
                      value: breakdown.maintenance,
                    ),
                    MoneyRow(
                      icon: Icons.local_gas_station_outlined,
                      label: 'Combustible',
                      value: breakdown.fuel,
                    ),
                    MoneyRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'Otros',
                      value: breakdown.expenses,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'No se pudo calcular el gasto',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
