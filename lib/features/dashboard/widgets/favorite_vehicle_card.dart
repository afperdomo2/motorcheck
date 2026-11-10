import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_status.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VehicleHeader(vehicle: vehicle),
              if (_hasDocuments(vehicle)) ...[
                const SizedBox(height: AppSpacing.md),
                _DocumentChips(vehicle: vehicle),
              ],
              const SizedBox(height: AppSpacing.md),
              const Divider(),
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

  bool _hasDocuments(Vehicle vehicle) =>
      vehicle.soatExpiresAt != null || vehicle.rtmExpiresAt != null;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
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
                      semanticLabel: 'Vehículo por defecto',
                    ),
                  ],
                ],
              ),
              if (vehicle.brand != null || vehicle.model != null) ...[
                const SizedBox(height: 2),
                Text(
                  [vehicle.brand, vehicle.model].whereType<String>().join(' '),
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
                  _Meta(
                    icon: vehicleTypeIcon(vehicle.type),
                    text: vehicleTypeLabel(vehicle.type),
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

class _DocumentChips extends StatelessWidget {
  final Vehicle vehicle;

  const _DocumentChips({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        if (vehicle.soatExpiresAt != null)
          _documentChip('SOAT', vehicle.soatExpiresAt!),
        if (vehicle.rtmExpiresAt != null)
          _documentChip('RTM', vehicle.rtmExpiresAt!),
      ],
    );
  }

  Widget _documentChip(String label, DateTime date) {
    final status = dateStatus(date);
    final appStatus = switch (status.level) {
      ExpiryLevel.danger => AppStatus.danger,
      ExpiryLevel.warning => AppStatus.warning,
      ExpiryLevel.ok => AppStatus.ok,
    };
    return StatusChip(
      status: appStatus,
      label: '$label · ${status.shortLabel}',
      icon: Icons.shield_outlined,
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
    return Row(
      children: [
        _ActionItem(
          icon: Icons.build_outlined,
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
    final semantic = AppSemanticColors.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              Badge(
                isLabelVisible: badge != null,
                label: Text('$badge'),
                child: Icon(icon, size: 24, color: semantic.accentText),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
