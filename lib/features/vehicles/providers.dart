import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mileage_repository.dart';
import 'models/mileage_reading.dart';
import 'models/vehicle.dart';
import 'repository.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

final mileageRepositoryProvider = Provider<MileageRepository>((ref) {
  return MileageRepository();
});

final vehicleMileageReadingsProvider =
    FutureProvider.family<List<MileageReading>, int>((ref, vehicleId) async {
      return ref.watch(mileageRepositoryProvider).getByVehicleId(vehicleId);
    });

final mileageStatsProvider = FutureProvider.family<MileageStats, int>((
  ref,
  vehicleId,
) async {
  return ref.watch(mileageRepositoryProvider).getStats(vehicleId);
});

final selectedVehicleIdProvider = StateProvider<int?>((ref) => null);

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getAll();
});

final defaultVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getDefault();
});

final selectedVehicleProvider = FutureProvider.family<Vehicle?, int>((
  ref,
  id,
) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getById(id);
});

class VehiclesNotifier extends Notifier<AsyncValue<List<Vehicle>>> {
  VehicleRepository get _repo => ref.read(vehicleRepositoryProvider);

  @override
  AsyncValue<List<Vehicle>> build() {
    loadVehicles();
    return const AsyncValue.loading();
  }

  Future<void> loadVehicles() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final vehicles = await _repo.getAll();
      final selectedId = ref.read(selectedVehicleIdProvider);
      if (vehicles.isNotEmpty &&
          (selectedId == null || !vehicles.any((v) => v.id == selectedId))) {
        final lastSelectedId = await _repo.getLastSelectedId();
        final initialId = _resolveInitialVehicleId(vehicles, lastSelectedId);
        if (initialId != null) {
          ref.read(selectedVehicleIdProvider.notifier).state = initialId;
        }
      }
      return vehicles;
    });
  }

  /// Prioriza el último vehículo seleccionado, luego el predeterminado y, por
  /// último, el primero de la lista.
  int? _resolveInitialVehicleId(List<Vehicle> vehicles, int? lastSelectedId) {
    if (lastSelectedId != null && vehicles.any((v) => v.id == lastSelectedId)) {
      return lastSelectedId;
    }
    for (final vehicle in vehicles) {
      if (vehicle.isDefault) return vehicle.id;
    }
    return vehicles.first.id;
  }

  Future<int> add(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repo.insert(vehicle);
      if (vehicle.currentMileage != null) {
        await ref
            .read(mileageRepositoryProvider)
            .addReading(
              vehicleId: id,
              mileage: vehicle.currentMileage!,
              source: 'manual',
            );
      }
      final vehicles = await _repo.getAll();
      if (vehicles.length == 1) {
        ref.read(selectedVehicleIdProvider.notifier).state = id;
      }
      if (vehicle.isDefault) {
        await _repo.setDefault(id);
      }
      state = AsyncValue.data(vehicles);
      ref.invalidate(vehiclesProvider);
      ref.invalidate(defaultVehicleProvider);
      ref.invalidate(selectedVehicleProvider);
      ref.invalidate(vehicleMileageReadingsProvider(id));
      ref.invalidate(mileageStatsProvider(id));
      return id;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> update(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final previous = await _repo.getById(vehicle.id!);
      await _repo.update(vehicle);
      if (vehicle.currentMileage != null &&
          vehicle.currentMileage != previous?.currentMileage) {
        await ref
            .read(mileageRepositoryProvider)
            .addReading(
              vehicleId: vehicle.id!,
              mileage: vehicle.currentMileage!,
              source: 'manual',
            );
      }
      if (vehicle.isDefault) {
        await _repo.setDefault(vehicle.id!);
      }
      return _repo.getAll();
    });
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(selectedVehicleProvider(vehicle.id!));
    ref.invalidate(vehicleMileageReadingsProvider(vehicle.id!));
    ref.invalidate(mileageStatsProvider(vehicle.id!));
  }

  Future<void> updateMileage(int vehicleId, int mileage) async {
    await ref
        .read(mileageRepositoryProvider)
        .addReading(vehicleId: vehicleId, mileage: mileage);
    state = AsyncValue.data(await _repo.getAll());
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(selectedVehicleProvider(vehicleId));
    ref.invalidate(vehicleMileageReadingsProvider(vehicleId));
    ref.invalidate(mileageStatsProvider(vehicleId));
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    final vehicles = await _repo.getAll();
    final selectedId = ref.read(selectedVehicleIdProvider);
    if (vehicles.isEmpty) {
      ref.read(selectedVehicleIdProvider.notifier).state = null;
    } else if (selectedId == id) {
      ref.read(selectedVehicleIdProvider.notifier).state = vehicles.first.id;
    }
    state = AsyncValue.data(vehicles);
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(selectedVehicleProvider);
  }

  Future<void> clearDefault() async {
    await _repo.clearDefault();
    state.whenData((vehicles) {
      final updated = vehicles
          .map((v) => v.copyWith(isDefault: false))
          .toList();
      updated.sort(_compareVehicles);
      state = AsyncValue.data(updated);
    });
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
  }

  Future<void> setDefault(int id) async {
    await _repo.setDefault(id);
    state.whenData((vehicles) {
      final updated = vehicles
          .map((v) => v.copyWith(isDefault: v.id == id))
          .toList();
      updated.sort(_compareVehicles);
      state = AsyncValue.data(updated);
    });
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
  }

  static int _compareVehicles(Vehicle a, Vehicle b) {
    if (a.isDefault && !b.isDefault) return -1;
    if (!a.isDefault && b.isDefault) return 1;
    return a.name.compareTo(b.name);
  }

  Future<void> selectVehicle(int id) async {
    await _repo.markLastSelected(id);
    ref.read(selectedVehicleIdProvider.notifier).state = id;
  }
}

final vehiclesNotifierProvider =
    NotifierProvider<VehiclesNotifier, AsyncValue<List<Vehicle>>>(
      VehiclesNotifier.new,
    );
