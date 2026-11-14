import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/components/models/component_status.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/components/providers.dart';
import 'package:motorcheck/features/components/screens/component_form_screen.dart';
import 'package:motorcheck/features/components/screens/components_screen.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

void main() {
  final now = DateTime(2026, 11, 13);
  final vehicle = Vehicle(
    id: 1,
    name: 'Mazda 33',
    currentMileage: 152300,
    createdAt: now,
    updatedAt: now,
  );

  List<ComponentStatus> statuses({int? mileage}) {
    VehicleComponent component({
      required int id,
      required String name,
      required String type,
      String? position,
      int? installedKm,
      int? intervalKm,
      int? intervalMonths,
      int? warningKm,
    }) {
      return VehicleComponent(
        id: id,
        vehicleId: 1,
        name: name,
        type: type,
        position: position,
        installedAt: DateTime(2026, 6, 1),
        installedKm: installedKm,
        intervalKm: intervalKm,
        intervalMonths: intervalMonths,
        warningKm: warningKm,
        createdAt: now,
        updatedAt: now,
      );
    }

    return [
      componentStatusFor(
        component(
          id: 1,
          name: 'Llanta delantera izquierda',
          type: 'tire',
          position: 'Delantera izquierda',
          installedKm: 140000,
          intervalKm: 50000,
          warningKm: 3000,
        ),
        currentMileage: mileage ?? 152300,
        today: now,
      ),
      componentStatusFor(
        component(
          id: 2,
          name: 'Batería principal',
          type: 'battery',
          intervalMonths: 48,
        ),
        currentMileage: mileage ?? 152300,
        today: now,
      ),
      componentStatusFor(
        component(
          id: 3,
          name: 'Cadena',
          type: 'chain',
          installedKm: 1000,
          intervalKm: 2000,
        ),
        currentMileage: mileage ?? 152300,
        today: now,
      ),
    ]..sort(compareComponentStatus);
  }

  testWidgets('la lista no desborda a 360 px con texto al 200 %', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedVehicleProvider(1).overrideWith((ref) async => vehicle),
          vehicleComponentStatusesProvider(
            1,
          ).overrideWith((ref) async => statuses()),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: ComponentsScreen(vehicleId: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Mazda 33'), findsOneWidget);
    expect(find.text('3 componentes'), findsOneWidget);
    expect(find.text('Llanta delantera izquierda'), findsOneWidget);

    expect(find.text('Batería principal'), findsOneWidget);
  });

  testWidgets('muestra el estado vacío sin componentes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedVehicleProvider(1).overrideWith((ref) async => vehicle),
          vehicleComponentStatusesProvider(1).overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: ComponentsScreen(vehicleId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin componentes'), findsOneWidget);
    expect(find.text('Agregar componente'), findsOneWidget);
  });

  testWidgets('el formulario nuevo no desborda a 360 px al 200 %', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedVehicleProvider(1).overrideWith((ref) async => vehicle),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: ComponentFormScreen(vehicleId: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Nuevo componente'), findsOneWidget);
    expect(find.text('Guardar componente'), findsOneWidget);
  });
}
