import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../maintenance/providers.dart';
import '../vehicles/providers.dart';
import 'models/fuel_log.dart';
import 'repository.dart';

final fuelRepositoryProvider = Provider<FuelRepository>((ref) {
  return FuelRepository();
});

final fuelLogsProvider = FutureProvider.family<List<FuelLog>, int>((
  ref,
  vehicleId,
) async {
  return ref.watch(fuelRepositoryProvider).getByVehicleId(vehicleId);
});

final fuelStatsProvider = FutureProvider.family<FuelStats, int>((
  ref,
  vehicleId,
) async {
  return ref.watch(fuelRepositoryProvider).getStats(vehicleId);
});

final fuelLogByIdProvider = FutureProvider.family<FuelLog?, int>((
  ref,
  id,
) async {
  return ref.watch(fuelRepositoryProvider).getById(id);
});

class FuelLogsNotifier extends Notifier<AsyncValue<void>> {
  FuelRepository get _repo => ref.read(fuelRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(FuelLog log) async {
    state = const AsyncValue.loading();
    try {
      if (log.id == null) {
        await _repo.insert(log);
      } else {
        await _repo.update(log);
      }
      _invalidate(log.vehicleId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(int id, int vehicleId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      _invalidate(vehicleId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void _invalidate(int vehicleId) {
    ref.invalidate(fuelLogsProvider(vehicleId));
    ref.invalidate(fuelStatsProvider(vehicleId));
    ref.invalidate(fuelLogByIdProvider);
    ref.invalidate(vehicleMileageReadingsProvider(vehicleId));
    ref.invalidate(mileageStatsProvider(vehicleId));
    ref.invalidate(selectedVehicleProvider(vehicleId));
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(upcomingMaintenanceProvider);
    ref.invalidate(maintenanceAttentionCountProvider);
  }
}

final fuelLogsNotifierProvider =
    NotifierProvider<FuelLogsNotifier, AsyncValue<void>>(FuelLogsNotifier.new);
