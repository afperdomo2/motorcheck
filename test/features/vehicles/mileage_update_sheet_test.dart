import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/widgets/mileage_update_sheet.dart';

void main() {
  testWidgets('valida que el kilometraje sea mayor al actual', (tester) async {
    final now = DateTime(2026, 11, 17);
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      type: 'car',
      currentMileage: 89000,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: MileageUpdateSheet(vehicle: vehicle)),
        ),
      ),
    );

    expect(find.text('Actualizar kilometraje'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '88000');
    await tester.tap(find.text('Guardar kilometraje'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Debe ser mayor a'), findsOneWidget);
  });
}
