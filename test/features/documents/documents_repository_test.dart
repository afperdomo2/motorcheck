import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
import 'package:motorcheck/features/documents/providers.dart';
import 'package:motorcheck/features/documents/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseHelper.instance.close();
    final dir = await getDatabasesPath();
    final file = File(p.join(dir, 'motorcheck.db'));
    if (await file.exists()) await file.delete();
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  test('CRUD de documentos por vehículo y globales', () async {
    final vehicleRepo = VehicleRepository();
    final repo = DocumentsRepository();
    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Documentos',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final now = DateTime(2026, 1, 1);

    final vehicleDocId = await repo.insert(
      VehicleDocument(
        vehicleId: vehicleId,
        type: 'soat',
        name: 'SOAT',
        expiresAt: DateTime(2026, 12, 31),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final globalDocId = await repo.insert(
      VehicleDocument(
        type: 'license',
        name: 'Licencia',
        expiresAt: DateTime(2027, 6, 30),
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(await repo.getByVehicleId(vehicleId), hasLength(1));
    expect(await repo.getGlobal(), hasLength(1));

    final loaded = await repo.getById(vehicleDocId);
    await repo.update(loaded!.copyWith(number: 'ABC-123'));
    expect((await repo.getById(vehicleDocId))!.number, 'ABC-123');

    await repo.delete(globalDocId);
    expect(await repo.getGlobal(), isEmpty);

    await vehicleRepo.delete(vehicleId);
    expect(await repo.getByVehicleId(vehicleId), isEmpty);
  });

  test('syncVehicleDates inserta, actualiza y elimina SOAT/RTM', () async {
    final vehicleRepo = VehicleRepository();
    final repo = DocumentsRepository();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Sincronización documentos',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    addTearDown(() => vehicleRepo.delete(vehicleId));

    final notifier = container.read(documentsNotifierProvider.notifier);

    await notifier.syncVehicleDates(
      vehicleId,
      soat: DateTime(2027, 1, 15),
      rtm: DateTime(2027, 6, 30),
    );

    var documents = await repo.getByVehicleId(vehicleId);
    expect(documents, hasLength(2));
    expect(
      documents.singleWhere((d) => d.type == 'soat').expiresAt,
      DateTime(2027, 1, 15),
    );

    await notifier.syncVehicleDates(
      vehicleId,
      soat: DateTime(2027, 2, 20),
      rtm: DateTime(2027, 6, 30),
    );

    documents = await repo.getByVehicleId(vehicleId);
    expect(
      documents.singleWhere((d) => d.type == 'soat').expiresAt,
      DateTime(2027, 2, 20),
    );

    await notifier.syncVehicleDates(vehicleId, soat: DateTime(2027, 2, 20));

    documents = await repo.getByVehicleId(vehicleId);
    expect(documents.where((d) => d.type == 'rtm'), isEmpty);
    expect(documents.where((d) => d.type == 'soat'), hasLength(1));
  });

  test('latest-wins actualiza el vigente y conserva el historial', () async {
    final vehicleRepo = VehicleRepository();
    final repo = DocumentsRepository();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'SOAT con historial',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    addTearDown(() => vehicleRepo.delete(vehicleId));
    final now = DateTime(2026, 1, 1);
    final oldId = await repo.insert(
      VehicleDocument(
        vehicleId: vehicleId,
        type: 'soat',
        name: 'SOAT viejo',
        expiresAt: DateTime(2025, 1, 1),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final currentId = await repo.insert(
      VehicleDocument(
        vehicleId: vehicleId,
        type: 'soat',
        name: 'SOAT vigente',
        expiresAt: DateTime(2027, 1, 1),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final latest = await repo.getLatestByType(vehicleId, 'soat');
    expect(latest?.id, currentId);

    await container
        .read(documentsNotifierProvider.notifier)
        .syncVehicleDates(vehicleId, soat: DateTime(2028, 1, 1));

    final documents = await repo.getByVehicleId(vehicleId);
    expect(documents.where((d) => d.type == 'soat'), hasLength(2));
    expect(
      documents.singleWhere((d) => d.id == oldId).expiresAt,
      DateTime(2025, 1, 1),
    );
    expect(
      documents.singleWhere((d) => d.id == currentId).expiresAt,
      DateTime(2028, 1, 1),
    );
    final vehicle = await vehicleRepo.getById(vehicleId);
    expect(vehicle!.soatExpiresAt, DateTime(2028, 1, 1));
  });

  test('eliminar el SOAT vigente limpia la columna legado', () async {
    final vehicleRepo = VehicleRepository();
    final repo = DocumentsRepository();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'SOAT eliminado',
        soatExpiresAt: DateTime(2027, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    addTearDown(() => vehicleRepo.delete(vehicleId));
    final documentId = await repo.insert(
      VehicleDocument(
        vehicleId: vehicleId,
        type: 'soat',
        name: 'SOAT',
        expiresAt: DateTime(2027, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    await container
        .read(documentsNotifierProvider.notifier)
        .remove(documentId, vehicleId: vehicleId);

    final vehicle = await vehicleRepo.getById(vehicleId);
    expect(vehicle!.soatExpiresAt, isNull);
  });
}
