import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../settings/providers.dart';
import '../../settings/models/maintenance_category.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../models/maintenance.dart';
import '../models/workshop.dart';
import '../providers.dart';
import '../widgets/timeline_tile.dart';
import '../widgets/maintenance_card.dart';

class MaintenanceListScreen extends ConsumerStatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  ConsumerState<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen> {
  int? _selectedVehicleId;
  bool _showCompactView = false;

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
    final maintenancesAsync = ref.watch(maintenancesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos'),
        actions: [
          IconButton(
            icon: Icon(_showCompactView ? Icons.timeline : Icons.view_agenda),
            tooltip: _showCompactView ? 'Vista timeline' : 'Vista compacta',
            onPressed: () =>
                setState(() => _showCompactView = !_showCompactView),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/maintenance/search'),
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
                final filtered = _applyFilters(maintenances);
                final vehicles = vehiclesAsync.valueOrNull ?? [];

                if (filtered.isEmpty) {
                  return _buildEmptyState(vehicles);
                }

                return _showCompactView
                    ? _buildCardList(filtered)
                    : _buildTimeline(filtered, vehicles);
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

    final groups = <DateTime, List<Maintenance>>{};
    for (final m in maintenances) {
      final key = DateTime(m.date.year, m.date.month, m.date.day);
      groups.putIfAbsent(key, () => []).add(m);
    }
    final sortedGroups = groups.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final flatItems = <dynamic>[];
    for (final group in sortedGroups) {
      flatItems.add(group.key);
      flatItems.addAll(group.value);
    }

    return RefreshIndicator(
      onRefresh: ref
          .read(maintenancesNotifierProvider.notifier)
          .loadMaintenances,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: flatItems.length,
        itemBuilder: (context, index) {
          final item = flatItems[index];

          if (item is DateTime) {
            final nextItem = index + 1 < flatItems.length
                ? flatItems[index + 1]
                : null;
            final isLastGroup = nextItem is DateTime || nextItem == null;
            return _DateHeader(date: item, hasLine: !isLastGroup);
          }

          if (item is Maintenance) {
            final nextItem = index + 1 < flatItems.length
                ? flatItems[index + 1]
                : null;
            final isLastInGroup = nextItem is DateTime || nextItem == null;

            final vehicle = _findVehicle(vehicles, item.vehicleId);
            final workshop = _findWorkshop(workshops, item.workshopId);
            final items = itemsByMaintenance[item.id] ?? [];

            return TimelineTile(
              maintenance: item,
              items: items,
              vehicleName: vehicle?.name,
              vehicleType: vehicle?.type,
              workshopName: workshop?.name,
              workshopLocation: workshop?.location,
              showConnector: true,
              isLastInGroup: isLastInGroup,
              categoryMap: categoryMap,
              onTap: () => context.push('/maintenance/${item.id}'),
            );
          }

          return const SizedBox.shrink();
        },
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
    if (vehicles.length <= 1) return const SizedBox.shrink();

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
          children: [
            _chip(
              label: 'Todos',
              icon: Icons.filter_list,
              selected: _selectedVehicleId == null,
              onSelected: (_) => setState(() => _selectedVehicleId = null),
            ),
            const SizedBox(width: 6),
            ...sorted.map((v) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _chip(
                  label: v.name,
                  icon: _vehicleIcon(v.type),
                  selected: _selectedVehicleId == v.id,
                  onSelected: (_) => setState(() => _selectedVehicleId = v.id),
                ),
              );
            }),
          ],
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

  List<Maintenance> _applyFilters(List<Maintenance> maintenances) {
    if (_selectedVehicleId == null) return maintenances;
    return maintenances
        .where((m) => m.vehicleId == _selectedVehicleId)
        .toList();
  }

  Widget _buildEmptyState(List<Vehicle> vehicles) {
    final hasFilters = _selectedVehicleId != null;
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

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final bool hasLine;

  const _DateHeader({required this.date, required this.hasLine});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (hasLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleSmall,
                  children: [
                    TextSpan(
                      text: '${date.day} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: months[date.month]),
                    TextSpan(text: ' ${date.year}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
