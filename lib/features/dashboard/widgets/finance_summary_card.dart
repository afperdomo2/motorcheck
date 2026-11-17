import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/tonal_avatar.dart';
import '../../finance/budget_status.dart';
import '../../finance/finance_section.dart';
import '../../finance/providers.dart';
import '../../finance/widgets/budget_dialog.dart';
import '../../vehicles/current_vehicle_provider.dart';
import '../../vehicles/providers.dart';

class FinanceSummaryCard extends ConsumerWidget {
  const FinanceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(currentVehicleProvider).valueOrNull;
    if (vehicle?.id == null) return const SizedBox.shrink();

    final vehicleId = vehicle!.id!;
    final financeAsync = ref.watch(vehicleFinanceProvider(vehicleId));
    final budgetAsync = ref.watch(budgetForVehicleProvider(vehicleId));
    final budget = budgetAsync.valueOrNull;
    final fleet = ref.watch(fleetMonthSpendProvider).valueOrNull;
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];

    return Card(
      child: InkWell(
        onTap: () {
          ref.read(financeSectionProvider.notifier).state =
              FinanceSection.summary;
          context.go('/finance');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(vehicleName: vehicle.name),
              financeAsync.when(
                loading: () => const SizedBox(
                  height: 96,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => _FinanceError(
                  onRetry: () =>
                      ref.invalidate(vehicleFinanceProvider(vehicleId)),
                ),
                data: (finance) {
                  if (!finance.hasData) {
                    return _EmptyFinance(vehicleId: vehicleId);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatCurrency(finance.currentMonthTotal),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (budgetAsync.isLoading)
                        const SizedBox(height: AppSpacing.sm)
                      else if (budgetAsync.hasError)
                        Text(
                          'No se pudo cargar el presupuesto',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else if (budget != null && budget.amount > 0)
                        _BudgetProgress(
                          spent: finance.currentMonthTotal,
                          amount: budget.amount,
                        )
                      else
                        TextButton.icon(
                          onPressed: () =>
                              showBudgetDialog(context, ref, vehicleId),
                          icon: const Icon(Icons.savings_outlined, size: 18),
                          label: const Text('Definir presupuesto'),
                        ),
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
                        label: 'Otros',
                        value: finance.currentMonthExpenses,
                      ),
                      if (vehicles.length > 1 &&
                          fleet != null &&
                          fleet > 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(height: 1),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total de ${vehicles.length} vehículos',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              formatCurrency(fleet),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.vehicleName});

  final String vehicleName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const TonalAvatar(icon: Icons.savings_outlined, size: 40, iconSize: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gasto de ${formatMonthYear(DateTime.now())}',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                vehicleName,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      ],
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.spent, required this.amount});

  final double spent;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = budgetStatusFor(spent: spent, amount: amount);
    final color = _budgetColor(context, status);
    final percent = ((spent / amount) * 100).round();
    final remaining = spent > amount
        ? 'Excedido por ${formatCurrency(spent - amount)}'
        : status == BudgetStatus.exceeded
        ? 'Límite alcanzado'
        : 'Quedan ${formatCurrency(amount - spent)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Presupuesto ${formatCurrency(amount)}',
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$percent %',
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (spent / amount).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainer,
            color: color,
            semanticsLabel: 'Presupuesto $percent por ciento',
            semanticsValue: '${percent.clamp(0, 100)} %',
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          remaining,
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          TonalAvatar(icon: icon, size: 28, iconSize: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            formatCurrency(value),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFinance extends StatelessWidget {
  const _EmptyFinance({required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Aún no hay movimientos este mes',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/finance/fuel/add?vehicleId=$vehicleId'),
              icon: const Icon(Icons.local_gas_station, size: 18),
              label: const Text('Combustible'),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/finance/expenses/add?vehicleId=$vehicleId'),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Gasto'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FinanceError extends StatelessWidget {
  const _FinanceError({required this.onRetry});

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
              'No se pudo calcular el gasto del mes',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

Color _budgetColor(BuildContext context, BudgetStatus status) {
  final semantic = AppSemanticColors.of(context);
  return switch (status) {
    BudgetStatus.ok => semantic.success,
    BudgetStatus.warning => semantic.warning,
    BudgetStatus.exceeded => semantic.danger,
  };
}
