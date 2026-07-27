import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../categories.dart';
import '../models/maintenance.dart';
import '../models/workshop.dart';
import '../providers.dart';

IconData _searchVehicleIcon(String? type) => switch (type) {
  'motorcycle' => Icons.motorcycle,
  'bike' => Icons.pedal_bike,
  'truck' => Icons.local_shipping,
  'other' => Icons.help_outline,
  _ => Icons.directions_car,
};

class MaintenanceSearchScreen extends ConsumerStatefulWidget {
  const MaintenanceSearchScreen({super.key});

  @override
  ConsumerState<MaintenanceSearchScreen> createState() =>
      _MaintenanceSearchScreenState();
}

class _MaintenanceSearchScreenState
    extends ConsumerState<MaintenanceSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String? _selectedPeriod;
  int? _selectedVehicleId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maintenancesAsync = ref.watch(maintenancesProvider);
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    final workshops = ref.watch(workshopsProvider).valueOrNull ?? [];
    final vehicleMap = {for (final v in vehicles) v.id!: v};

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar mantenimiento...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(context, vehicles),
          Expanded(
            child: maintenancesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (maintenances) {
                final filtered = _applyFilters(
                  maintenances,
                  workshops,
                  vehicleMap,
                );

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _query.isEmpty &&
                                  _selectedPeriod == null &&
                                  _selectedVehicleId == null
                              ? 'Escribe para buscar'
                              : 'Sin resultados',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return _buildResultsList(filtered, workshops, vehicleMap);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, List<Vehicle> vehicles) {
    final hasVehicles = vehicles.length > 1;
    if (vehicles.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _periodChip(context, null, 'Todas'),
                const SizedBox(width: 6),
                _periodChip(context, 'month', 'Este mes'),
                const SizedBox(width: 6),
                _periodChip(context, '3months', '3 meses'),
                const SizedBox(width: 6),
                _periodChip(context, 'year', 'Este año'),
              ],
            ),
          ),
          if (hasVehicles) ...[
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _vehicleChip(context, null, vehicles),
                  const SizedBox(width: 6),
                  ...vehicles.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _vehicleChip(context, v.id, vehicles),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _periodChip(BuildContext context, String? period, String label) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _selectedPeriod == period,
      onSelected: (_) {
        setState(
          () => _selectedPeriod = _selectedPeriod == period ? null : period,
        );
      },
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }

  Widget _vehicleChip(
    BuildContext context,
    int? vehicleId,
    List<Vehicle> vehicles,
  ) {
    final vehicle = vehicleId != null
        ? vehicles.where((v) => v.id == vehicleId).firstOrNull
        : null;
    final label = vehicle?.name ?? 'Todos';
    final icon = vehicleId != null
        ? _searchVehicleIcon(vehicle?.type)
        : Icons.filter_list;

    return FilterChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _selectedVehicleId == vehicleId,
      onSelected: (_) {
        setState(
          () => _selectedVehicleId = _selectedVehicleId == vehicleId
              ? null
              : vehicleId,
        );
      },
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }

  List<Maintenance> _applyFilters(
    List<Maintenance> maintenances,
    List<Workshop> workshops,
    Map<int, Vehicle> vehicleMap,
  ) {
    var filtered = maintenances.where((m) {
      final now = DateTime.now();
      final date = m.date;

      if (_selectedVehicleId != null && m.vehicleId != _selectedVehicleId) {
        return false;
      }

      if (_selectedPeriod != null) {
        final cutoff = switch (_selectedPeriod) {
          'month' => now.subtract(const Duration(days: 30)),
          '3months' => now.subtract(const Duration(days: 90)),
          'year' => now.subtract(const Duration(days: 365)),
          _ => DateTime(2000),
        };
        if (date.isBefore(cutoff)) return false;
      }

      return true;
    }).toList();

    final q = _query.toLowerCase().trim();
    if (q.isNotEmpty) {
      filtered = filtered.where((m) {
        final dateStr = formatDate(m.date).toLowerCase();
        final notesStr = (m.notes ?? '').toLowerCase();
        final workshop = workshops
            .where((w) => w.id == m.workshopId)
            .firstOrNull;
        final workshopName = (workshop?.name ?? '').toLowerCase();
        final workshopLocation = (workshop?.location ?? '').toLowerCase();
        final vehicle = vehicleMap[m.vehicleId];
        final vehicleName = (vehicle?.name ?? '').toLowerCase();

        return dateStr.contains(q) ||
            notesStr.contains(q) ||
            workshopName.contains(q) ||
            workshopLocation.contains(q) ||
            vehicleName.contains(q);
      }).toList();
    }

    return filtered;
  }

  Widget _buildResultsList(
    List<Maintenance> maintenances,
    List<Workshop> workshops,
    Map<int, Vehicle> vehicleMap,
  ) {
    final maintenanceIds = maintenances.map((m) => m.id!).toList()..sort();
    final itemsAsync = ref.watch(
      workshopItemsProvider(maintenanceIds.join(',')),
    );
    final itemsByMaintenance = itemsAsync.valueOrNull ?? {};

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: maintenances.length,
      itemBuilder: (context, index) {
        final maintenance = maintenances[index];
        final items = itemsByMaintenance[maintenance.id] ?? [];
        final total = maintenance.maintenanceCost + maintenance.totalPartsCost;
        final workshop = workshops
            .where((w) => w.id == maintenance.workshopId)
            .firstOrNull;
        final vehicle = vehicleMap[maintenance.vehicleId];
        final categoryKeys = items.map((i) => i.category).toSet().toList();

        return ListTile(
          onTap: () => context.push('/maintenance/${maintenance.id}'),
          title: Row(
            children: [
              Icon(
                _searchVehicleIcon(vehicle?.type),
                size: 18,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  vehicle?.name ?? 'Vehículo',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (total > 0)
                Text(
                  formatCurrency(total),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    formatDisplayDate(maintenance.date),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (categoryKeys.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        categoryKeys
                            .map((k) => MaintenanceCategories.label(k))
                            .join(', '),
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (workshop != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.handyman,
                      size: 12,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        workshop.location != null &&
                                workshop.location!.isNotEmpty
                            ? '${workshop.name} · ${workshop.location}'
                            : workshop.name,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
        );
      },
    );
  }
}
