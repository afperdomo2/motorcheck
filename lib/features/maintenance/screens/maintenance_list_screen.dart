import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../settings/providers.dart';
import '../../settings/models/maintenance_category.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../models/maintenance.dart';
import '../models/workshop.dart';
import '../providers.dart';
import '../widgets/maintenance_card.dart';

class MaintenanceListScreen extends ConsumerStatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  ConsumerState<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen> {
  IconData _vehicleIcon(String type) => switch (type) {
    'motorcycle' => Icons.motorcycle,
    'bike' => Icons.pedal_bike,
    'truck' => Icons.local_shipping,
    'other' => Icons.help_outline,
    _ => Icons.directions_car,
  };

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final selectedVehicleId = ref.watch(selectedVehicleIdProvider);
    final maintenancesAsync = ref.watch(maintenancesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/maintenance/search'),
          ),
        ],
      ),
      floatingActionButton: selectedVehicleId != null
          ? FloatingActionButton(
              onPressed: () =>
                  context.push('/maintenance/add?vehicleId=$selectedVehicleId'),
              tooltip: 'Agregar mantenimiento',
              child: const Icon(Icons.build),
            )
          : null,
      body: Column(
        children: [
          _buildFilterBar(context),
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
                final filtered = maintenances
                    .where((m) => m.vehicleId == selectedVehicleId)
                    .toList();
                final vehicles = vehiclesAsync.valueOrNull ?? [];

                if (vehicles.isEmpty) {
                  return const EmptyState(
                    icon: Icons.directions_car,
                    title: 'No hay vehículos',
                    subtitle: 'Agrega un vehículo primero',
                  );
                }

                if (selectedVehicleId == null) {
                  return const EmptyState(
                    icon: Icons.touch_app,
                    title: 'Selecciona un vehículo',
                    subtitle: 'Elige un vehículo para ver sus mantenimientos',
                  );
                }

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.build,
                    title: 'Sin mantenimientos',
                    subtitle: 'Registra el primer mantenimiento',
                  );
                }

                return _buildCardList(filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(List<Maintenance> maintenances) {
    final workshopsAsync = ref.watch(workshopsProvider);
    final workshops = workshopsAsync.valueOrNull ?? [];
    final maintenanceIds = maintenances.map((m) => m.id!).toList()..sort();
    final itemsAsync = ref.watch(
      workshopItemsProvider(maintenanceIds.join(',')),
    );
    final itemsByMaintenance = itemsAsync.valueOrNull ?? {};
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
    final categoryMap = <String, MaintenanceCategory>{
      for (final c
          in (categoriesAsync.valueOrNull ?? []).cast<MaintenanceCategory>())
        c.key: c,
    };

    final sorted = List<Maintenance>.from(maintenances)
      ..sort((a, b) => b.date.compareTo(a.date));

    return RefreshIndicator(
      onRefresh: ref
          .read(maintenancesNotifierProvider.notifier)
          .loadMaintenances,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final maintenance = sorted[index];
          final workshop = _findWorkshop(workshops, maintenance.workshopId);
          final items = itemsByMaintenance[maintenance.id] ?? [];

          return MaintenanceCard(
            maintenance: maintenance,
            items: items,
            workshopName: workshop?.name,
            workshopLocation: workshop?.location,
            categoryMap: categoryMap,
            onTap: () => context.push('/maintenance/${maintenance.id}'),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.valueOrNull ?? [];
    if (vehicles.isEmpty) return const SizedBox.shrink();

    final selectedVehicleId = ref.watch(selectedVehicleIdProvider);

    final sorted = List<Vehicle>.from(vehicles)
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sorted.map((v) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _chip(
                label: v.name,
                icon: _vehicleIcon(v.type),
                selected: selectedVehicleId == v.id,
                onSelected: (_) => ref
                    .read(vehiclesNotifierProvider.notifier)
                    .selectVehicle(v.id!),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      visualDensity: VisualDensity.compact,
      labelStyle: const TextStyle(fontSize: 12),
      showCheckmark: false,
    );
  }

  Workshop? _findWorkshop(List<Workshop> workshops, int? workshopId) {
    if (workshopId == null) return null;
    for (final w in workshops) {
      if (w.id == workshopId) return w;
    }
    return null;
  }
}
