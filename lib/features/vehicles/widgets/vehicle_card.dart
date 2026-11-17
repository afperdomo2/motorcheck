import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/meta_row.dart';
import '../../../shared/widgets/plate_badge.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = AppSemanticColors.of(context);
    final tint = semantic
        .vehicleColor(vehicle.type)
        .withValues(alpha: theme.brightness == Brightness.dark ? 0.14 : 0.06);

    return Card(
      color: tint,
      child: InkWell(
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
                            color: scheme.primary,
                            semanticLabel: 'Vehículo por defecto',
                          ),
                        ],
                      ],
                    ),
                    if (vehicle.brand != null || vehicle.model != null)
                      Text(
                        [
                          vehicle.brand,
                          vehicle.model,
                        ].whereType<String>().join(' '),
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (vehicle.plate != null)
                          PlateBadge(plate: vehicle.plate),
                        if (vehicle.currentMileage != null)
                          MetaRow(
                            icon: Icons.speed,
                            text: formatMileage(vehicle.currentMileage),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSetDefault == null
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onSetDefault!.call();
                      },
                tooltip: vehicle.isDefault
                    ? 'Quitar como vehículo por defecto'
                    : 'Usar como vehículo por defecto',
                icon: Icon(
                  vehicle.isDefault ? Icons.star_rounded : Icons.star_border,
                  color: vehicle.isDefault
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
