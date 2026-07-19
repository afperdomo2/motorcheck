import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../providers.dart';
import '../widgets/vehicle_card.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Vehículos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/add'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: vehiclesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () =>
              ref.read(vehiclesNotifierProvider.notifier).loadVehicles(),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car,
              title: 'No hay vehículos',
              subtitle: 'Agrega tu primer vehículo para comenzar',
              onAction: () => context.push('/vehicles/add'),
              actionLabel: 'Agregar vehículo',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: VehicleCard(
                  vehicle: vehicle,
                  isSelected: vehicle.id == selectedId,
                  onTap: () {
                    ref.read(selectedVehicleIdProvider.notifier).state =
                        vehicle.id;
                  },
                  onEdit: () => context.push('/vehicles/${vehicle.id}/edit'),
                  onDelete: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: 'Eliminar vehículo',
                      message:
                          '¿Estás seguro de eliminar "${vehicle.name}"? Se perderán todos sus mantenimientos.',
                      confirmLabel: 'Eliminar',
                      isDestructive: true,
                    );
                    if (confirmed == true && context.mounted) {
                      ref
                          .read(vehiclesNotifierProvider.notifier)
                          .remove(vehicle.id!);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
