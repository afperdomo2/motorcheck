import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/widgets/maintenance_card.dart';

Maintenance _maintenance() {
  return Maintenance(
    id: 1,
    vehicleId: 1,
    date: DateTime(2024, 3, 15),
    mileage: 6000,
    maintenanceCost: 100,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required String workshopName,
  String? workshopLocation,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MaintenanceCard(
          maintenance: _maintenance(),
          workshopName: workshopName,
          workshopLocation: workshopLocation,
          onTap: () {},
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('muestra el taller sin errores de ParentDataWidget', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      workshopName: 'Taller Central',
      workshopLocation: 'Bogotá',
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Taller Central · Bogotá'), findsOneWidget);
  });

  testWidgets('un nombre de taller largo no desborda la tarjeta', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      workshopName: 'Taller de mantenimiento automotriz especializado',
      workshopLocation: 'Bogotá',
    );

    expect(tester.takeException(), isNull);
  });
}
