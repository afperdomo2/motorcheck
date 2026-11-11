import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory dbDir;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseHelper.instance.close();
    dbDir = await Directory.systemTemp.createTemp('motorcheck_backfill_');
    DatabaseHelper.useDirectoryForTesting(dbDir.path);
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.useDirectoryForTesting(null);
    if (await dbDir.exists()) await dbDir.delete(recursive: true);
  });

  test('no recrea documentos ni lecturas al reabrir la base', () async {
    final vehicleRepo = VehicleRepository();
    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Sin backfill',
        currentMileage: 88000,
        soatExpiresAt: DateTime(2027, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    await DatabaseHelper.instance.close();
    final db = await DatabaseHelper.instance.database;

    final documents = await db.query(
      'documents',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    final readings = await db.query(
      'mileage_readings',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );

    expect(documents, isEmpty);
    expect(readings, isEmpty);
  });
}
