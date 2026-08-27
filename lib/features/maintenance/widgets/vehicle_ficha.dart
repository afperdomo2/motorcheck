import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../vehicles/models/vehicle.dart';

class VehicleFicha extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleFicha({super.key, required this.vehicle, required this.onTap});

  IconData get _typeIcon => switch (vehicle.type) {
    'car' => Icons.directions_car,
    'motorcycle' => Icons.motorcycle,
    'bike' => Icons.pedal_bike,
    'truck' => Icons.local_shipping,
    _ => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.forVehicleType(vehicle.type);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: typeColor.withValues(alpha: 0.15),
              child: Icon(_typeIcon, color: typeColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          vehicle.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vehicle.isDefault) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.star, size: 16, color: Colors.amber[600]),
                      ],
                    ],
                  ),
                  if (vehicle.brand != null || vehicle.model != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        vehicle.brand,
                        vehicle.model,
                      ].whereType<String>().join(' '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (vehicle.plate != null) ...[
                        Icon(Icons.pin, size: 14, color: theme.disabledColor),
                        const SizedBox(width: 2),
                        Text(
                          vehicle.plate!,
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                      if (vehicle.plate != null &&
                          vehicle.currentMileage != null)
                        const SizedBox(width: 12),
                      if (vehicle.currentMileage != null) ...[
                        Icon(Icons.speed, size: 14, color: theme.disabledColor),
                        const SizedBox(width: 2),
                        Text(
                          formatMileage(vehicle.currentMileage),
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    ],
                  ),
                  if (vehicle.soatExpiresAt != null ||
                      vehicle.rtmExpiresAt != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (vehicle.soatExpiresAt != null)
                          _statusPill(
                            theme,
                            Icons.health_and_safety_outlined,
                            'SOAT',
                            vehicle.soatExpiresAt!,
                          ),
                        if (vehicle.rtmExpiresAt != null)
                          _statusPill(
                            theme,
                            Icons.engineering_outlined,
                            'RTM',
                            vehicle.rtmExpiresAt!,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.expand_more, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(
    ThemeData theme,
    IconData icon,
    String label,
    DateTime date,
  ) {
    final color = expiryColor(date);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            '$label · ${_daysShort(date)}',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _daysShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff > 0) return 'en $diff d';
    if (diff == 0) return 'hoy';
    return 'hace ${-diff} d';
  }
}
