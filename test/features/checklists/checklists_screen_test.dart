import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/checklists/models/checklist.dart';
import 'package:motorcheck/features/checklists/providers.dart';
import 'package:motorcheck/features/checklists/screens/checklists_screen.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

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
          checklistsForVehicleProvider(1).overrideWith(
            (ref) async => [
              Checklist(id: 1, name: 'Inspección pre-viaje', createdAt: now),
            ],
          ),
          inspectionRunsProvider(1).overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: ChecklistsScreen(vehicleId: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Inspección pre-viaje'), findsOneWidget);
    expect(find.text('Sin inspecciones registradas'), findsOneWidget);
  });
}
