import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/widgets/vehicle_switcher.dart';
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

Vehicle _vehicle(int id, String name, String type) {
  return Vehicle(
    id: id,
    name: name,
    type: type,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  testWidgets('muestra los vehículos y selecciona al tocar', (tester) async {
    final bici = _vehicle(1, 'Bici', 'bike');
    final moto = _vehicle(2, 'Moto', 'motorcycle');
    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith((ref) async => [bici, moto]),
        currentVehicleProvider.overrideWith((ref) async => bici),
        vehicleRepositoryProvider.overrideWithValue(_FakeVehicleRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: VehicleSwitcher())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bici'), findsOneWidget);
    expect(find.text('Moto'), findsOneWidget);

    await tester.tap(find.text('Moto'));
    await tester.pumpAndSettle();

    expect(container.read(selectedVehicleIdProvider), 2);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final bici = _vehicle(1, 'Bicicleta Trek eléctrica', 'bike');
    final carro = _vehicle(2, 'Mazda 3', 'car');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehiclesProvider.overrideWith((ref) async => [bici, carro]),
          currentVehicleProvider.overrideWith((ref) async => bici),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: VehicleSwitcher())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
