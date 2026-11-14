import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/reminder.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.reminder, required this.onTap});

  final Reminder reminder;
  final VoidCallback onTap;

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

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminder.vehicleName,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reminder.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
      ),
    );
  }
}
