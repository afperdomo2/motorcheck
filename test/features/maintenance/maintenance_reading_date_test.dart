import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/mileage_repository.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setUpAll(TestDatabase.setUp);
  tearDownAll(TestDatabase.tearDown);

  test('la lectura usa la fecha del mantenimiento, no la de hoy', () async {
    final vehicleId = await VehicleRepository().insert(
      Vehicle(
        name: 'Fecha histórica',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final date = DateTime(2025, 5, 20);

    await MaintenanceRepository().insert(
      Maintenance(
        vehicleId: vehicleId,
        date: date,
        mileage: 5000,
        createdAt: date,
        updatedAt: date,
      ),
      const [],
    );

    final readings = await MileageRepository().getByVehicleId(vehicleId);
    expect(readings, hasLength(1));
    expect(readings.first.date, DateTime(2025, 5, 20));
    expect(readings.first.source, 'maintenance');
  });
}
