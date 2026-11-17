import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/screens/vehicle_form_screen.dart';

void main() {
  testWidgets('valida año y VIN antes de guardar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VehicleFormScreen())),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.enterText(find.byType(TextFormField).at(3), '1800');
    await tester.enterText(find.byType(TextFormField).at(6), 'ABC');
    await tester.tap(find.text('Crear vehículo'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Año fuera de rango'), findsOneWidget);
    expect(find.text('El VIN debe tener 17 caracteres'), findsOneWidget);
  });
}
