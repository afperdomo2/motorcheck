import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
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
}
