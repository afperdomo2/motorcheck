import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/vehicle_document.dart';
import 'repository.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepository();
});

final allDocumentsProvider = FutureProvider<List<VehicleDocument>>((ref) async {
  return ref.watch(documentsRepositoryProvider).getAll();
});

final vehicleDocumentsProvider =
    FutureProvider.family<List<VehicleDocument>, int>((ref, vehicleId) async {
      return ref.watch(documentsRepositoryProvider).getByVehicleId(vehicleId);
    });

final globalDocumentsProvider = FutureProvider<List<VehicleDocument>>((
  ref,
) async {
  return ref.watch(documentsRepositoryProvider).getGlobal();
});

final documentByIdProvider = FutureProvider.family<VehicleDocument?, int>((
  ref,
  id,
) async {
  return ref.watch(documentsRepositoryProvider).getById(id);
});

class DocumentsNotifier extends Notifier<AsyncValue<void>> {
  DocumentsRepository get _repo => ref.read(documentsRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(VehicleDocument document) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (document.id == null) {
        await _repo.insert(document);
      } else {
        await _repo.update(document);
      }
    });
    _invalidate(document.vehicleId);
  }

  Future<void> remove(int id, {int? vehicleId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(id));
    _invalidate(vehicleId);
  }

  void _invalidate(int? vehicleId) {
    ref.invalidate(allDocumentsProvider);
    ref.invalidate(globalDocumentsProvider);
    if (vehicleId != null) {
      ref.invalidate(vehicleDocumentsProvider(vehicleId));
    }
  }
}

final documentsNotifierProvider =
    NotifierProvider<DocumentsNotifier, AsyncValue<void>>(
      DocumentsNotifier.new,
    );
