import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_status.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/vehicle_document.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final VehicleDocument document;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = documentTypeFor(document.type);
    final status = dateStatus(document.expiresAt);
    final appStatus = switch (status.level) {
      ExpiryLevel.danger => AppStatus.danger,
      ExpiryLevel.warning => AppStatus.warning,
      ExpiryLevel.ok => AppStatus.ok,
    };
    final title = document.name?.isNotEmpty == true
        ? document.name!
        : type.label;

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  type.icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.label,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formatDisplayDate(document.expiresAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        if (document.filePath != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.attach_file,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(
                    status: appStatus,
                    label: status.shortLabel,
                    icon: Icons.schedule,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PopupMenuButton<_DocumentAction>(
                    tooltip: 'Opciones',
                    onSelected: (action) {
                      switch (action) {
                        case _DocumentAction.edit:
                          onEdit();
                        case _DocumentAction.delete:
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _DocumentAction.edit,
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _DocumentAction.delete,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DocumentAction { edit, delete }
