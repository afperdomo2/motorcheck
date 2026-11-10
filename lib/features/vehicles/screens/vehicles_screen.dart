import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_snack_bar.dart';
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehículos'),
            Text(
              _countLabel(vehiclesAsync.valueOrNull?.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl * 2,
              ),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final vehicle = sorted[index];
                final wasFavorite = vehicle.isDefault;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: VehicleCard(
                    vehicle: vehicle,
                    onTap: () => context.push('/vehicles/${vehicle.id}'),
                    onSetDefault: () {
                      ref
                          .read(vehiclesNotifierProvider.notifier)
                          .setDefault(vehicle.id!);
                      AppSnackBar.success(
                        wasFavorite
                            ? 'Quitado de favoritos'
                            : 'Marcado como favorito',
                      );
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

  String _countLabel(int? count) {
    if (count == null) return 'Cargando…';
    if (count == 1) return '1 vehículo registrado';
    return '$count vehículos registrados';
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
