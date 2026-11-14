import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/component_defaults.dart';
import '../vehicles/providers.dart';
import 'models/component_replacement.dart';
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

final componentReplacementsProvider =
    FutureProvider.family<List<ComponentReplacement>, int>((
      ref,
      componentId,
    ) async {
      return ref
          .watch(componentsRepositoryProvider)
          .getReplacementsForComponent(componentId);
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
      final replacements = await ref
          .watch(componentsRepositoryProvider)
          .getReplacements(vehicleId);
      final latest = <int, ComponentReplacement>{};
      for (final replacement in replacements) {
        latest.putIfAbsent(replacement.componentId, () => replacement);
      }

      final today = DateTime.now();
      final statuses = components.map((component) {
        final replacement = latest[component.id];
        return componentStatusFor(
          component,
          currentMileage: vehicle?.currentMileage,
          today: today,
          replacementDate: replacement?.date,
          replacementKm: replacement?.mileage,
        );
      }).toList()..sort(compareComponentStatus);
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
  final replacement = await ref
      .read(componentsRepositoryProvider)
      .getLatestReplacement(componentId);
  return componentStatusFor(
    component,
    currentMileage: vehicle?.currentMileage,
    replacementDate: replacement?.date,
    replacementKm: replacement?.mileage,
  );
});

class ComponentsNotifier extends Notifier<AsyncValue<void>> {
  ComponentsRepository get _repo => ref.read(componentsRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<int> save(VehicleComponent component) async {
    state = const AsyncValue.loading();
    try {
      final vehicle = await ref.read(
        selectedVehicleProvider(component.vehicleId).future,
      );
      final categoryKey =
          component.categoryKey ??
          componentCategoryKeyFor(vehicle?.type ?? 'other', component.type);
      final toSave = component.copyWith(categoryKey: categoryKey);
      final id = toSave.id == null ? await _repo.insert(toSave) : toSave.id!;
      if (toSave.id != null) {
        await _repo.update(toSave);
      }
      state = const AsyncValue.data(null);
      _invalidate(component.vehicleId, toSave.id ?? id);
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

  Future<int> seedDefaults({
    required int vehicleId,
    required String vehicleType,
    required DateTime installedAt,
    int? installedKm,
  }) async {
    try {
      final created = await _repo.seedDefaults(
        vehicleId: vehicleId,
        vehicleType: vehicleType,
        installedAt: installedAt,
        installedKm: installedKm,
      );
      if (created > 0) {
        _invalidate(vehicleId, null);
      }
      return created;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void _invalidate(int vehicleId, int? componentId) {
    ref.invalidate(vehicleComponentsProvider(vehicleId));
    ref.invalidate(vehicleComponentStatusesProvider(vehicleId));
    ref.invalidate(componentByIdProvider);
    ref.invalidate(componentStatusProvider);
    ref.invalidate(componentReplacementsProvider);
  }
}

final componentsNotifierProvider =
    NotifierProvider<ComponentsNotifier, AsyncValue<void>>(
      ComponentsNotifier.new,
    );
