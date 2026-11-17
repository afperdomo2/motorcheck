import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motorcheck/features/finance/finance_section.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/finance/screens/finance_screen.dart';
import 'package:motorcheck/features/vehicles/current_vehicle_provider.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

class _FakeVehicleRepository extends VehicleRepository {
  @override
  Future<List<Vehicle>> getAll() async => [];

  @override
  Future<int?> getLastSelectedId() async => null;

  @override
  Future<void> markLastSelected(int id) async {}
}

Vehicle _vehicle(int id, String name) {
  return Vehicle(
    id: id,
    name: name,
    type: 'car',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  testWidgets('el deep link abre presupuestos y selecciona el vehículo', (
    tester,
  ) async {
    final vehicle1 = _vehicle(1, 'Mazda');
    final vehicle2 = _vehicle(2, 'Yamaha');
    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith((ref) async => [vehicle1, vehicle2]),
        currentVehicleProvider.overrideWith((ref) async => vehicle2),
        vehicleRepositoryProvider.overrideWithValue(_FakeVehicleRepository()),
        budgetStatusesProvider.overrideWith((ref) async => []),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/finance?section=budgets&vehicleId=1',
      routes: [
        GoRoute(path: '/finance', builder: (_, _) => const FinanceScreen()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(financeSectionProvider), FinanceSection.budgets);
    expect(container.read(selectedVehicleIdProvider), 1);

    router.go('/finance?section=budgets&vehicleId=2');
    await tester.pumpAndSettle();

    expect(container.read(selectedVehicleIdProvider), 2);
  });
}
