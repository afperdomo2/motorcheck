import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/maintenance/screens/maintenance_list_screen.dart';
import 'package:motorcheck/features/maintenance/widgets/maintenance_card.dart';
import 'package:motorcheck/features/settings/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

class _FakeMaintenancesNotifier extends MaintenancesNotifier {
  _FakeMaintenancesNotifier(this.items);

  final List<Maintenance> items;

  @override
  AsyncValue<List<Maintenance>> build() => AsyncValue.data(items);

  @override
  Future<void> loadMaintenances() async {}
}

void main() {
  final now = DateTime(2026, 11, 17);
  final vehicle = Vehicle(
    id: 1,
    name: 'Mazda 33',
    type: 'car',
    currentMileage: 89000,
    createdAt: now,
    updatedAt: now,
  );
  final maintenance = Maintenance(
    id: 1,
    vehicleId: 1,
    date: now,
    mileage: 89000,
    maintenanceCost: 50000,
    totalPartsCost: 20000,
    createdAt: now,
    updatedAt: now,
  );

  Future<void> pump(
    WidgetTester tester, {
    required List<Maintenance> items,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehiclesProvider.overrideWith((ref) async => [vehicle]),
          maintenancesNotifierProvider.overrideWith(
            () => _FakeMaintenancesNotifier(items),
          ),
          workshopsProvider.overrideWith((ref) async => []),
          maintenanceCategoriesProvider.overrideWith((ref) async => []),
          workshopItemsProvider('1').overrideWith((ref) async => {}),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(360, 800),
              textScaler: TextScaler.linear(textScale),
            ),
            child: const MaintenanceListScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el estado vacío del vehículo actual', (tester) async {
    await pump(tester, items: const []);

    expect(find.text('Mazda 33'), findsOneWidget);
    expect(find.text('Sin mantenimientos'), findsOneWidget);
    expect(find.text('Registrar mantenimiento'), findsOneWidget);
  });

  testWidgets('muestra los mantenimientos del vehículo actual', (tester) async {
    await pump(tester, items: [maintenance]);

    expect(find.byType(MaintenanceCard), findsOneWidget);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    await pump(tester, items: [maintenance], textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
