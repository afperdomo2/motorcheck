import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../maintenance/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';

class FavoriteVehicleCard extends ConsumerWidget {
  const FavoriteVehicleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultVehicle = ref.watch(defaultVehicleProvider).valueOrNull;
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];

    final vehicle =
        defaultVehicle ?? (vehicles.isNotEmpty ? vehicles.first : null);

    if (vehicle == null || vehicle.id == null) return const SizedBox.shrink();

    return Card(
      child: InkWell(
        onTap: () => context.push('/vehicles/${vehicle.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VehicleHeader(vehicle: vehicle),
              const SizedBox(height: 12),
              _Actions(
                upcomingCount: _upcomingCount(ref, vehicle.id!),
                onMaintenance: () => _goToMaintenance(context, ref, vehicle),
                onDetails: () => context.push('/vehicles/${vehicle.id}'),
                onUpcoming: () =>
                    context.push('/vehicles/${vehicle.id}/upcoming'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _upcomingCount(WidgetRef ref, int vehicleId) {
    final upcoming = ref
        .watch(upcomingMaintenanceProvider(vehicleId))
        .valueOrNull;
    if (upcoming == null) return 0;
    return upcoming.where((u) => u.isWarning || u.isOverdue).length;
  }

  Future<void> _goToMaintenance(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    await ref
        .read(vehiclesNotifierProvider.notifier)
        .selectVehicle(vehicle.id!);
    if (context.mounted) context.go('/maintenance');
  }
}

class _VehicleHeader extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleHeader({required this.vehicle});

  IconData get _typeIcon => switch (vehicle.type) {
    'car' => Icons.directions_car,
    'motorcycle' => Icons.motorcycle,
    'bike' => Icons.pedal_bike,
    'truck' => Icons.local_shipping,
    _ => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = AppColors.forVehicleType(vehicle.type);

    return Row(
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
                  [vehicle.brand, vehicle.model].whereType<String>().join(' '),
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
                    Text(vehicle.plate!, style: theme.textTheme.labelMedium),
                  ],
                  if (vehicle.plate != null && vehicle.currentMileage != null)
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
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: theme.disabledColor),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final int upcomingCount;
  final VoidCallback onMaintenance;
  final VoidCallback onDetails;
  final VoidCallback onUpcoming;

  const _Actions({
    required this.upcomingCount,
    required this.onMaintenance,
    required this.onDetails,
    required this.onUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 24),
        Row(
          children: [
            _ActionItem(
              icon: Icons.build,
              label: 'Mantenimientos',
              onTap: onMaintenance,
            ),
            _ActionItem(
              icon: Icons.info_outline,
              label: 'Detalles',
              onTap: onDetails,
            ),
            _ActionItem(
              icon: Icons.schedule,
              label: 'Próximos',
              badge: upcomingCount > 0 ? upcomingCount : null,
              onTap: onUpcoming,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Badge(
                isLabelVisible: badge != null,
                label: Text('$badge'),
                child: Icon(icon, size: 24, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
