import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await getDatabasesPath();
    final dbFile = File(p.join(dir, 'motorcheck.db'));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  final vehicleRepo = VehicleRepository();
  final maintRepo = MaintenanceRepository();

  test(
    'getCategoryHistory filtra por vehículo y categoría y ordena por fecha desc',
    () async {
      final now = DateTime(2024, 1, 1);
      final vehicleId = await vehicleRepo.insert(
        Vehicle(
          name: 'test-history-vehicle',
          type: 'car',
          createdAt: now,
          updatedAt: now,
        ),
      );
      addTearDown(() => vehicleRepo.delete(vehicleId));

      await maintRepo.insert(
        Maintenance(
          vehicleId: vehicleId,
          date: DateTime(2024, 1, 10),
          mileage: 10000,
          createdAt: now,
          updatedAt: now,
        ),
        [
          MaintenanceItem(
            maintenanceId: 0,
            category: 'car_oil',
            partsCost: 50,
            notes: 'Sintético',
            createdAt: now,
          ),
        ],
      );
      await maintRepo.insert(
        Maintenance(
          vehicleId: vehicleId,
          date: DateTime(2024, 3, 15),
          mileage: 13000,
          createdAt: now,
          updatedAt: now,
        ),
        [
          MaintenanceItem(
            maintenanceId: 0,
            category: 'car_oil',
            partsCost: 55,
            notes: 'Castrol',
            createdAt: now,
          ),
        ],
      );
      await maintRepo.insert(
        Maintenance(
          vehicleId: vehicleId,
          date: DateTime(2024, 2, 1),
          mileage: 11500,
          notes: 'Revisión de frenos',
          createdAt: now,
          updatedAt: now,
        ),
        [
          MaintenanceItem(
            maintenanceId: 0,
            category: 'car_brakes',
            partsCost: 120,
            createdAt: now,
          ),
        ],
      );

      final history = await maintRepo.getCategoryHistory(vehicleId, 'car_oil');

      expect(history.length, 2);
      expect(history.first.date, DateTime(2024, 3, 15));
      expect(history.first.mileage, 13000);
      expect(history.first.partsCost, 55);
      expect(history.first.notes, 'Castrol');
      expect(history.last.date, DateTime(2024, 1, 10));
      expect(history.last.mileage, 10000);
      expect(history.last.notes, 'Sintético');
    },
  );

  test(
    'un mantenimiento con km menor no baja el kilometraje del vehículo',
    () async {
      final now = DateTime(2024, 1, 1);
      final vehicleId = await vehicleRepo.insert(
        Vehicle(
          name: 'test-mileage-low',
          type: 'car',
          currentMileage: 88000,
          createdAt: now,
          updatedAt: now,
        ),
      );
      addTearDown(() => vehicleRepo.delete(vehicleId));

      await maintRepo.insert(
        Maintenance(
          vehicleId: vehicleId,
          date: DateTime(2024, 2, 1),
          mileage: 85000,
          createdAt: now,
          updatedAt: now,
        ),
        [],
      );

      final vehicle = await vehicleRepo.getById(vehicleId);
      expect(vehicle!.currentMileage, 88000);
    },
  );

  test(
    'un mantenimiento con km mayor sube el kilometraje del vehículo',
    () async {
      final now = DateTime(2024, 1, 1);
      final vehicleId = await vehicleRepo.insert(
        Vehicle(
          name: 'test-mileage-high',
          type: 'car',
          currentMileage: 88000,
          createdAt: now,
          updatedAt: now,
        ),
      );
      addTearDown(() => vehicleRepo.delete(vehicleId));

      await maintRepo.insert(
        Maintenance(
          vehicleId: vehicleId,
          date: DateTime(2024, 2, 1),
          mileage: 90000,
          createdAt: now,
          updatedAt: now,
        ),
        [],
      );

      final vehicle = await vehicleRepo.getById(vehicleId);
      expect(vehicle!.currentMileage, 90000);
    },
  );

  test('editar un mantenimiento sube el km pero no lo baja', () async {
    final now = DateTime(2024, 1, 1);
    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'test-mileage-edit',
        type: 'car',
        currentMileage: 88000,
        createdAt: now,
        updatedAt: now,
      ),
    );
    addTearDown(() => vehicleRepo.delete(vehicleId));

    final maintenanceId = await maintRepo.insert(
      Maintenance(
        vehicleId: vehicleId,
        date: DateTime(2024, 2, 1),
        mileage: 90000,
        createdAt: now,
        updatedAt: now,
      ),
      [],
    );
    final maintenance = await maintRepo.getById(maintenanceId);

    await maintRepo.update(
      maintenance!.copyWith(mileage: 95000, updatedAt: now),
      [],
    );
    expect((await vehicleRepo.getById(vehicleId))!.currentMileage, 95000);

    await maintRepo.update(
      maintenance.copyWith(mileage: 80000, updatedAt: now),
      [],
    );
    expect((await vehicleRepo.getById(vehicleId))!.currentMileage, 95000);
  });
}
