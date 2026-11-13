import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/mileage_repository.dart';
import 'package:motorcheck/features/vehicles/models/mileage_reading.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/screens/mileage_history_screen.dart';

void main() {
  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    final now = DateTime(2026, 11, 13);
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      currentMileage: 89000,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedVehicleProvider(1).overrideWith((ref) async => vehicle),
          vehicleMileageReadingsProvider(1).overrideWith(
            (ref) async => [
              MileageReading(
                id: 1,
                vehicleId: 1,
                date: DateTime(2026, 10, 1),
                mileage: 87000,
                source: 'manual',
                createdAt: now,
              ),
              MileageReading(
                id: 2,
                vehicleId: 1,
                date: DateTime(2026, 11, 1),
                mileage: 89000,
                source: 'fuel',
                createdAt: now,
              ),
            ],
          ),
          mileageStatsProvider(1).overrideWith(
            (ref) async =>
                const MileageStats(currentMileage: 89000, averageKmPerDay: 66),
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: MileageHistoryScreen(vehicleId: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Lecturas'), findsWidgets);
  });
}
