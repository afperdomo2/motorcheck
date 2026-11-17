import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/tonal_avatar.dart';
import '../../reminders/models/reminder.dart';
import '../../reminders/providers.dart';
import '../../vehicles/providers.dart';

/// Vencimientos de todos los vehículos. El pico y placa vive en su propia
/// tira para que se vea el de todos, no solo el del vehículo actual.
class AttentionSection extends ConsumerWidget {
  const AttentionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final reminders = (remindersAsync.valueOrNull ?? const <Reminder>[])
        .where((reminder) => reminder.kind != ReminderKind.restriction)
        .toList();

    if (reminders.isEmpty) {
      if (remindersAsync.hasError) {
        return _ErrorCard(onRetry: () => ref.invalidate(remindersProvider));
      }
      return const SizedBox.shrink();
    }

    final visible = reminders.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Vencimientos',
            actionLabel: 'Ver todas',
            onAction: () => context.push('/reminders'),
          ),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ReminderRow(reminder: visible[i]),
                ],
              ],
            ),
          ),
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
    final semantic = AppSemanticColors.of(context);
    final railColor = switch (reminder.severity) {
      ReminderSeverity.overdue => semantic.danger,
      ReminderSeverity.warning => semantic.warning,
      ReminderSeverity.info => semantic.info,
    };

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: railColor, width: 4)),
      ),
      child: InkWell(
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
        logError('seleccionar vehículo desde vencimiento', error, stackTrace);
      }
    }
    if (!context.mounted) return;
    context.push(reminder.route);
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'No se pudieron cargar los vencimientos',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}
