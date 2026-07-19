import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../categories.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';

IconData _vehicleIcon(String? type) => switch (type) {
  'motorcycle' => Icons.motorcycle,
  'bike' => Icons.pedal_bike,
  'truck' => Icons.local_shipping,
  'other' => Icons.help_outline,
  _ => Icons.directions_car,
};

class TimelineTile extends StatelessWidget {
  final Maintenance maintenance;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? vehicleName;
  final String? vehicleType;
  final String? workshopName;
  final String? workshopLocation;
  final List<MaintenanceItem> items;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.maintenance,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.vehicleName,
    this.vehicleType,
    this.workshopName,
    this.workshopLocation,
    this.items = const [],
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = maintenance.maintenanceCost + maintenance.totalPartsCost;
    final categoryKeys = items.map((i) => i.category).toSet().toList();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimelineIndicator(date: maintenance.date, isLast: isLast),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (vehicleName != null) ...[
                        Row(
                          children: [
                            Icon(_vehicleIcon(vehicleType), size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                vehicleName!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        if (workshopName != null ||
                            categoryKeys.isNotEmpty ||
                            maintenance.mileage != null)
                          const SizedBox(height: 8),
                      ],
                      if (workshopName != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.handyman, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              workshopName!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        if (workshopLocation != null &&
                            workshopLocation!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const SizedBox(width: 22),
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Theme.of(context).disabledColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  workshopLocation!,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                      if (maintenance.mileage != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.speed, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              formatMileage(maintenance.mileage),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      if (categoryKeys.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: categoryKeys.map((key) {
                            return Chip(
                              avatar: Icon(
                                MaintenanceCategories.icon(key),
                                size: 16,
                              ),
                              label: Text(
                                MaintenanceCategories.label(key),
                                style: const TextStyle(fontSize: 12),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                      if (total > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          formatCurrency(total),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                      if (maintenance.notes != null &&
                          maintenance.notes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          maintenance.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TimelineIndicator extends StatelessWidget {
  final DateTime date;
  final bool isLast;

  const _TimelineIndicator({required this.date, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final day = date.day.toString();
    final month = _monthAbbr(date.month);

    return SizedBox(
      width: 40,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            month,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: color.withValues(alpha: 0.3),
                margin: const EdgeInsets.only(top: 4),
              ),
            ),
        ],
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month];
  }
}
