import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
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
      appBar: AppBar(title: const Text('Vehículos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/add'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: vehiclesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: 'No se pudieron cargar los vehículos',
          onRetry: () =>
              ref.read(vehiclesNotifierProvider.notifier).loadVehicles(),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car,
              title: 'Sin vehículos',
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
                AppSpacing.xxxl * 2,
              ),
              itemCount: sorted.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      _countLabel(vehicles.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }

                final vehicle = sorted[index - 1];

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: VehicleCard(
                    vehicle: vehicle,
                    onTap: () => context.push('/vehicles/${vehicle.id}'),
                    onSetDefault: () async {
                      final notifier = ref.read(
                        vehiclesNotifierProvider.notifier,
                      );
                      try {
                        if (vehicle.isDefault) {
                          await notifier.clearDefault();
                          AppSnackBar.success('Vehículo por defecto eliminado');
                        } else {
                          await notifier.setDefault(vehicle.id!);
                          AppSnackBar.success(
                            'Ahora es tu vehículo por defecto',
                          );
                        }
                      } catch (error) {
                        logError(
                          'cambiar vehículo por defecto',
                          error,
                          StackTrace.current,
                        );
                        AppSnackBar.error(
                          friendlyErrorMessage(
                            error,
                            fallback:
                                'No se pudo actualizar el vehículo por defecto',
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
