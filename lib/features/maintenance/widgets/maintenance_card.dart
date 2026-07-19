import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../models/maintenance.dart';

class MaintenanceCard extends StatelessWidget {
  final Maintenance maintenance;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MaintenanceCard({
    super.key,
    required this.maintenance,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final total = maintenance.totalLaborCost + maintenance.totalPartsCost;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      maintenance.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(maintenance.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (maintenance.mileage != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.speed, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      formatMileage(maintenance.mileage),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
              if (total > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Costo total: ${formatCurrency(total)}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
              if (maintenance.notes != null &&
                  maintenance.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  maintenance.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
