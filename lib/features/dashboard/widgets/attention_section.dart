import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/tonal_avatar.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../finance/budget_status.dart';
import '../../finance/finance_section.dart';
import '../../finance/providers.dart';
import '../../reminders/models/reminder.dart';
import '../../reminders/providers.dart';
import '../../vehicles/providers.dart';

/// Sección global del Inicio: vencimientos de todos los vehículos y
/// presupuestos en riesgo. Solo se muestra si hay algo que mirar.
class AttentionSection extends ConsumerWidget {
  const AttentionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final budgetsAsync = ref.watch(budgetStatusesProvider);

    final reminders = remindersAsync.valueOrNull ?? const <Reminder>[];
    final budgets = budgetsAsync.valueOrNull ?? const <BudgetStatusEntry>[];
    final withBudget = budgets.where((entry) => entry.hasBudget).toList();
    final atRisk = withBudget
        .where((entry) => entry.status != BudgetStatus.ok)
        .toList();
    final sortedBudgets = [...withBudget]
      ..sort((a, b) {
        final rankA = _budgetRank(a.status);
        final rankB = _budgetRank(b.status);
        if (rankA != rankB) return rankA.compareTo(rankB);
        return b.ratio.compareTo(a.ratio);
      });

    if (reminders.isEmpty && atRisk.isEmpty) {
      if (remindersAsync.hasError || budgetsAsync.hasError) {
        return _ErrorCard(
          onRetry: () {
            ref.invalidate(remindersProvider);
            ref.invalidate(budgetStatusesProvider);
          },
        );
      }
      return const SizedBox.shrink();
    }

    final count = reminders.length + atRisk.length;
    // Si hay presupuestos en riesgo, deja espacio para que se vean sin
    // desplazar la pantalla: dos vencimientos son suficientes como avance.
    final visibleReminders = reminders.take(atRisk.isEmpty ? 3 : 2).toList();
    final visibleBudgets = sortedBudgets.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atención · $count',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'En todos tus vehículos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              if (visibleReminders.isNotEmpty) ...[
                _SubHeader(
                  title: 'Vencimientos',
                  actionLabel: 'Ver todas',
                  onAction: () => context.push('/reminders'),
                ),
                for (var i = 0; i < visibleReminders.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ReminderRow(reminder: visibleReminders[i]),
                ],
              ],
              if (atRisk.isNotEmpty) ...[
                if (visibleReminders.isNotEmpty) const Divider(height: 1),
                _SubHeader(
                  title: 'Presupuestos',
                  actionLabel: 'Ver todos',
                  onAction: () => _openBudgets(context, ref),
                ),
                for (var i = 0; i < visibleBudgets.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _BudgetRow(entry: visibleBudgets[i]),
                ],
              ],
              if ((remindersAsync.hasError || budgetsAsync.hasError) &&
                  (visibleReminders.isNotEmpty || atRisk.isNotEmpty)) ...[
                const Divider(height: 1),
                _InlineError(
                  onRetry: () {
                    ref.invalidate(remindersProvider);
                    ref.invalidate(budgetStatusesProvider);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openBudgets(BuildContext context, WidgetRef ref) async {
    ref.read(financeSectionProvider.notifier).state = FinanceSection.budgets;
    context.go('/finance');
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = switch (reminder.severity) {
      ReminderSeverity.overdue => AppStatus.danger,
      ReminderSeverity.warning => AppStatus.warning,
      ReminderSeverity.info => AppStatus.info,
    };
    final icon = switch (reminder.kind) {
      ReminderKind.maintenance => Icons.build_outlined,
      ReminderKind.document => Icons.description_outlined,
      ReminderKind.component => Icons.tire_repair,
      ReminderKind.restriction => Icons.directions_car_outlined,
    };

    return InkWell(
      onTap: () => _open(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TonalAvatar(icon: icon, size: 36, iconSize: 18),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        reminder.vehicleName,
                        style: theme.textTheme.bodySmall,
                      ),
                      StatusChip(
                        status: status,
                        label: reminder.statusLabel,
                        icon: reminder.severity == ReminderSeverity.overdue
                            ? Icons.priority_high
                            : Icons.schedule,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    if (reminder.vehicleId > 0) {
      try {
        await ref
            .read(vehiclesNotifierProvider.notifier)
            .selectVehicle(reminder.vehicleId);
      } catch (error, stackTrace) {
        logError('seleccionar vehículo desde alerta', error, stackTrace);
      }
    }
    if (!context.mounted) return;
    context.push(reminder.route);
  }
}

class _BudgetRow extends ConsumerWidget {
  const _BudgetRow({required this.entry});

  final BudgetStatusEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _budgetColor(context, entry.status);

    return InkWell(
      onTap: () => _open(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VehicleAvatar(type: entry.vehicle.type, size: 36),
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
                      const SizedBox(width: AppSpacing.sm),
                      StatusChip(
                        status: _appStatus(entry.status),
                        label: '${entry.percent} %',
                        icon: Icons.savings_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: entry.ratio.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      color: color,
                      semanticsLabel: 'Presupuesto ${entry.percent} por ciento',
                      semanticsValue: '${entry.percent.clamp(0, 100)} %',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${formatCurrency(entry.spent)} de '
                    '${formatCurrency(entry.amount)} · '
                    '${entry.remainingLabel}',
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final id = entry.vehicle.id;
    if (id != null) {
      try {
        await ref.read(vehiclesNotifierProvider.notifier).selectVehicle(id);
      } catch (error, stackTrace) {
        logError('seleccionar vehículo desde presupuesto', error, stackTrace);
      }
    }
    if (!context.mounted) return;
    ref.read(financeSectionProvider.notifier).state = FinanceSection.budgets;
    context.go('/finance');
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'No se pudieron cargar las alertas',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'No se pudieron cargar todas las alertas',
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

AppStatus _appStatus(BudgetStatus status) => switch (status) {
  BudgetStatus.exceeded => AppStatus.danger,
  BudgetStatus.warning => AppStatus.warning,
  BudgetStatus.ok => AppStatus.ok,
};

Color _budgetColor(BuildContext context, BudgetStatus status) {
  final semantic = AppSemanticColors.of(context);
  return switch (status) {
    BudgetStatus.ok => semantic.success,
    BudgetStatus.warning => semantic.warning,
    BudgetStatus.exceeded => semantic.danger,
  };
}

int _budgetRank(BudgetStatus status) => switch (status) {
  BudgetStatus.exceeded => 0,
  BudgetStatus.warning => 1,
  BudgetStatus.ok => 2,
};
