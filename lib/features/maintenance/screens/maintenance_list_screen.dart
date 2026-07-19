import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../models/maintenance.dart';
import '../providers.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/maintenance_search_delegate.dart';

class MaintenanceListScreen extends ConsumerStatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  ConsumerState<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen> {
  int? _selectedVehicleId;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final maintenancesAsync = ref.watch(maintenancesNotifierProvider);
    final hasMultipleVehicles = (vehiclesAsync.valueOrNull?.length ?? 0) > 1;

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMaintenance(context),
        tooltip: 'Agregar mantenimiento',
        child: const Icon(Icons.build),
      ),
      body: Column(
        children: [
          _buildFilterBar(context, hasMultipleVehicles),
          Expanded(
            child: maintenancesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorState(
                message: err.toString(),
                onRetry: () => ref
                    .read(maintenancesNotifierProvider.notifier)
                    .loadMaintenances(),
              ),
              data: (maintenances) {
                final filtered = _applyFilters(maintenances);
                final vehicles = vehiclesAsync.valueOrNull ?? [];

                if (filtered.isEmpty) {
                  return _buildEmptyState(vehicles);
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
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final m = filtered[index];
                      final vehicle = _findVehicle(vehicles, m.vehicleId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MaintenanceCard(
                          maintenance: m,
                          vehicleName: vehicle?.name,
                          onTap: () => context.push('/maintenance/${m.id}'),
                          onEdit: () =>
                              context.push('/maintenance/${m.id}/edit'),
                          onDelete: () async {
                            final confirmed = await showConfirmDialog(
                              context,
                              title: 'Eliminar mantenimiento',
                              message:
                                  '¿Eliminar "${m.title}" y todos sus items?',
                              confirmLabel: 'Eliminar',
                              isDestructive: true,
                            );
                            if (confirmed == true && context.mounted) {
                              ref
                                  .read(maintenancesNotifierProvider.notifier)
                                  .remove(m.id!);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool hasMultipleVehicles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (hasMultipleVehicles) ...[
              _chip(
                'Todos',
                _selectedVehicleId == null,
                (_) => setState(() => _selectedVehicleId = null),
              ),
              const SizedBox(width: 6),
              ...(ref.watch(vehiclesProvider).valueOrNull ?? []).map((v) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _chip(
                    v.name,
                    _selectedVehicleId == v.id,
                    (_) => setState(() => _selectedVehicleId = v.id),
                  ),
                );
              }),
              const SizedBox(width: 12),
            ],
            _chip(
              'Todas',
              _selectedCategory == null,
              (_) => setState(() => _selectedCategory = null),
            ),
            const SizedBox(width: 6),
            ...['oil', 'tires', 'filters', 'brakes', 'general'].map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  _categoryLabel(cat),
                  _selectedCategory == cat,
                  (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }

  List<Maintenance> _applyFilters(List<Maintenance> maintenances) {
    var filtered = maintenances;
    if (_selectedVehicleId != null) {
      filtered = filtered
          .where((m) => m.vehicleId == _selectedVehicleId)
          .toList();
    }
    if (_selectedCategory != null) {
      final label = _categoryLabel(_selectedCategory!).toLowerCase();
      filtered = filtered.where((m) {
        return m.title.toLowerCase().contains(label);
      }).toList();
    }
    return filtered;
  }

  Widget _buildEmptyState(List<Vehicle> vehicles) {
    final hasFilters = _selectedVehicleId != null || _selectedCategory != null;
    if (vehicles.isEmpty) {
      return const EmptyState(
        icon: Icons.build,
        title: 'No hay vehículos',
        subtitle: 'Agrega un vehículo primero',
      );
    }
    if (hasFilters) {
      return EmptyState(
        icon: Icons.filter_list,
        title: 'Sin resultados',
        subtitle: 'Intenta con otros filtros',
        onAction: () => setState(() {
          _selectedVehicleId = null;
          _selectedCategory = null;
        }),
        actionLabel: 'Limpiar filtros',
      );
    }
    return const EmptyState(
      icon: Icons.build,
      title: 'Sin mantenimientos',
      subtitle: 'Registra el primer mantenimiento',
    );
  }

  Vehicle? _findVehicle(List<Vehicle> vehicles, int vehicleId) {
    for (final v in vehicles) {
      if (v.id == vehicleId) return v;
    }
    return null;
  }

  String _categoryLabel(String cat) {
    return switch (cat) {
      'oil' => 'Aceite',
      'tires' => 'Llantas',
      'filters' => 'Filtros',
      'brakes' => 'Frenos',
      'general' => 'General',
      _ => cat,
    };
  }

  Future<void> _addMaintenance(BuildContext context) async {
    final vehicles = ref.read(vehiclesProvider).valueOrNull ?? [];
    if (vehicles.isEmpty) return;

    if (vehicles.length == 1) {
      if (context.mounted) {
        context.push('/maintenance/add?vehicleId=${vehicles.first.id}');
      }
      return;
    }

    final selected = await VehicleSelectorSheet.show(context);
    if (selected != null && context.mounted) {
      context.push('/maintenance/add?vehicleId=${selected.id}');
    }
  }
}
