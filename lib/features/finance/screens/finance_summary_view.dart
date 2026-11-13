import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers.dart';
import '../widgets/monthly_spend_chart.dart';

class FinanceSummaryView extends ConsumerWidget {
  const FinanceSummaryView({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(vehicleFinanceProvider(vehicleId));

    return financeAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorState(
        message: 'No se pudo calcular el resumen financiero',
        onRetry: () => ref.invalidate(vehicleFinanceProvider(vehicleId)),
      ),
      data: (finance) {
        if (!finance.hasData) {
          return _EmptyFinance(vehicleId: vehicleId);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            _MonthCard(finance: finance),
            const SizedBox(height: AppSpacing.md),
            _TotalsCard(finance: finance),
            const SizedBox(height: AppSpacing.md),
            MonthlySpendChart(points: finance.monthlyPoints),
          ],
        );
      },
    );
  }
}

class _EmptyFinance extends StatelessWidget {
  final int vehicleId;

  const _EmptyFinance({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Aún no hay movimientos',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Registra una tanqueada o un gasto para ver el costo real '
                  'del vehículo.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.push(
                        '/finance/fuel/add?vehicleId=$vehicleId',
                      ),
                      icon: const Icon(Icons.local_gas_station),
                      label: const Text('Registrar combustible'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/finance/expenses/add?vehicleId=$vehicleId',
                      ),
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Registrar gasto'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final VehicleFinanceSummary finance;

  const _MonthCard({required this.finance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(finance.monthLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              formatCurrency(finance.currentMonthTotal),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            _MoneyRow(
              icon: Icons.build_outlined,
              label: 'Mantenimiento',
              value: finance.currentMonthMaintenance,
            ),
            _MoneyRow(
              icon: Icons.local_gas_station_outlined,
              label: 'Combustible',
              value: finance.currentMonthFuel,
            ),
            _MoneyRow(
              icon: Icons.receipt_long_outlined,
              label: 'Gastos del vehículo',
              value: finance.currentMonthExpenses,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final VehicleFinanceSummary finance;

  const _TotalsCard({required this.finance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Histórico', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.md,
              children: [
                _Stat(
                  label: 'Gasto total',
                  value: formatCurrency(finance.totalCost),
                ),
                _Stat(
                  label: 'Costo por km',
                  value: finance.costPerKm != null
                      ? formatCurrency(finance.costPerKm!)
                      : 'Sin datos',
                ),
                _Stat(
                  label: 'Consumo',
                  value: finance.fuelStats.consumptionLabel(),
                ),
                _Stat(
                  label: 'Registros',
                  value:
                      '${finance.maintenanceCount + finance.fuelCount + finance.expenseCount}',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${finance.maintenanceCount} mantenimientos · '
              '${finance.fuelCount} tanqueadas · '
              '${finance.expenseCount} gastos',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;

  const _MoneyRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            formatCurrency(value),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
