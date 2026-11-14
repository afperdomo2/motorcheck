import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/component_status.dart';
import '../models/vehicle_component.dart';

AppStatus appStatusForComponent(ComponentStatus status) {
  if (status.isInactive || status.isInformational) return AppStatus.neutral;
  if (status.isOverdue) return AppStatus.danger;
  if (status.isWarning) return AppStatus.warning;
  return AppStatus.ok;
}

class ComponentCard extends StatelessWidget {
  const ComponentCard({super.key, required this.status, required this.onTap});

  final ComponentStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final component = status.component;
    final type = componentTypeFor(component.type);
    final subtitle = [
      type.label,
      if (component.position?.isNotEmpty == true) component.position!,
    ].join(' · ');

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
                  type.icon,
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
                      component.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.primaryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                status: appStatusForComponent(status),
                label: status.statusWord,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
