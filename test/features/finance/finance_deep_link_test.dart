import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/finance/screens/finance_screen.dart';
import 'package:motorcheck/features/fuel/repository.dart';
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

VehicleFinanceSummary _emptySummary(int vehicleId) {
  return VehicleFinanceSummary(
    vehicleId: vehicleId,
    monthLabel: 'Noviembre 2026',
    currentMonthMaintenance: 0,
    currentMonthFuel: 0,
    currentMonthExpenses: 0,
    currentMonthTotal: 0,
    totalMaintenance: 0,
    totalFuel: 0,
    totalExpenses: 0,
    totalCost: 0,
    costPerKm: null,
    fuelStats: const FuelStats(),
    maintenanceCount: 0,
    fuelCount: 0,
    expenseCount: 0,
    monthlyPoints: const [],
  );
}

void main() {
  testWidgets('el deep link selecciona el vehículo de la notificación', (
    tester,
  ) async {
    final vehicle1 = _vehicle(1, 'Mazda');
    final vehicle2 = _vehicle(2, 'Yamaha');
    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith((ref) async => [vehicle1, vehicle2]),
        vehicleRepositoryProvider.overrideWithValue(_FakeVehicleRepository()),
        vehicleFinanceProvider(1).overrideWith((ref) async => _emptySummary(1)),
        vehicleFinanceProvider(2).overrideWith((ref) async => _emptySummary(2)),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/finance?vehicleId=1',
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

    expect(container.read(selectedVehicleIdProvider), 1);

    router.go('/finance?vehicleId=2');
    await tester.pumpAndSettle();

    expect(container.read(selectedVehicleIdProvider), 2);
  });
}
