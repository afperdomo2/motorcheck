import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../settings/models/maintenance_category.dart';
import '../../settings/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';
import '../models/maintenance.dart';
import '../models/workshop.dart';
import '../providers.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/month_header.dart';
import '../widgets/vehicle_ficha.dart';

class MaintenanceListScreen extends ConsumerStatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  ConsumerState<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen> {
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
            tooltip: 'Buscar',
          ),
        ],
      ),
      floatingActionButton: selectedVehicleId != null
          ? FloatingActionButton.extended(
              onPressed: () =>
                  context.push('/maintenance/add?vehicleId=$selectedVehicleId'),
              tooltip: 'Registrar mantenimiento',
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            )
          : null,
      body: Column(
        children: [
          _buildVehicleSelector(context),
          Expanded(
            child: maintenancesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, _) => ErrorState(
                message: 'No se pudieron cargar los mantenimientos',
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
                  return EmptyState(
                    icon: Icons.directions_car,
                    title: 'Sin vehículos',
                    subtitle:
                        'Agrega un vehículo para registrar mantenimientos',
                    onAction: () => context.push('/vehicles/add'),
                    actionLabel: 'Agregar vehículo',
                  );
                }

                if (selectedVehicleId == null) {
                  return EmptyState(
                    icon: Icons.touch_app,
                    title: 'Selecciona un vehículo',
                    subtitle: 'Elige un vehículo para ver sus mantenimientos',
                    onAction: () => context.go('/vehicles'),
                    actionLabel: 'Ir a vehículos',
                  );
                }

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.build_outlined,
                    title: 'Sin mantenimientos',
                    subtitle:
                        'Registra el primer mantenimiento de este vehículo',
                    onAction: () => context.push(
                      '/maintenance/add?vehicleId=$selectedVehicleId',
                    ),
                    actionLabel: 'Registrar mantenimiento',
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
    final workshops = ref.watch(workshopsProvider).valueOrNull ?? [];
    final maintenanceIds = maintenances.map((m) => m.id!).toList()..sort();
    final itemsByMaintenance =
        ref
            .watch(workshopItemsProvider(maintenanceIds.join(',')))
            .valueOrNull ??
        {};
    final categories =
        ref.watch(maintenanceCategoriesProvider).valueOrNull ?? [];
    final categoryMap = <String, MaintenanceCategory>{
      for (final c in categories) c.key: c,
    };

    final flat = _buildGroupedItems(maintenances);

    return RefreshIndicator(
      onRefresh: ref
          .read(maintenancesNotifierProvider.notifier)
          .loadMaintenances,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl * 2,
        ),
        itemCount: flat.length,
        itemBuilder: (context, index) {
          final item = flat[index];

          if (item is MonthHeader) {
            return item;
          }

          final maintenance = item as Maintenance;
          final workshop = _findWorkshop(workshops, maintenance.workshopId);

          return MaintenanceCard(
            maintenance: maintenance,
            items: itemsByMaintenance[maintenance.id] ?? [],
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
      final total = items.fold<double>(
        0,
        (sum, m) => sum + m.maintenanceCost + m.totalPartsCost,
      );
      flat.add(MonthHeader(year: key.$1, month: key.$2, total: total));
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
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
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
      return Card(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: InkWell(
          onTap: () => _selectVehicle(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_car_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Selecciona un vehículo',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: VehicleFicha(
        vehicle: selectedVehicle,
        onTap: () => _selectVehicle(context),
      ),
    );
  }

  Future<void> _selectVehicle(BuildContext context) async {
    final result = await VehicleSelectorSheet.show(context);
    if (result != null) {
      await ref
          .read(vehiclesNotifierProvider.notifier)
          .selectVehicle(result.id!);
    }
  }

  Workshop? _findWorkshop(List<Workshop> workshops, int? workshopId) {
    if (workshopId == null) return null;
    for (final w in workshops) {
      if (w.id == workshopId) return w;
    }
    return null;
  }
}
