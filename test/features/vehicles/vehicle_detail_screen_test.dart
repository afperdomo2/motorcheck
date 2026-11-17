import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/checklists/providers.dart';
import 'package:motorcheck/features/components/providers.dart';
import 'package:motorcheck/features/documents/providers.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/reminders/health_score.dart';
import 'package:motorcheck/features/reminders/providers.dart';
import 'package:motorcheck/features/restrictions/providers.dart';
import 'package:motorcheck/features/restrictions/restriction_status.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/screens/vehicle_detail_screen.dart';

void main() {
  testWidgets('muestra la ficha consolidada y no desborda al 200 %', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 4000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final now = DateTime(2026, 11, 17);
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      type: 'car',
      brand: 'Mazda',
      model: '3',
      year: 2020,
      plate: 'HJK-123',
      color: 'Rojo',
      currentMileage: 89000,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedVehicleProvider(1).overrideWith((ref) async => vehicle),
          vehicleMaintenanceSummaryProvider(1).overrideWith(
            (ref) async => (count: 0, totalCost: 0.0, lastDate: null),
          ),
          vehicleCurrentDocumentsProvider(1).overrideWith((ref) async => []),
          vehicleRestrictionStatusProvider(1).overrideWith(
            (ref) async => const RestrictionStatus(
              configured: false,
              restrictedToday: false,
              restrictedNow: false,
              todayLabel: 'Sin configurar',
              nextLabel: 'Configura tus días de pico y placa',
            ),
          ),
          vehicleHealthProvider(1).overrideWith(
            (ref) async => const HealthScore(
              value: 92,
              label: 'Al día',
              reasons: ['Todo al día'],
            ),
          ),
          vehicleComponentStatusesProvider(1).overrideWith((ref) async => []),
          inspectionRunsProvider(1).overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: VehicleDetailScreen(vehicleId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mazda 33'), findsOneWidget);
    expect(find.text('HJK-123'), findsOneWidget);
    expect(find.text('Salud del vehículo'), findsOneWidget);
    expect(find.text('Información'), findsOneWidget);
    expect(find.text('Creado'), findsOneWidget);
    expect(find.text('Documentos'), findsOneWidget);
    expect(find.text('Pico y placa'), findsOneWidget);
    expect(find.text('Inspecciones'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
