import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/maintenance/widgets/upcoming_maintenance_view.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

void main() {
  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      type: 'car',
      currentMileage: 89000,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final category = MaintenanceCategory(
      key: 'car_oil',
      name: 'Aceite y filtros de motor',
      vehicleType: 'car',
      intervalKm: 5000,
      warningKm: 800,
      intervalMonths: 6,
      warningDays: 15,
      createdAt: DateTime(2026, 1, 1),
    );
    final item = UpcomingMaintenance(
      category: category,
      lastMileage: 85000,
      lastServiceDate: DateTime(2026, 5, 10),
      nextServiceDate: DateTime(2026, 11, 10),
      remainingKm: 1200,
      remainingDays: 12,
      isWarning: true,
      kmWarning: true,
      dateWarning: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedVehicleProvider(1).overrideWith((ref) async => vehicle),
          upcomingMaintenanceProvider(1).overrideWith((ref) async => [item]),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(body: UpcomingMaintenanceView(vehicleId: 1)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
