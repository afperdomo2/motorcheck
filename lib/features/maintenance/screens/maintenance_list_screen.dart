import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/maintenance_search_delegate.dart';

class MaintenanceListScreen extends ConsumerWidget {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleId = ref.watch(selectedVehicleIdProvider);
    final maintenancesAsync = ref.watch(maintenancesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MaintenanceSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      floatingActionButton: vehicleId != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/maintenance/add'),
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            )
          : null,
      body: vehicleId == null
          ? const EmptyState(
              icon: Icons.build,
              title: 'No hay vehículo seleccionado',
              subtitle: 'Agrega o selecciona un vehículo primero',
            )
          : maintenancesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorState(
                message: err.toString(),
                onRetry: () => ref
                    .read(maintenancesNotifierProvider.notifier)
                    .loadMaintenances(),
              ),
              data: (maintenances) {
                if (maintenances.isEmpty) {
                  return EmptyState(
                    icon: Icons.build,
                    title: 'Sin mantenimientos',
                    subtitle: 'Registra el primer mantenimiento',
                    onAction: () => context.push('/maintenance/add'),
                    actionLabel: 'Registrar mantenimiento',
                  );
                }

                return RefreshIndicator(
                  onRefresh: ref
                      .read(maintenancesNotifierProvider.notifier)
                      .loadMaintenances,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: maintenances.length,
                    itemBuilder: (context, index) {
                      final maintenance = maintenances[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MaintenanceCard(
                          maintenance: maintenance,
                          onTap: () =>
                              context.push('/maintenance/${maintenance.id}'),
                          onEdit: () =>
                              context.push('/maintenance/${maintenance.id}/edit'),
                          onDelete: () async {
                            final confirmed = await showConfirmDialog(
                              context,
                              title: 'Eliminar mantenimiento',
                              message:
                                  '¿Eliminar "${maintenance.title}" y todos sus items?',
                              confirmLabel: 'Eliminar',
                              isDestructive: true,
                            );
                            if (confirmed == true && context.mounted) {
                              ref
                                  .read(maintenancesNotifierProvider.notifier)
                                  .remove(maintenance.id!);
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
}
