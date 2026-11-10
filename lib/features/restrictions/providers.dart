import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../vehicles/models/vehicle.dart';
import '../vehicles/providers.dart';
import 'models/vehicle_restriction.dart';
import 'repository.dart';
import 'restriction_status.dart';

final restrictionRepositoryProvider = Provider<RestrictionRepository>((ref) {
  return RestrictionRepository();
});

final vehicleRestrictionProvider =
    FutureProvider.family<VehicleRestriction?, int>((ref, vehicleId) async {
      return ref.watch(restrictionRepositoryProvider).getByVehicleId(vehicleId);
    });

final vehicleRestrictionStatusProvider =
    FutureProvider.family<RestrictionStatus, int>((ref, vehicleId) async {
      final restriction = await ref.watch(
        vehicleRestrictionProvider(vehicleId).future,
      );
      return evaluateRestriction(restriction, DateTime.now());
    });

class VehicleRestrictionEntry {
  const VehicleRestrictionEntry({required this.vehicle, required this.status});

  final Vehicle vehicle;
  final RestrictionStatus status;
}

final restrictionStatusesProvider =
    FutureProvider<List<VehicleRestrictionEntry>>((ref) async {
      final vehicles = await ref.watch(vehiclesProvider.future);
      final entries = <VehicleRestrictionEntry>[];

      for (final vehicle in vehicles) {
        final id = vehicle.id;
        if (id == null) continue;
        final restriction = await ref.watch(
          vehicleRestrictionProvider(id).future,
        );
        final status = evaluateRestriction(restriction, DateTime.now());
        if (status.configured) {
          entries.add(
            VehicleRestrictionEntry(vehicle: vehicle, status: status),
          );
        }
      }

      entries.sort((a, b) {
        if (a.status.restrictedToday != b.status.restrictedToday) {
          return a.status.restrictedToday ? -1 : 1;
        }
        return a.vehicle.name.compareTo(b.vehicle.name);
      });
      return entries;
    });

class RestrictionsNotifier extends Notifier<AsyncValue<void>> {
  RestrictionRepository get _repo => ref.read(restrictionRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(VehicleRestriction restriction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.upsert(restriction));
    _invalidate(restriction.vehicleId);
  }

  Future<void> remove(int vehicleId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(vehicleId));
    _invalidate(vehicleId);
  }

  void _invalidate(int vehicleId) {
    ref.invalidate(vehicleRestrictionProvider(vehicleId));
    ref.invalidate(vehicleRestrictionStatusProvider(vehicleId));
    ref.invalidate(restrictionStatusesProvider);
  }
}

final restrictionsNotifierProvider =
    NotifierProvider<RestrictionsNotifier, AsyncValue<void>>(
      RestrictionsNotifier.new,
    );
