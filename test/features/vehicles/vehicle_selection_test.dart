import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import 'package:motorcheck/features/vehicles/vehicle_selection.dart';

class _FakeVehicleRepository extends VehicleRepository {
  _FakeVehicleRepository(this.vehicles);

  final List<Vehicle> vehicles;

  @override
  Future<List<Vehicle>> getAll() async => vehicles;

  @override
  Future<Vehicle?> getById(int id) async =>
      vehicles.where((v) => v.id == id).firstOrNull;

  @override
  Future<int?> getLastSelectedId() async => null;

  @override
  Future<void> markLastSelected(int id) async {}
}

class _Harness extends ConsumerWidget {
  const _Harness({required this.onResult, this.preferredVehicleId});

  final ValueChanged<Vehicle?> onResult;
  final int? preferredVehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () async =>
                onResult(await pickVehicleOrUseSingle(context, ref)),
            child: const Text('Elegir'),
          ),
          TextButton(
            onPressed: () async => onResult(
              await resolveVehicleForNewRecord(
                ref,
                preferredVehicleId: preferredVehicleId,
              ),
            ),
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }
}

void main() {
  final toyota = Vehicle(
    id: 1,
    name: 'Toyota Corolla',
    type: 'car',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
  final mazda = Vehicle(
    id: 2,
    name: 'Mazda 2',
    type: 'car',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  Future<void> pumpHarness(
    WidgetTester tester, {
    required List<Vehicle> vehicles,
    int? preferredVehicleId,
    int? selectedVehicleId,
    required ValueChanged<Vehicle?> onResult,
  }) async {
    final container = ProviderContainer(
      overrides: [
        vehicleRepositoryProvider.overrideWithValue(
          _FakeVehicleRepository(vehicles),
        ),
        vehiclesProvider.overrideWith((ref) async => vehicles),
      ],
    );
    addTearDown(container.dispose);
    if (selectedVehicleId != null) {
      container.read(selectedVehicleIdProvider.notifier).state =
          selectedVehicleId;
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: _Harness(
            onResult: onResult,
            preferredVehicleId: preferredVehicleId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('pickVehicleOrUseSingle', () {
    testWidgets('con un solo vehículo lo devuelve sin abrir el selector', (
      tester,
    ) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: [toyota],
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Elegir'));
      await tester.pumpAndSettle();

      expect(result, toyota);
      expect(find.text('Selecciona un vehículo'), findsNothing);
    });

    testWidgets('con dos vehículos abre el selector', (tester) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: [toyota, mazda],
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Elegir'));
      await tester.pumpAndSettle();

      expect(find.text('Selecciona un vehículo'), findsOneWidget);

      await tester.tap(find.text('Mazda 2'));
      await tester.pumpAndSettle();

      expect(result, mazda);
    });

    testWidgets('sin vehículos devuelve null y no abre el selector', (
      tester,
    ) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: const [],
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Elegir'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text('Selecciona un vehículo'), findsNothing);
    });
  });

  group('resolveVehicleForNewRecord', () {
    testWidgets('sin vehículo indicado usa el único registrado', (
      tester,
    ) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: [toyota],
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Resolver'));
      await tester.pumpAndSettle();

      expect(result, toyota);
    });

    testWidgets('sin vehículo indicado ni selección devuelve null', (
      tester,
    ) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: [toyota, mazda],
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Resolver'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('prioriza el vehículo indicado', (tester) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: [toyota, mazda],
        preferredVehicleId: 2,
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Resolver'));
      await tester.pumpAndSettle();

      expect(result, mazda);
    });

    testWidgets('usa el vehículo seleccionado', (tester) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: [toyota, mazda],
        selectedVehicleId: 2,
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Resolver'));
      await tester.pumpAndSettle();

      expect(result, mazda);
    });

    testWidgets('cae al único vehículo si el indicado ya no existe', (
      tester,
    ) async {
      Vehicle? result;
      await pumpHarness(
        tester,
        vehicles: [toyota],
        preferredVehicleId: 99,
        onResult: (vehicle) => result = vehicle,
      );

      await tester.tap(find.text('Resolver'));
      await tester.pumpAndSettle();

      expect(result, toyota);
    });
  });
}
