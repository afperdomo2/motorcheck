import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../maintenance/providers.dart';
import '../../reminders/providers.dart';
import '../../restrictions/providers.dart';
import '../../vehicles/current_vehicle_provider.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/widgets/mileage_update_sheet.dart';

/// Resumen compacto del vehículo actual. La card completa navega al detalle;
/// las acciones internas son solo las dos de uso frecuente.
class FavoriteVehicleCard extends ConsumerWidget {
  const FavoriteVehicleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(currentVehicleProvider).valueOrNull;
    if (vehicle == null || vehicle.id == null) return const SizedBox.shrink();

    final upcoming = ref
        .watch(upcomingMaintenanceProvider(vehicle.id!))
        .valueOrNull;
    final upcomingCount =
        upcoming?.where((item) => item.isWarning || item.isOverdue).length ?? 0;

    return Card(
      child: InkWell(
        onTap: () => context.push('/vehicles/${vehicle.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VehicleHeader(vehicle: vehicle),
              _HealthChip(vehicleId: vehicle.id!),
              _RestrictionRow(vehicleId: vehicle.id!),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => MileageUpdateSheet.show(context, vehicle),
                    icon: const Icon(Icons.speed, size: 18),
                    label: const Text('Actualizar km'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/vehicles/${vehicle.id}/upcoming'),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(
                      upcomingCount > 0
                          ? 'Próximos ($upcomingCount)'
                          : 'Próximos',
                    ),
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

class _VehicleHeader extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleHeader({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identity = [
      vehicle.brand,
      vehicle.model,
    ].whereType<String>().join(' ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VehicleAvatar(type: vehicle.type, size: 52),
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
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (vehicle.isDefault) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star,
                      size: 18,
                      color: theme.colorScheme.primary,
                      semanticLabel: 'Vehículo principal',
                    ),
                  ],
                ],
              ),
              if (identity.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  identity,
                  style: theme.textTheme.bodyMedium,
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
        Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
      ],
    );
  }
}

class _HealthChip extends ConsumerWidget {
  final int vehicleId;

  const _HealthChip({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(vehicleHealthProvider(vehicleId)).valueOrNull;
    if (health == null || !health.hasData) return const SizedBox.shrink();

    final status = health.value >= 90
        ? AppStatus.ok
        : health.value >= 70
        ? AppStatus.warning
        : AppStatus.danger;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: StatusChip(
        status: status,
        label: 'Salud ${health.value}/100 · ${health.label}',
        icon: Icons.favorite_border,
      ),
    );
  }
}

class _RestrictionRow extends ConsumerWidget {
  final int vehicleId;

  const _RestrictionRow({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref
        .watch(vehicleRestrictionStatusProvider(vehicleId))
        .valueOrNull;
    if (status == null || !status.configured) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final label = switch (status) {
      _ when status.restrictedToday => 'Pico y placa · ${status.todayLabel}',
      _ when status.nextRestrictionDate != null =>
        'Pico y placa · Hoy circulas · próx. ${status.nextLabel}',
      _ => 'Pico y placa · ${status.todayLabel}',
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: InkWell(
        onTap: () => context.push('/vehicles/$vehicleId/restriction'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Icon(
                status.restrictedToday
                    ? Icons.do_not_disturb_on_outlined
                    : Icons.directions_car_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Editar',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
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
