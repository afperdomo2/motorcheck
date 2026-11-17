import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../vehicles/current_vehicle_provider.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';

/// Rail horizontal con el vehículo actual y el resto de vehículos.
class VehicleSwitcher extends ConsumerWidget {
  const VehicleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    if (vehicles.length < 2) return const SizedBox.shrink();

    final current = ref.watch(currentVehicleProvider).valueOrNull;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final vehicle in vehicles)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _VehicleChip(
                vehicle: vehicle,
                selected: vehicle.id == current?.id,
                onTap: () => _select(ref, vehicle),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _select(WidgetRef ref, Vehicle vehicle) async {
    final id = vehicle.id;
    if (id == null) return;
    try {
      await ref.read(vehiclesNotifierProvider.notifier).selectVehicle(id);
    } catch (error, stackTrace) {
      logError('seleccionar vehículo desde inicio', error, stackTrace);
    }
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Vehículo ${vehicle.name}',
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainer,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VehicleAvatar(type: vehicle.type, size: 26),
                const SizedBox(width: AppSpacing.xs + 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 128),
                  child: Text(
                    vehicle.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (vehicle.isDefault) ...[
                  const SizedBox(width: 2),
                  Icon(
                    Icons.star,
                    size: 14,
                    color: selected ? foreground : scheme.primary,
                    semanticLabel: 'Vehículo principal',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
