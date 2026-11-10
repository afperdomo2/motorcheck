import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/features/vehicles/mileage_repository.dart';
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

  test('registra lecturas y calcula el promedio km/día', () async {
    final vehicleRepo = VehicleRepository();
    final mileageRepo = MileageRepository();
    final id = await vehicleRepo.insert(
      Vehicle(
        name: 'Prueba km',
        currentMileage: 1000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    await mileageRepo.addReading(
      vehicleId: id,
      mileage: 1000,
      date: DateTime(2026, 1, 1),
    );
    await mileageRepo.addReading(
      vehicleId: id,
      mileage: 2000,
      date: DateTime(2026, 1, 11),
    );
    await mileageRepo.addReading(
      vehicleId: id,
      mileage: 3000,
      date: DateTime(2026, 1, 21),
    );

    final stats = await mileageRepo.getStats(id);

    expect(stats.currentMileage, 3000);
    expect(stats.averageKmPerDay, closeTo(100, 0.01));
    expect(stats.hasEnoughData, isTrue);
    expect(stats.estimatedDateFor(1000), isNotNull);
  });

  test('una lectura menor no baja el kilometraje del vehículo', () async {
    final vehicleRepo = VehicleRepository();
    final mileageRepo = MileageRepository();
    final id = await vehicleRepo.insert(
      Vehicle(
        name: 'Prueba km menor',
        currentMileage: 5000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    await mileageRepo.addReading(vehicleId: id, mileage: 4000);
    final vehicle = await vehicleRepo.getById(id);

    expect(vehicle!.currentMileage, 5000);
    expect((await mileageRepo.getByVehicleId(id)).length, 1);
  });
}
