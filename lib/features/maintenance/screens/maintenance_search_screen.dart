import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/search.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../../settings/providers.dart';
import '../../settings/models/maintenance_category.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';
import '../models/workshop.dart';
import '../providers.dart';
import '../widgets/month_header.dart';

IconData _searchVehicleIcon(String? type) => switch (type) {
  'motorcycle' => Icons.motorcycle,
  'bike' => Icons.pedal_bike,
  'scooter' => Icons.electric_scooter,
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

  bool get _hasFilters =>
      _query.isNotEmpty ||
      _selectedPeriod != null ||
      _selectedVehicleId != null;

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
    final categoryMap = <String, MaintenanceCategory>{
      for (final c
          in (ref.watch(maintenanceCategoriesProvider).valueOrNull ?? [])
              .cast<MaintenanceCategory>())
        c.key: c,
    };
    final vehicleMap = {for (final v in vehicles) v.id!: v};
    final allMaintenances = maintenancesAsync.valueOrNull ?? <Maintenance>[];
    final allIds = allMaintenances.map((m) => m.id!).toList()..sort();
    final itemsByMaintenance =
        ref.watch(workshopItemsProvider(allIds.join(','))).valueOrNull ??
        const <int, List<MaintenanceItem>>{};

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar búsqueda',
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context, vehicles),
          Expanded(
            child: maintenancesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorState(
                message: 'No se pudieron cargar los mantenimientos',
                onRetry: () => ref.invalidate(maintenancesProvider),
              ),
              data: (maintenances) {
                if (maintenances.isEmpty) {
                  final vehicleId =
                      _selectedVehicleId ?? ref.read(selectedVehicleIdProvider);
                  return EmptyState(
                    icon: Icons.build_outlined,
                    title: 'Sin mantenimientos',
                    subtitle: 'Registra el primer mantenimiento de un vehículo',
                    onAction: vehicleId != null
                        ? () => context.push(
                            '/maintenance/add?vehicleId=$vehicleId',
                          )
                        : () => context.go('/vehicles'),
                    actionLabel: vehicleId != null
                        ? 'Registrar mantenimiento'
                        : 'Ir a vehículos',
                  );
                }

                final filtered = _applyFilters(
                  maintenances,
                  workshops,
                  vehicleMap,
                  itemsByMaintenance,
                  categoryMap,
                );

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    subtitle: 'Prueba con otro término o cambia los filtros',
                    onAction: _hasFilters ? _clearFilters : null,
                    actionLabel: 'Limpiar filtros',
                  );
                }

                return _buildResultsList(
                  filtered,
                  workshops,
                  vehicleMap,
                  categoryMap,
                  itemsByMaintenance,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Buscar por nota, taller o categoría…',
        border: InputBorder.none,
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      ),
      onChanged: (v) => setState(() => _query = v),
    );
  }

  Widget _buildFilters(BuildContext context, List<Vehicle> vehicles) {
    final theme = Theme.of(context);
    final hasVehicles = vehicles.length > 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Periodo', style: theme.textTheme.labelMedium),
              const Spacer(),
              if (_hasFilters)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _periodChip(null, 'Todas'),
                const SizedBox(width: AppSpacing.sm),
                _periodChip('month', 'Este mes'),
                const SizedBox(width: AppSpacing.sm),
                _periodChip('3months', '3 meses'),
                const SizedBox(width: AppSpacing.sm),
                _periodChip('year', 'Este año'),
              ],
            ),
          ),
          if (hasVehicles) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Vehículo', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _vehicleChip(null, vehicles),
                  const SizedBox(width: AppSpacing.sm),
                  ...vehicles.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _vehicleChip(v.id, vehicles),
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

  void _clearFilters() {
    _controller.clear();
    setState(() {
      _query = '';
      _selectedPeriod = null;
      _selectedVehicleId = null;
    });
  }

  Widget _periodChip(String? period, String label) {
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

  Widget _vehicleChip(int? vehicleId, List<Vehicle> vehicles) {
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
    Map<int, List<MaintenanceItem>> itemsByMaintenance,
    Map<String, MaintenanceCategory> categoryMap,
  ) {
    final now = DateTime.now();
    final cutoff = switch (_selectedPeriod) {
      'month' => now.subtract(const Duration(days: 30)),
      '3months' => now.subtract(const Duration(days: 90)),
      'year' => now.subtract(const Duration(days: 365)),
      _ => null,
    };
    final query = normalizeForSearch(_query);

    return maintenances.where((m) {
      if (_selectedVehicleId != null && m.vehicleId != _selectedVehicleId) {
        return false;
      }
      if (cutoff != null && m.date.isBefore(cutoff)) return false;
      if (query.isEmpty) return true;

      final workshop = workshops.where((w) => w.id == m.workshopId).firstOrNull;
      final vehicle = vehicleMap[m.vehicleId];
      final items = itemsByMaintenance[m.id] ?? const <MaintenanceItem>[];
      final categoryText = items
          .map((i) => categoryMap[i.category]?.name ?? i.category)
          .join(' ');
      final haystack = normalizeForSearch(
        [
          formatDate(m.date),
          formatDisplayDate(m.date),
          formatMileage(m.mileage),
          m.notes ?? '',
          workshop?.name ?? '',
          workshop?.location ?? '',
          vehicle?.name ?? '',
          categoryText,
        ].join(' '),
      );

      return haystack.contains(query);
    }).toList();
  }

  Widget _buildResultsList(
    List<Maintenance> maintenances,
    List<Workshop> workshops,
    Map<int, Vehicle> vehicleMap,
    Map<String, MaintenanceCategory> categoryMap,
    Map<int, List<MaintenanceItem>> itemsByMaintenance,
  ) {
    final flat = _buildGroupedItems(maintenances);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      itemCount: flat.length,
      itemBuilder: (context, index) {
        final item = flat[index];
        if (item is MonthHeader) return item;

        final maintenance = item as Maintenance;
        final items = itemsByMaintenance[maintenance.id] ?? const [];
        final total = maintenance.maintenanceCost + maintenance.totalPartsCost;
        final workshop = workshops
            .where((w) => w.id == maintenance.workshopId)
            .firstOrNull;
        final vehicle = vehicleMap[maintenance.vehicleId];
        final categoryKeys = items.map((i) => i.category).toSet().toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Card(
            child: ListTile(
              onTap: () => context.push('/maintenance/${maintenance.id}'),
              title: Row(
                children: [
                  Icon(
                    _searchVehicleIcon(vehicle?.type),
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatShortDate(maintenance.date),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (categoryKeys.isNotEmpty)
                        Text(
                          categoryKeys
                              .map((k) => categoryMap[k]?.name ?? k)
                              .join(', '),
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  if (workshop != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.handyman,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
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
            ),
          ),
        );
      },
    );
  }

  List<Object> _buildGroupedItems(List<Maintenance> maintenances) {
    final groups = <(int, int), List<Maintenance>>{};
    for (final m in maintenances) {
      groups.putIfAbsent((m.date.year, m.date.month), () => []).add(m);
    }

    final monthKeys = groups.keys.toList()
      ..sort((a, b) {
        final da = DateTime(a.$1, a.$2);
        final db = DateTime(b.$1, b.$2);
        return db.compareTo(da);
      });

    final flat = <Object>[];
    for (final key in monthKeys) {
      final items = groups[key]!..sort((a, b) => b.date.compareTo(a.date));
      final total = items.fold<double>(
        0,
        (sum, m) => sum + m.maintenanceCost + m.totalPartsCost,
      );
      flat.add(MonthHeader(year: key.$1, month: key.$2, total: total));
      flat.addAll(items);
    }
    return flat;
  }
}
