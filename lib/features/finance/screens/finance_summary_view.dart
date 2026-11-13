import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
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
            _BudgetCard(vehicleId: vehicleId, spent: finance.currentMonthTotal),
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

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard({required this.vehicleId, required this.spent});

  final int vehicleId;
  final double spent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetForVehicleProvider(vehicleId));
    final theme = Theme.of(context);

    return budgetAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
      data: (budget) {
        if (budget == null || budget.amount <= 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sin presupuesto mensual',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'Define un límite para controlar el gasto',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _edit(context, ref),
                    child: const Text('Definir'),
                  ),
                ],
              ),
            ),
          );
        }

        final progress = (spent / budget.amount).clamp(0.0, 1.5);
        final exceeded = spent > budget.amount;
        final warning = !exceeded && progress >= 0.8;
        final color = exceeded
            ? theme.colorScheme.error
            : warning
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.savings_outlined, color: color),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Presupuesto mensual',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _edit(context, ref, budget.amount),
                      child: const Text('Editar'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Límite ${formatCurrency(budget.amount)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      'Gastado ${formatCurrency(spent)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    color: color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  exceeded
                      ? 'Superado por ${formatCurrency(spent - budget.amount)}'
                      : 'Disponible ${formatCurrency(budget.amount - spent)}'
                            '${warning ? ' · cerca del límite' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    double? current,
  ]) async {
    final controller = TextEditingController(
      text: current != null ? current.toStringAsFixed(0) : '',
    );
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Presupuesto mensual'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Límite del mes',
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(
                controller.text.trim().replaceAll(',', '.'),
              );
              Navigator.of(context).pop(value);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null || amount <= 0) return;

    try {
      await ref.read(budgetNotifierProvider.notifier).save(vehicleId, amount);
      if (!context.mounted) return;
      AppSnackBar.success('Presupuesto actualizado');
    } catch (error) {
      logError('guardar presupuesto', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error('No se pudo guardar el presupuesto');
    }
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
