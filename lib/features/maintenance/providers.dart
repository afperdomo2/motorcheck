import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../vehicles/providers.dart';
import 'models/maintenance.dart';
import 'models/maintenance_item.dart';
import 'repository.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepository();
});

final maintenancesProvider = FutureProvider<List<Maintenance>>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  if (vehicleId == null) return [];
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getByVehicleId(vehicleId);
});

final maintenanceItemsProvider =
    FutureProvider.family<List<MaintenanceItem>, int>((
      ref,
      maintenanceId,
    ) async {
      final repository = ref.watch(maintenanceRepositoryProvider);
      return repository.getItems(maintenanceId);
    });

class MaintenancesNotifier extends Notifier<AsyncValue<List<Maintenance>>> {
  MaintenanceRepository get _repo => ref.read(maintenanceRepositoryProvider);

  @override
  AsyncValue<List<Maintenance>> build() {
    ref.listen(selectedVehicleIdProvider, (_, next) {
      if (next != null) loadMaintenances();
    });
    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId != null) loadMaintenances();
    return const AsyncValue.data([]);
  }

  Future<void> loadMaintenances() async {
    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) return;
    state = await AsyncValue.guard(() => _repo.getByVehicleId(vehicleId));
  }

  Future<void> add(Maintenance maintenance, List<MaintenanceItem> items) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(maintenance, items);
      final vehicleId = ref.read(selectedVehicleIdProvider)!;
      return _repo.getByVehicleId(vehicleId);
    });
  }

  Future<void> update(
    Maintenance maintenance,
    List<MaintenanceItem> items,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.update(maintenance, items);
      final vehicleId = ref.read(selectedVehicleIdProvider)!;
      return _repo.getByVehicleId(vehicleId);
    });
  }

  Future<void> remove(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.delete(id);
      final vehicleId = ref.read(selectedVehicleIdProvider)!;
      return _repo.getByVehicleId(vehicleId);
    });
  }
}

final maintenancesNotifierProvider =
    NotifierProvider<MaintenancesNotifier, AsyncValue<List<Maintenance>>>(
      MaintenancesNotifier.new,
    );
