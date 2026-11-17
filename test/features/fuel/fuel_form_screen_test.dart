import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/fuel/screens/fuel_form_screen.dart';
import 'package:motorcheck/features/vehicles/mileage_repository.dart';
import 'package:motorcheck/features/vehicles/models/mileage_reading.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

class _FakeVehicleRepository extends VehicleRepository {
  _FakeVehicleRepository(this.vehicle);

  final Vehicle vehicle;

  @override
  Future<Vehicle?> getById(int id) async => vehicle;
}

class _FakeMileageRepository extends MileageRepository {
  @override
  Future<MileageReading?> getLastReading(int vehicleId) async => null;
}

void main() {
  testWidgets('valida odómetro, cantidad y total de la tanqueada', (
    tester,
  ) async {
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
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(
            _FakeVehicleRepository(vehicle),
          ),
          mileageRepositoryProvider.overrideWithValue(_FakeMileageRepository()),
        ],
        child: const MaterialApp(home: FuelFormScreen(vehicleId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar tanqueada'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un odómetro válido'), findsOneWidget);
    expect(find.text('Ingresa una cantidad válida'), findsOneWidget);
    expect(find.text('Ingresa un total válido'), findsOneWidget);
  });
}
