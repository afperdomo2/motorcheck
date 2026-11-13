import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../finance/providers.dart';
import '../providers.dart';

class FinanceSummaryCard extends ConsumerWidget {
  const FinanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(dashboardVehicleProvider).valueOrNull;
    if (vehicle?.id == null) return const SizedBox.shrink();

    final financeAsync = ref.watch(vehicleFinanceProvider(vehicle!.id!));
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.go('/finance'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: financeAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'No se pudo calcular el resumen financiero',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            data: (finance) {
              if (!finance.hasData) {
                return Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Finanzas', style: theme.textTheme.titleMedium),
                          Text(
                            'Registra combustible o gastos',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Gasto de ${finance.monthLabel}',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    formatCurrency(finance.currentMonthTotal),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _Meta(
                        icon: Icons.build_outlined,
                        text: formatCurrency(finance.currentMonthMaintenance),
                      ),
                      _Meta(
                        icon: Icons.local_gas_station_outlined,
                        text: formatCurrency(finance.currentMonthFuel),
                      ),
                      _Meta(
                        icon: Icons.receipt_long_outlined,
                        text: formatCurrency(finance.currentMonthExpenses),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _Meta(
                          icon: Icons.route_outlined,
                          text: finance.costPerKm != null
                              ? '${formatCurrency(finance.costPerKm!)} / km'
                              : 'Costo por km sin datos',
                        ),
                      ),
                      _Meta(
                        icon: Icons.local_gas_station,
                        text: finance.fuelStats.consumptionLabel(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
