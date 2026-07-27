import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers.dart';
import '../widgets/vehicle_card.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: _buildTitle(context, vehiclesAsync)),
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

          final sorted = _sortVehicles(vehicles);

          return RefreshIndicator(
            onRefresh: ref.read(vehiclesNotifierProvider.notifier).loadVehicles,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final vehicle = sorted[index];
                final wasFavorite = vehicle.isDefault;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VehicleCard(
                    vehicle: vehicle,
                    onTap: () => context.push('/vehicles/${vehicle.id}'),
                    onSetDefault: () {
                      ref
                          .read(vehiclesNotifierProvider.notifier)
                          .setDefault(vehicle.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              wasFavorite
                                  ? 'Quitado de favoritos'
                                  : 'Marcado como favorito',
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                              bottom: 80,
                              left: 16,
                              right: 16,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    AsyncValue<List<dynamic>> vehiclesAsync,
  ) {
    final count = vehiclesAsync.valueOrNull?.length;

    if (count == null) return const Text('Mis Vehículos');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mis Vehículos'),
        Text(
          '$count vehículos',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<dynamic> _sortVehicles(List<dynamic> vehicles) {
    final sorted = [...vehicles]
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });
    return sorted;
  }
}
