import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/vehicles/models/vehicle.dart';
import '../../features/vehicles/providers.dart';
import 'vehicle_avatar.dart';

class VehicleSelectorSheet extends ConsumerWidget {
  const VehicleSelectorSheet({super.key});

  static Future<Vehicle?> show(BuildContext context) {
    return showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const VehicleSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              'Selecciona un vehículo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: vehiclesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'No se pudieron cargar los vehículos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay vehículos registrados',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: VehicleAvatar(type: vehicle.type, size: 40),
                        title: Row(
                          children: [
                            Flexible(child: Text(vehicle.name)),
                            if (vehicle.isDefault) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        subtitle: _subtitle(vehicle) != null
                            ? Text(_subtitle(vehicle)!)
                            : null,
                        trailing: vehicle.plate != null
                            ? Text(vehicle.plate!)
                            : null,
                        onTap: () => Navigator.of(context).pop(vehicle),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _subtitle(Vehicle vehicle) {
    final parts = [vehicle.brand, vehicle.model].whereType<String>().join(' ');
    return parts.isEmpty ? null : parts;
  }
}
