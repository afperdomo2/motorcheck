import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../vehicles/providers.dart';
import 'models/component_service.dart';
import 'models/component_status.dart';
import 'models/vehicle_component.dart';
import 'repository.dart';

final componentsRepositoryProvider = Provider<ComponentsRepository>((ref) {
  return ComponentsRepository();
});

final vehicleComponentsProvider =
    FutureProvider.family<List<VehicleComponent>, int>((ref, vehicleId) async {
      return ref.watch(componentsRepositoryProvider).getByVehicleId(vehicleId);
    });

final componentByIdProvider = FutureProvider.family<VehicleComponent?, int>((
  ref,
  id,
) async {
  return ref.watch(componentsRepositoryProvider).getById(id);
});

final componentServicesProvider =
    FutureProvider.family<List<ComponentService>, int>((
      ref,
      componentId,
    ) async {
      return ref.watch(componentsRepositoryProvider).getServices(componentId);
    });

/// Componentes de un vehículo con su estado calculado y ordenados por urgencia.
final vehicleComponentStatusesProvider =
    FutureProvider.family<List<ComponentStatus>, int>((ref, vehicleId) async {
      final components = await ref.watch(
        vehicleComponentsProvider(vehicleId).future,
      );
      final vehicle = await ref.watch(
        selectedVehicleProvider(vehicleId).future,
      );
      final today = DateTime.now();
      final statuses =
          components
              .map(
                (component) => componentStatusFor(
                  component,
                  currentMileage: vehicle?.currentMileage,
                  today: today,
                ),
              )
              .toList()
            ..sort(compareComponentStatus);
      return statuses;
    });

final componentStatusProvider = FutureProvider.family<ComponentStatus?, int>((
  ref,
  componentId,
) async {
  final component = await ref.watch(componentByIdProvider(componentId).future);
  if (component == null) return null;
  final vehicle = await ref.watch(
    selectedVehicleProvider(component.vehicleId).future,
  );
  return componentStatusFor(component, currentMileage: vehicle?.currentMileage);
});

class ComponentsNotifier extends Notifier<AsyncValue<void>> {
  ComponentsRepository get _repo => ref.read(componentsRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<int> save(VehicleComponent component) async {
    state = const AsyncValue.loading();
    try {
      final id = component.id == null
          ? await _repo.insert(component)
          : component.id!;
      if (component.id != null) {
        await _repo.update(component);
      }
      state = const AsyncValue.data(null);
      _invalidate(component.vehicleId, component.id ?? id);
      return id;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(int id, {required int vehicleId}) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      state = const AsyncValue.data(null);
      _invalidate(vehicleId, id);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> registerService(ComponentService service) async {
    state = const AsyncValue.loading();
    try {
      await _repo.registerService(service);
      final component = await _repo.getById(service.componentId);
      state = const AsyncValue.data(null);
      if (component != null) {
        _invalidate(component.vehicleId, component.id!);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> removeService(
    int serviceId, {
    required int componentId,
    required int vehicleId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteService(serviceId);
      state = const AsyncValue.data(null);
      _invalidate(vehicleId, componentId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void _invalidate(int vehicleId, int componentId) {
    ref.invalidate(vehicleComponentsProvider(vehicleId));
    ref.invalidate(vehicleComponentStatusesProvider(vehicleId));
    ref.invalidate(componentByIdProvider(componentId));
    ref.invalidate(componentStatusProvider(componentId));
    ref.invalidate(componentServicesProvider(componentId));
  }
}

final componentsNotifierProvider =
    NotifierProvider<ComponentsNotifier, AsyncValue<void>>(
      ComponentsNotifier.new,
    );
