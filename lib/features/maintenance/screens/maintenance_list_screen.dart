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
import '../categories.dart';
import '../models/maintenance.dart';
import '../models/workshop.dart';
import '../providers.dart';
import '../widgets/timeline_tile.dart';
import '../widgets/maintenance_search_delegate.dart';
import '../../../core/utils/formatters.dart';

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

                return _buildTimeline(filtered, vehicles);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(
    List<Maintenance> maintenances,
    List<Vehicle> vehicles,
  ) {
    final workshopsAsync = ref.watch(workshopsProvider);
    final workshops = workshopsAsync.valueOrNull ?? [];
    final maintenanceIds = maintenances.map((m) => m.id!).toList();
    final itemsAsync = ref.watch(workshopItemsProvider(maintenanceIds));
    final itemsByMaintenance = itemsAsync.valueOrNull ?? {};

    return RefreshIndicator(
      onRefresh: ref
          .read(maintenancesNotifierProvider.notifier)
          .loadMaintenances,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: maintenances.length,
        itemBuilder: (context, index) {
          final m = maintenances[index];
          final vehicle = _findVehicle(vehicles, m.vehicleId);
          final workshop = _findWorkshop(workshops, m.workshopId);
          final items = itemsByMaintenance[m.id] ?? [];
          final vehicleName = vehicle?.name;
          final vehicleType = vehicle?.type;
          final workshopName = workshop?.name;
          final workshopLocation = workshop?.location;
          final dateStr = formatDate(m.date);

          return TimelineTile(
            maintenance: m,
            items: items,
            vehicleName: vehicleName,
            vehicleType: vehicleType,
            workshopName: workshopName,
            workshopLocation: workshopLocation,
            isLast: index == maintenances.length - 1,
            onTap: () => context.push('/maintenance/${m.id}'),
            onEdit: () => context.push('/maintenance/${m.id}/edit'),
            onDelete: () async {
              final dateId = dateStr;
              final vehicleId = vehicleName ?? 'Vehículo';
              final confirmed = await showConfirmDialog(
                context,
                title: 'Eliminar mantenimiento',
                message:
                    '¿Eliminar el mantenimiento del $dateId ($vehicleId) y todos sus items?',
                confirmLabel: 'Eliminar',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                ref.read(maintenancesNotifierProvider.notifier).remove(m.id!);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool hasMultipleVehicles) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.valueOrNull ?? [];

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
              ...vehicles.map((v) {
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
            ..._allCategoryFilters(vehicles).map((cat) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  MaintenanceCategories.label(cat),
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

  List<String> _allCategoryFilters(List<Vehicle> vehicles) {
    final selectedVehicle = vehicles.where(
      (v) => _selectedVehicleId == null || v.id == _selectedVehicleId,
    );
    final types = selectedVehicle.map((v) => v.type).toSet();
    if (types.isEmpty) {
      return MaintenanceCategories.all.map((c) => c.key).toList();
    }
    final categories = <String>{};
    for (final type in types) {
      categories.addAll(
        MaintenanceCategories.forVehicleType(type).map((c) => c.key),
      );
    }
    return categories.toList()..sort();
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
      filtered = filtered.where((m) {
        return _categoryContains(_selectedCategory!, m.id ?? 0);
      }).toList();
    }
    return filtered;
  }

  bool _categoryContains(String category, int maintenanceId) {
    return true;
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

  Workshop? _findWorkshop(List<Workshop> workshops, int? workshopId) {
    if (workshopId == null) return null;
    for (final w in workshops) {
      if (w.id == workshopId) return w;
    }
    return null;
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
