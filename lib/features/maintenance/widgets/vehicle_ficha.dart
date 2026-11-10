import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../vehicles/models/vehicle.dart';

class VehicleFicha extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;

  const VehicleFicha({super.key, required this.vehicle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            VehicleAvatar(type: vehicle.type, size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          vehicle.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vehicle.isDefault) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
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
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (vehicle.plate != null)
                        _Meta(icon: Icons.pin_outlined, text: vehicle.plate!),
                      if (vehicle.currentMileage != null)
                        _Meta(
                          icon: Icons.speed,
                          text: formatMileage(vehicle.currentMileage),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.expand_more,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
