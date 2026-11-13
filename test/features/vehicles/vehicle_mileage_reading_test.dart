import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/mileage_repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setUpAll(TestDatabase.setUp);
  tearDownAll(TestDatabase.tearDown);

  test('crear y editar vehículo agrega lecturas de kilometraje', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(vehiclesNotifierProvider.notifier);
    final createdAt = DateTime(2026, 1, 1);

    final id = await notifier.add(
      Vehicle(
        name: 'Lecturas',
        currentMileage: 1000,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );

    var readings = await MileageRepository().getByVehicleId(id);
    expect(readings, hasLength(1));
    expect(readings.first.mileage, 1000);
    expect(readings.first.source, 'manual');

    final vehicle = await VehicleRepository().getById(id);
    await notifier.update(vehicle!.copyWith(currentMileage: 1500));

    readings = await MileageRepository().getByVehicleId(id);
    expect(readings, hasLength(2));
    expect(readings.last.mileage, 1500);
  });
}
