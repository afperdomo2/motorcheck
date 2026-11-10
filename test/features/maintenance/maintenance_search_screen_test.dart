import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/maintenance/screens/maintenance_search_screen.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
import 'package:motorcheck/features/settings/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

void main() {
  final vehicle = Vehicle(
    id: 1,
    name: 'Toyota',
    type: 'car',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
  final category = MaintenanceCategory(
    id: 1,
    key: 'car_oil',
    name: 'Aceite',
    vehicleType: 'car',
    createdAt: DateTime(2024),
  );
  final maintenance = Maintenance(
    id: 1,
    vehicleId: 1,
    date: DateTime(2024, 3, 15),
    mileage: 10000,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
  final item = MaintenanceItem(
    id: 1,
    maintenanceId: 1,
    category: 'car_oil',
    createdAt: DateTime(2024),
  );

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          maintenancesProvider.overrideWith((ref) async => [maintenance]),
          vehiclesProvider.overrideWith((ref) async => [vehicle]),
          workshopsProvider.overrideWith((ref) async => []),
          maintenanceCategoriesProvider.overrideWith((ref) async => [category]),
          workshopItemsProvider('1').overrideWith(
            (ref) async => {
              1: [item],
            },
          ),
        ],
        child: const MaterialApp(home: MaintenanceSearchScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('encuentra mantenimientos por nombre de categoría', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'aceite');
    await tester.pumpAndSettle();

    expect(find.text('Toyota'), findsOneWidget);
    expect(find.text('Aceite'), findsOneWidget);
  });

  testWidgets('muestra estado sin resultados y limpia filtros', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsOneWidget);
    expect(find.text('Limpiar filtros'), findsOneWidget);

    await tester.tap(find.text('Limpiar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsNothing);
    expect(find.text('Toyota'), findsOneWidget);
  });
}
