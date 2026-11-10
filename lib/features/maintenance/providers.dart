import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../settings/providers.dart';
import '../settings/models/maintenance_category.dart';
import '../vehicles/providers.dart';
import '../vehicles/models/vehicle.dart';
import 'models/maintenance.dart';
import 'models/maintenance_item.dart';
import 'models/workshop.dart';
import 'repository.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepository();
});

final maintenancesProvider = FutureProvider<List<Maintenance>>((ref) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getAll();
});

final maintenanceItemsProvider =
    FutureProvider.family<List<MaintenanceItem>, int>((
      ref,
      maintenanceId,
    ) async {
      final repository = ref.watch(maintenanceRepositoryProvider);
      return repository.getItems(maintenanceId);
    });

final maintenanceByIdProvider = FutureProvider.family<Maintenance?, int>((
  ref,
  maintenanceId,
) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getById(maintenanceId);
});

final vehicleNamesProvider = FutureProvider<Map<int, Vehicle>>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  return {for (final v in vehicles) v.id!: v};
});

class MaintenancesNotifier extends Notifier<AsyncValue<List<Maintenance>>> {
  MaintenanceRepository get _repo => ref.read(maintenanceRepositoryProvider);

  @override
  AsyncValue<List<Maintenance>> build() {
    _load();
    return const AsyncValue.data([]);
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repo.getAll());
    ref.invalidate(workshopItemsProvider);
  }

  Future<void> loadMaintenances() => _load();

  Future<void> add(Maintenance maintenance, List<MaintenanceItem> items) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(maintenance, items);
      return _repo.getAll();
    });
    _invalidateDependentProviders();
  }

  Future<void> update(
    Maintenance maintenance,
    List<MaintenanceItem> items,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.update(maintenance, items);
      return _repo.getAll();
    });
    _invalidateDependentProviders();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    state = AsyncValue.data(await _repo.getAll());
    _invalidateDependentProviders();
  }

  void _invalidateDependentProviders() {
    ref.invalidate(maintenancesProvider);
    ref.invalidate(workshopItemsProvider);
    ref.invalidate(maintenanceByIdProvider);
    ref.invalidate(maintenanceItemsProvider);
    ref.invalidate(vehicleMaintenanceSummaryProvider);
    ref.invalidate(upcomingMaintenanceProvider);
    ref.invalidate(maintenanceAttentionCountProvider);
    ref.invalidate(vehicleNamesProvider);

    // El repositorio pudo subir el kilometraje del vehículo.
    ref.invalidate(vehiclesNotifierProvider);
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(selectedVehicleProvider);
  }
}

final vehicleMaintenanceSummaryProvider =
    FutureProvider.family<
      ({int count, double totalCost, DateTime? lastDate}),
      int
    >((ref, vehicleId) async {
      final repository = ref.watch(maintenanceRepositoryProvider);
      return repository.getMaintenanceSummary(vehicleId);
    });

final maintenancesNotifierProvider =
    NotifierProvider<MaintenancesNotifier, AsyncValue<List<Maintenance>>>(
      MaintenancesNotifier.new,
    );

final workshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getAll();
});

final workshopItemsProvider =
    FutureProvider.family<Map<int, List<MaintenanceItem>>, String>((
      ref,
      idsKey,
    ) async {
      if (idsKey.isEmpty) return {};
      final maintenanceIds = idsKey.split(',').map(int.parse).toList();
      final repository = ref.watch(maintenanceRepositoryProvider);
      final items = await repository.getItemsByMaintenanceIds(maintenanceIds);
      final result = <int, List<MaintenanceItem>>{};
      for (final item in items) {
        result.putIfAbsent(item.maintenanceId, () => []).add(item);
      }
      return result;
    });

class UpcomingMaintenance {
  final MaintenanceCategory category;
  final int? lastMileage;
  final int? lastDate;
  final int? remainingKm;
  final bool isOverdue;
  final bool isWarning;

  const UpcomingMaintenance({
    required this.category,
    this.lastMileage,
    this.lastDate,
    this.remainingKm,
    this.isOverdue = false,
    this.isWarning = false,
  });

  String statusLabel() {
    if (category.intervalKm == null) return 'Sin frecuencia';
    if (lastMileage == null) return 'Sin registro previo';
    if (isOverdue) {
      return remainingKm != null ? 'Vencido ${-remainingKm!} km' : 'Vencido';
    }
    if (remainingKm != null) return 'En $remainingKm km';
    return '';
  }

  String? lastDateFormatted() {
    if (lastDate == null) return null;
    return formatDate(DateTime.fromMillisecondsSinceEpoch(lastDate!));
  }
}

final maintenanceCategoryHistoryProvider =
    FutureProvider.family<
      List<CategoryHistoryEntry>,
      ({int vehicleId, String category})
    >((ref, args) async {
      final repository = ref.watch(maintenanceRepositoryProvider);
      return repository.getCategoryHistory(args.vehicleId, args.category);
    });

/// Cantidad de mantenimientos vencidos o próximos a vencer en todos los
/// vehículos. Se usa para el badge de la barra de navegación.
final maintenanceAttentionCountProvider = FutureProvider<int>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  var count = 0;

  for (final vehicle in vehicles) {
    final id = vehicle.id;
    if (id == null) continue;
    final upcoming = await ref.watch(upcomingMaintenanceProvider(id).future);
    count += upcoming.where((item) => item.isOverdue || item.isWarning).length;
  }

  return count;
});

final upcomingMaintenanceProvider =
    FutureProvider.family<List<UpcomingMaintenance>, int>((
      ref,
      vehicleId,
    ) async {
      final vehicle = await ref.watch(
        selectedVehicleProvider(vehicleId).future,
      );
      if (vehicle == null || vehicle.currentMileage == null) return [];

      final currentMileage = vehicle.currentMileage!;

      final catRepo = ref.read(maintenanceCategoryRepositoryProvider);
      final categories = await catRepo.getByVehicleType(vehicle.type);

      final maintRepo = ref.read(maintenanceRepositoryProvider);
      final result = <UpcomingMaintenance>[];

      for (final cat in categories) {
        if (cat.intervalKm == null) {
          result.add(UpcomingMaintenance(category: cat));
          continue;
        }

        final last = await maintRepo.getLastMileageByCategory(
          vehicleId,
          cat.key,
        );

        if (last.mileage == null) {
          result.add(
            UpcomingMaintenance(
              category: cat,
              lastDate: last.date?.millisecondsSinceEpoch,
            ),
          );
          continue;
        }

        final nextServiceKm = last.mileage! + cat.intervalKm!;
        final remainingKm = nextServiceKm - currentMileage;
        final warningKm = cat.warningKm ?? 0;
        final isOverdue = remainingKm <= 0;
        final isWarning = !isOverdue && remainingKm <= warningKm;

        result.add(
          UpcomingMaintenance(
            category: cat,
            lastMileage: last.mileage,
            lastDate: last.date?.millisecondsSinceEpoch,
            remainingKm: remainingKm,
            isOverdue: isOverdue,
            isWarning: isWarning,
          ),
        );
      }

      return result;
    });
