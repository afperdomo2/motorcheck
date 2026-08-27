import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/providers.dart';
import '../../settings/models/maintenance_category.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../models/maintenance.dart';
import '../models/workshop.dart';
import '../providers.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/vehicle_ficha.dart';

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
          _buildVehicleSelector(context),
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

    final flat = _buildGroupedItems(maintenances);

    return RefreshIndicator(
      onRefresh: ref
          .read(maintenancesNotifierProvider.notifier)
          .loadMaintenances,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: flat.length,
        itemBuilder: (context, index) {
          final item = flat[index];

          if (item is _MonthHeader) {
            return item;
          }

          final maintenance = item as Maintenance;
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

  List<Object> _buildGroupedItems(List<Maintenance> maintenances) {
    final groups = <(int, int), List<Maintenance>>{};
    for (final m in maintenances) {
      final key = (m.date.year, m.date.month);
      groups.putIfAbsent(key, () => []).add(m);
    }

    final monthKeys = groups.keys.toList()
      ..sort((a, b) {
        final da = DateTime(a.$1, a.$2);
        final db = DateTime(b.$1, b.$2);
        return db.compareTo(da);
      });

    final flat = <Object>[];
    for (final key in monthKeys) {
      final items = groups[key]!..sort(_compareMileageThenDate);
      flat.add(_MonthHeader(year: key.$1, month: key.$2));
      flat.addAll(items);
    }
    return flat;
  }

  int _compareMileageThenDate(Maintenance a, Maintenance b) {
    final aKm = a.mileage;
    final bKm = b.mileage;
    if (aKm != null && bKm != null) {
      if (aKm != bKm) return bKm.compareTo(aKm);
      return b.date.compareTo(a.date);
    }
    if (aKm != null) return -1;
    if (bKm != null) return 1;
    return b.date.compareTo(a.date);
  }

  Widget _buildVehicleSelector(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.valueOrNull ?? [];
    if (vehicles.isEmpty) return const SizedBox.shrink();

    final selectedVehicleId = ref.watch(selectedVehicleIdProvider);

    Vehicle? selectedVehicle;
    for (final v in vehicles) {
      if (v.id == selectedVehicleId) {
        selectedVehicle = v;
        break;
      }
    }

    final theme = Theme.of(context);

    if (selectedVehicle == null) {
      return InkWell(
        onTap: () => _showVehicleSheet(context, vehicles),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                child: Icon(
                  Icons.directions_car,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Selecciona un vehículo',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(Icons.expand_more, color: theme.disabledColor),
            ],
          ),
        ),
      );
    }

    return VehicleFicha(
      vehicle: selectedVehicle,
      onTap: () => _showVehicleSheet(context, vehicles),
    );
  }

  Future<void> _showVehicleSheet(
    BuildContext context,
    List<Vehicle> vehicles,
  ) async {
    final selectedVehicleId = ref.read(selectedVehicleIdProvider);

    final sorted = List<Vehicle>.from(vehicles)
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });

    final result = await showModalBottomSheet<Vehicle>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Selecciona un vehículo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ...sorted.map((v) {
                final isSelected = v.id == selectedVehicleId;
                final typeColor = AppColors.forVehicleType(v.type);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: typeColor.withValues(alpha: 0.15),
                    child: Icon(_vehicleIcon(v.type), color: typeColor),
                  ),
                  title: Text(v.name),
                  subtitle: _vehicleSubtitle(v) != null
                      ? Text(_vehicleSubtitle(v)!)
                      : null,
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(v),
                );
              }),
            ],
          ),
        );
      },
    );

    if (result != null) {
      await ref
          .read(vehiclesNotifierProvider.notifier)
          .selectVehicle(result.id!);
    }
  }

  String? _vehicleSubtitle(Vehicle v) {
    final parts = <String>[];
    if (v.plate != null) parts.add(v.plate!);
    if (v.currentMileage != null) parts.add(formatMileage(v.currentMileage));
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  Workshop? _findWorkshop(List<Workshop> workshops, int? workshopId) {
    if (workshopId == null) return null;
    for (final w in workshops) {
      if (w.id == workshopId) return w;
    }
    return null;
  }
}

class _MonthHeader extends StatelessWidget {
  final int year;
  final int month;

  const _MonthHeader({required this.year, required this.month});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = formatMonthYearLong(DateTime(year, month));

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 18,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
