import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/features/expenses/models/expense.dart';
import 'package:motorcheck/features/expenses/repository.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/fuel/models/fuel_log.dart';
import 'package:motorcheck/features/fuel/repository.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
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

  test('suma mantenimiento, combustible y gastos', () async {
    final vehicleRepo = VehicleRepository();
    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Finanzas',
        currentMileage: 1000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final now = DateTime.now();

    final maintenanceRepo = MaintenanceRepository();
    await maintenanceRepo.insert(
      Maintenance(
        vehicleId: vehicleId,
        date: now,
        mileage: 1200,
        maintenanceCost: 1000,
        totalPartsCost: 0,
        createdAt: now,
        updatedAt: now,
      ),
      const [],
    );

    final fuelRepo = FuelRepository();
    await fuelRepo.insert(
      FuelLog(
        vehicleId: vehicleId,
        date: now,
        odometer: 1400,
        quantity: 10,
        unitPrice: 100,
        totalCost: 1000,
        fuelType: 'gasoline',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final expenseRepo = ExpenseRepository();
    await expenseRepo.insert(
      Expense(
        vehicleId: vehicleId,
        categoryKey: 'insurance',
        date: now,
        amount: 500,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final finance = await container.read(
      vehicleFinanceProvider(vehicleId).future,
    );

    expect(finance.currentMonthMaintenance, 1000);
    expect(finance.currentMonthFuel, 1000);
    expect(finance.currentMonthExpenses, 500);
    expect(finance.currentMonthTotal, 2500);
    expect(finance.totalCost, 2500);
  });
}
