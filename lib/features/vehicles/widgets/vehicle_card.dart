import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback? onSetDefault;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.forVehicleType(vehicle.type);

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSetDefault?.call();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Icon(
                        vehicle.isDefault ? Icons.star : Icons.star_border,
                        key: ValueKey(vehicle.isDefault),
                        color: vehicle.isDefault ? Colors.amber[600] : null,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).disabledColor,
                ),
              ),
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
