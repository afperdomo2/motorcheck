import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../budget_status.dart';
import '../providers.dart';
import 'budget_dialog.dart';

class BudgetsView extends ConsumerWidget {
  const BudgetsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(budgetStatusesProvider);

    return statusesAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorState(
        message: 'No se pudieron cargar los presupuestos',
        onRetry: () => ref.invalidate(budgetStatusesProvider),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.savings_outlined,
            title: 'Sin vehículos',
            subtitle: 'Agrega un vehículo para definir un presupuesto',
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Presupuestos de ${formatMonthYear(DateTime.now())}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Un límite por vehículo. Los gastos globales no se asignan '
              'a ningún presupuesto.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    _BudgetEntryRow(entry: entries[i]),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BudgetEntryRow extends ConsumerWidget {
  const _BudgetEntryRow({required this.entry});

  final BudgetStatusEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VehicleAvatar(type: entry.vehicle.type, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.vehicle.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.hasBudget) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _BudgetStatusChip(entry: entry),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (!entry.hasBudget)
                  Text(
                    'Sin presupuesto mensual',
                    style: theme.textTheme.bodySmall,
                  )
                else ...[
                  const SizedBox(height: AppSpacing.xs),
                  _BudgetBar(entry: entry),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${formatCurrency(entry.spent)} de '
                    '${formatCurrency(entry.amount)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    entry.remainingLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _budgetColor(context, entry.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: entry.hasBudget
                ? 'Editar presupuesto'
                : 'Definir presupuesto',
            onPressed: () => showBudgetDialog(
              context,
              ref,
              entry.vehicle.id!,
              current: entry.hasBudget ? entry.amount : null,
            ),
            icon: Icon(entry.hasBudget ? Icons.edit_outlined : Icons.add),
          ),
        ],
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({required this.entry});

  final BudgetStatusEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = _budgetColor(context, entry.status);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: entry.ratio.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        color: color,
        semanticsLabel: 'Presupuesto ${entry.percent} por ciento',
        semanticsValue: '${entry.percent.clamp(0, 100)} %',
      ),
    );
  }
}

class _BudgetStatusChip extends StatelessWidget {
  const _BudgetStatusChip({required this.entry});

  final BudgetStatusEntry entry;

  @override
  Widget build(BuildContext context) {
    final status = switch (entry.status) {
      BudgetStatus.exceeded => AppStatus.danger,
      BudgetStatus.warning => AppStatus.warning,
      BudgetStatus.ok => AppStatus.ok,
    };
    return StatusChip(
      status: status,
      label: '${entry.percent} %',
      icon: Icons.savings_outlined,
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
