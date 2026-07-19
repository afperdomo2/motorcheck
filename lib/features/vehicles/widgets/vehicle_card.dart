import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.forVehicleType(vehicle.type);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: typeColor.withValues(alpha: 0.15),
                child: Icon(_typeIcon(vehicle.type), color: typeColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (vehicle.brand != null || vehicle.model != null)
                      Text(
                        [
                          vehicle.brand,
                          vehicle.model,
                        ].whereType<String>().join(' '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (vehicle.plate != null || vehicle.currentMileage != null)
                      Row(
                        children: [
                          if (vehicle.plate != null) ...[
                            Icon(
                              Icons.pin,
                              size: 14,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              vehicle.plate!,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                          if (vehicle.plate != null &&
                              vehicle.currentMileage != null)
                            const SizedBox(width: 14),
                          if (vehicle.currentMileage != null) ...[
                            Icon(
                              Icons.speed,
                              size: 14,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              formatMileage(vehicle.currentMileage),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              if (vehicle.isDefault)
                Tooltip(
                  message: 'Favorito',
                  child: Icon(Icons.star, color: Colors.amber[600], size: 22),
                ),
              if (onEdit != null ||
                  onDelete != null ||
                  onSetDefault != null) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                    if (value == 'default') onSetDefault?.call();
                  },
                  itemBuilder: (context) => [
                    if (!vehicle.isDefault) ...[
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 20,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 8),
                            const Text('Marcar como favorito'),
                          ],
                        ),
                      ),
                    ],
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
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'car' => Icons.directions_car,
      'motorcycle' => Icons.motorcycle,
      'bike' => Icons.pedal_bike,
      'truck' => Icons.local_shipping,
      _ => Icons.help_outline,
    };
  }
}
