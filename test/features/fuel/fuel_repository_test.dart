import 'package:flutter_test/flutter_test.dart';
import '../../helpers/database_test_helper.dart';
import 'package:motorcheck/features/fuel/models/fuel_log.dart';
import 'package:motorcheck/features/fuel/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

void main() {
  setUpAll(TestDatabase.setUp);

  tearDownAll(TestDatabase.tearDown);

  FuelLog log({
    required int odometer,
    required double quantity,
    required DateTime date,
    bool fullTank = true,
  }) {
    return FuelLog(
      vehicleId: 0,
      date: date,
      odometer: odometer,
      quantity: quantity,
      unitPrice: 4000,
      totalCost: quantity * 4000,
      fuelType: 'gasoline',
      fullTank: fullTank,
      createdAt: date,
      updatedAt: date,
    );
  }

  test('calcula consumo con tanque lleno y actualiza kilometraje', () async {
    final vehicleRepo = VehicleRepository();
    final fuelRepo = FuelRepository();
    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Consumo',
        currentMileage: 1000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    await fuelRepo.insert(
      log(
        odometer: 1000,
        quantity: 40,
        date: DateTime(2026, 1, 1),
      ).copyWith(vehicleId: vehicleId),
    );
    await fuelRepo.insert(
      log(
        odometer: 1200,
        quantity: 10,
        date: DateTime(2026, 1, 5),
        fullTank: false,
      ).copyWith(vehicleId: vehicleId),
    );
    await fuelRepo.insert(
      log(
        odometer: 1600,
        quantity: 30,
        date: DateTime(2026, 1, 10),
      ).copyWith(vehicleId: vehicleId),
    );

    final stats = await fuelRepo.getStats(vehicleId);
    final vehicle = await vehicleRepo.getById(vehicleId);

    expect(stats.count, 3);
    expect(stats.averageConsumption, closeTo(15, 0.01));
    expect(stats.litersPer100Km, closeTo(6.666, 0.01));
    expect(stats.costPerKm, closeTo(266.66, 0.01));
    expect(vehicle!.currentMileage, 1600);
  });
}
