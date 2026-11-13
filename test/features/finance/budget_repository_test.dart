import 'package:flutter_test/flutter_test.dart';
import '../../helpers/database_test_helper.dart';
import 'package:motorcheck/features/finance/budget_repository.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

void main() {
  setUpAll(TestDatabase.setUp);

  tearDownAll(TestDatabase.tearDown);

  test('crea, actualiza y elimina el presupuesto del mes', () async {
    final vehicleId = await VehicleRepository().insert(
      Vehicle(
        name: 'Presupuesto',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final repo = BudgetRepository();
    final now = DateTime.now();
    final period = repo.currentPeriod;

    await repo.upsert(
      Budget(
        vehicleId: vehicleId,
        period: period,
        amount: 800000,
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect((await repo.getForVehiclePeriod(vehicleId, period))!.amount, 800000);

    await repo.upsert(
      Budget(
        vehicleId: vehicleId,
        period: period,
        amount: 900000,
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect((await repo.getForVehiclePeriod(vehicleId, period))!.amount, 900000);

    await repo.delete(vehicleId, period);
    expect(await repo.getForVehiclePeriod(vehicleId, period), isNull);
  });
}
