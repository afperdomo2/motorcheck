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

  /// Mantiene SOAT y RTM alineados con la tabla `documents`, que es la fuente
  /// de verdad. Se usa al guardar el vehículo desde su formulario.
  Future<void> syncVehicleDates(
    int vehicleId, {
    DateTime? soat,
    DateTime? rtm,
  }) async {
    state = const AsyncValue.loading();
    try {
      final existing = await _repo.getByVehicleId(vehicleId);
      await _syncType(
        vehicleId: vehicleId,
        type: 'soat',
        name: 'SOAT',
        date: soat,
        existing: existing,
      );
      await _syncType(
        vehicleId: vehicleId,
        type: 'rtm',
        name: 'Tecnomecánica',
        date: rtm,
        existing: existing,
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
    required List<VehicleDocument> existing,
  }) async {
    VehicleDocument? current;
    for (final document in existing) {
      if (document.type == type) {
        current = document;
        break;
      }
    }

    if (date == null) {
      // No se elimina un documento con adjuntos o notas desde el formulario
      // del vehículo; eso se hace desde la pantalla de Documentos.
      final id = current?.id;
      if (id != null && current!.filePath == null && current.notes == null) {
        await _repo.delete(id);
      }
      return;
    }

    final now = DateTime.now();
    if (current == null) {
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
      await _repo.update(current.copyWith(expiresAt: date, updatedAt: now));
    }
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
