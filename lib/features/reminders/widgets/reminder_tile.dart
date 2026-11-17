import 'package:flutter/material.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/severity_rail.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/tonal_avatar.dart';
import '../models/reminder.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.reminder, required this.onTap});

  final Reminder reminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
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
      ReminderKind.budget => Icons.savings_outlined,
    };
    final railColor = switch (reminder.severity) {
      ReminderSeverity.overdue => semantic.danger,
      ReminderSeverity.warning => semantic.warning,
      ReminderSeverity.info => semantic.info,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SeverityRail(
        color: railColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                TonalAvatar(icon: icon, size: 42, iconSize: 20),
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
      ),
    );
  }
}
