import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/vehicle.dart';
import 'repository.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
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
        final defaultVehicle = await _repo.getDefault();
        final id = defaultVehicle?.id ?? vehicles.first.id;
        if (id != null) {
          ref.read(selectedVehicleIdProvider.notifier).state = id;
        }
      }
      return vehicles;
    });
  }

  Future<void> add(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final id = await _repo.insert(vehicle);
      final vehicles = await _repo.getAll();
      if (vehicles.length == 1) {
        ref.read(selectedVehicleIdProvider.notifier).state = id;
      }
      if (vehicle.isDefault) {
        await _repo.setDefault(id);
      }
      return vehicles;
    });
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
  }

  Future<void> update(Vehicle vehicle) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.update(vehicle);
      if (vehicle.isDefault) {
        await _repo.setDefault(vehicle.id!);
      }
      return _repo.getAll();
    });
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
  }

  Future<void> remove(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.delete(id);
      final vehicles = await _repo.getAll();
      final selectedId = ref.read(selectedVehicleIdProvider);
      if (vehicles.isEmpty) {
        ref.read(selectedVehicleIdProvider.notifier).state = null;
      } else if (selectedId == id) {
        ref.read(selectedVehicleIdProvider.notifier).state = vehicles.first.id;
      }
      return vehicles;
    });
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
  }

  Future<void> setDefault(int id) async {
    state.whenData((vehicles) {
      final updated = vehicles
          .map((v) => v.copyWith(isDefault: v.id == id))
          .toList();
      updated.sort(_compareVehicles);
      state = AsyncValue.data(updated);
    });

    await _repo.setDefault(id);
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
  }

  static int _compareVehicles(Vehicle a, Vehicle b) {
    if (a.isDefault && !b.isDefault) return -1;
    if (!a.isDefault && b.isDefault) return 1;
    return a.name.compareTo(b.name);
  }
}

final vehiclesNotifierProvider =
    NotifierProvider<VehiclesNotifier, AsyncValue<List<Vehicle>>>(
      VehiclesNotifier.new,
    );
