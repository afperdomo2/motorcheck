import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motorcheck/features/components/providers.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/maintenance/screens/maintenance_form_screen.dart';
import 'package:motorcheck/features/settings/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

class _MockVehicleRepository extends Mock implements VehicleRepository {}

class _MockMaintenanceRepository extends Mock
    implements MaintenanceRepository {}

void main() {
  final toyota = Vehicle(
    id: 1,
    name: 'Toyota Corolla',
    type: 'car',
    brand: 'Toyota',
    model: '2020',
    plate: 'ABC-123',
    currentMileage: 89500,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
  final mazda = Vehicle(
    id: 2,
    name: 'Mazda 2',
    type: 'car',
    plate: 'XYZ-987',
    currentMileage: 12000,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  late _MockVehicleRepository vehicleRepo;
  late _MockMaintenanceRepository maintenanceRepo;

  setUpAll(() async {
    await initializeDateFormatting('es_CO');
  });

  setUp(() {
    vehicleRepo = _MockVehicleRepository();
    maintenanceRepo = _MockMaintenanceRepository();

    when(() => vehicleRepo.getById(1)).thenAnswer((_) async => toyota);
    when(() => vehicleRepo.getById(2)).thenAnswer((_) async => mazda);
    when(() => vehicleRepo.getAll()).thenAnswer((_) async => [toyota, mazda]);
    when(() => vehicleRepo.markLastSelected(any())).thenAnswer((_) async {});
    when(() => vehicleRepo.getLastSelectedId()).thenAnswer((_) async => null);
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    int? vehicleId,
    int? maintenanceId,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(vehicleRepo),
          maintenanceRepositoryProvider.overrideWithValue(maintenanceRepo),
          vehiclesProvider.overrideWith((ref) async => [toyota, mazda]),
          workshopsProvider.overrideWith((ref) async => []),
          maintenanceCategoriesProvider.overrideWith((ref) async => []),
          vehicleComponentsProvider(1).overrideWith((ref) async => []),
          vehicleComponentsProvider(2).overrideWith((ref) async => []),
        ],
        child: MaterialApp(
          home: MaintenanceFormScreen(
            vehicleId: vehicleId,
            maintenanceId: maintenanceId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('al crear muestra la ficha del vehículo', (tester) async {
    await pumpForm(tester, vehicleId: 1);

    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('Toyota 2020'), findsOneWidget);
    expect(find.text('ABC-123'), findsOneWidget);
    expect(find.text('89.500 km'), findsOneWidget);
  });

  testWidgets('al editar muestra la ficha del vehículo del mantenimiento', (
    tester,
  ) async {
    when(() => maintenanceRepo.getById(10)).thenAnswer(
      (_) async => Maintenance(
        id: 10,
        vehicleId: 1,
        date: DateTime(2024, 3, 15),
        mileage: 80000,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    );
    when(() => maintenanceRepo.getItems(10)).thenAnswer((_) async => []);

    await pumpForm(tester, maintenanceId: 10);

    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('ABC-123'), findsOneWidget);
  });

  testWidgets('al crear permite cambiar de vehículo desde la ficha', (
    tester,
  ) async {
    await pumpForm(tester, vehicleId: 1);

    await tester.tap(find.text('Toyota Corolla'));
    await tester.pumpAndSettle();
    expect(find.text('Selecciona un vehículo'), findsOneWidget);

    await tester.tap(find.text('Mazda 2'));
    await tester.pumpAndSettle();

    expect(find.text('Mazda 2'), findsOneWidget);
    expect(find.text('Toyota Corolla'), findsNothing);
    expect(find.text('XYZ-987'), findsOneWidget);
    expect(find.text('12000'), findsOneWidget);
  });

  testWidgets('al editar la ficha no cambia de vehículo', (tester) async {
    when(() => maintenanceRepo.getById(10)).thenAnswer(
      (_) async => Maintenance(
        id: 10,
        vehicleId: 1,
        date: DateTime(2024, 3, 15),
        mileage: 80000,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    );
    when(() => maintenanceRepo.getItems(10)).thenAnswer((_) async => []);

    await pumpForm(tester, maintenanceId: 10);

    await tester.tap(find.text('Toyota Corolla'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona un vehículo'), findsNothing);
  });
}
