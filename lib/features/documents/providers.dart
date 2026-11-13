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

/// Documentos vigentes: el de mayor `expiresAt` por tipo.
final vehicleCurrentDocumentsProvider =
    FutureProvider.family<List<VehicleDocument>, int>((ref, vehicleId) async {
      final documents = await ref.watch(
        vehicleDocumentsProvider(vehicleId).future,
      );
      final seen = <String>{};
      return [
        for (final document in documents)
          if (seen.add(document.type)) document,
      ];
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
    try {
      if (document.id == null) {
        await _repo.insert(document);
      } else {
        await _repo.update(document);
      }
      if (document.vehicleId != null) {
        await _syncLegacyDate(document.vehicleId!, document.type);
      }
      _invalidate(document.vehicleId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(int id, {int? vehicleId}) async {
    state = const AsyncValue.loading();
    try {
      final document = await _repo.getById(id);
      await _repo.delete(id);
      final ownerId = document?.vehicleId ?? vehicleId;
      if (document != null && ownerId != null) {
        await _syncLegacyDate(ownerId, document.type);
      }
      _invalidate(vehicleId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> syncVehicleDates(
    int vehicleId, {
    DateTime? soat,
    DateTime? rtm,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _syncType(
        vehicleId: vehicleId,
        type: 'soat',
        name: 'SOAT',
        date: soat,
      );
      await _syncType(
        vehicleId: vehicleId,
        type: 'rtm',
        name: 'Tecnomecánica',
        date: rtm,
      );
      state = const AsyncValue.data(null);
      _invalidate(vehicleId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _syncType({
    required int vehicleId,
    required String type,
    required String name,
    required DateTime? date,
  }) async {
    final current = await _repo.getLatestByType(vehicleId, type);

    if (date == null) {
      // No se elimina un documento con adjuntos o notas desde el formulario
      // del vehículo; eso se hace desde la pantalla de Documentos.
      if (current?.id != null &&
          current!.filePath == null &&
          current.notes == null) {
        await _repo.delete(current.id!);
      }
    } else if (current == null) {
      final now = DateTime.now();
      await _repo.insert(
        VehicleDocument(
          vehicleId: vehicleId,
          type: type,
          name: name,
          expiresAt: date,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await _repo.update(
        current.copyWith(expiresAt: date, updatedAt: DateTime.now()),
      );
    }

    await _syncLegacyDate(vehicleId, type);
  }

  Future<void> _syncLegacyDate(int vehicleId, String type) async {
    if (type != 'soat' && type != 'rtm') return;
    final latest = await _repo.getLatestByType(vehicleId, type);
    await _repo.setLegacyVehicleDate(vehicleId, type, latest?.expiresAt);
  }

  void _invalidate(int? vehicleId) {
    ref.invalidate(allDocumentsProvider);
    ref.invalidate(globalDocumentsProvider);
    ref.invalidate(vehicleCurrentDocumentsProvider);
    if (vehicleId != null) {
      ref.invalidate(vehicleDocumentsProvider(vehicleId));
    }
  }
}

final documentsNotifierProvider =
    NotifierProvider<DocumentsNotifier, AsyncValue<void>>(
      DocumentsNotifier.new,
    );
