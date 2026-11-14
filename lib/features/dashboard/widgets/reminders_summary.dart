import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../reminders/models/reminder.dart';
import '../../reminders/providers.dart';

class RemindersSummary extends ConsumerWidget {
  const RemindersSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider).valueOrNull ?? [];
    if (reminders.isEmpty) return const SizedBox.shrink();

    final visible = reminders.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recordatorios',
          icon: Icons.notifications_active_outlined,
          actionLabel: 'Ver todo',
          onAction: () => context.push('/reminders'),
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) const Divider(),
                _ReminderRow(reminder: visible[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final Reminder reminder;

  const _ReminderRow({required this.reminder});

  @override
  Widget build(BuildContext context) {
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
      onTap: () => context.push(reminder.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    reminder.vehicleName,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusChip(
              status: status,
              label: reminder.statusLabel,
              icon: reminder.severity == ReminderSeverity.overdue
                  ? Icons.priority_high
                  : Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }
}
