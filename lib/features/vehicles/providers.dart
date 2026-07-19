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
      if (ref.read(selectedVehicleIdProvider) == null) {
        ref.read(selectedVehicleIdProvider.notifier).state = id;
      }
      return vehicles;
    });
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
  }

  Future<void> setDefault(int id) async {
    await _repo.setDefault(id);
    ref.invalidate(vehiclesProvider);
  }
}

final vehiclesNotifierProvider =
    NotifierProvider<VehiclesNotifier, AsyncValue<List<Vehicle>>>(
      VehiclesNotifier.new,
    );
