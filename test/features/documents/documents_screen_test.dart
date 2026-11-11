import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
import 'package:motorcheck/features/documents/providers.dart';
import 'package:motorcheck/features/documents/screens/documents_screen.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

void main() {
  testWidgets('muestra vigente e histórico sin desbordar al 200 %', (
    tester,
  ) async {
    final now = DateTime.now();
    final vehicle = Vehicle(
      id: 1,
      name: 'Toyota',
      type: 'car',
      createdAt: now,
      updatedAt: now,
    );
    final current = VehicleDocument(
      id: 2,
      vehicleId: 1,
      type: 'soat',
      name: 'SOAT vigente',
      expiresAt: now.add(const Duration(days: 200)),
      createdAt: now,
      updatedAt: now,
    );
    final old = VehicleDocument(
      id: 1,
      vehicleId: 1,
      type: 'soat',
      name: 'SOAT viejo',
      expiresAt: now.subtract(const Duration(days: 100)),
      createdAt: now,
      updatedAt: now,
    );

    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedVehicleProvider(1).overrideWith((ref) async => vehicle),
          vehicleDocumentsProvider(
            1,
          ).overrideWith((ref) async => [current, old]),
        ],
        child: const MaterialApp(home: DocumentsScreen(vehicleId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 documentos'), findsOneWidget);
    expect(find.text('Vigente'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
