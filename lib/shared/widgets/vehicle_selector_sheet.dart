import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/vehicles/models/vehicle.dart';
import '../../features/vehicles/providers.dart';
import 'loading_indicator.dart';
import 'vehicle_avatar.dart';

class VehicleSelectorSheet extends ConsumerWidget {
  const VehicleSelectorSheet({super.key});

  static Future<Vehicle?> show(BuildContext context) {
    return showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => const VehicleSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
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
                loading: () =>
                    const LoadingIndicator(message: 'Cargando vehículos'),
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
                        'Sin vehículos registrados',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
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
                                const SizedBox(width: AppSpacing.xs),
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
        );
      },
    );
  }

  String? _subtitle(Vehicle vehicle) {
    final parts = [vehicle.brand, vehicle.model].whereType<String>().join(' ');
    return parts.isEmpty ? null : parts;
  }
}
