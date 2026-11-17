import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motorcheck/features/components/providers.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/maintenance/screens/maintenance_form_screen.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
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

  final aceite = MaintenanceCategory(
    key: 'car_oil',
    name: 'Aceite',
    iconName: 'oil_barrel',
    vehicleType: 'car',
    createdAt: DateTime(2024),
  );
  final frenos = MaintenanceCategory(
    key: 'car_brakes',
    name: 'Frenos',
    iconName: 'disc_full',
    vehicleType: 'car',
    createdAt: DateTime(2024),
  );
  final general = MaintenanceCategory(
    key: 'car_general',
    name: 'General',
    iconName: 'build',
    vehicleType: 'car',
    createdAt: DateTime(2024),
  );

  setUpAll(() async {
    await initializeDateFormatting('es_CO');
    registerFallbackValue(
      Maintenance(
        vehicleId: 1,
        date: DateTime(2024),
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    );
    registerFallbackValue(<MaintenanceItem>[]);
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
    List<MaintenanceCategory> categories = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(vehicleRepo),
          maintenanceRepositoryProvider.overrideWithValue(maintenanceRepo),
          vehiclesProvider.overrideWith((ref) async => [toyota, mazda]),
          workshopsProvider.overrideWith((ref) async => []),
          maintenanceCategoriesProvider.overrideWith((ref) async => categories),
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

  /// Toca un botón de agregar asegurando que esté a la vista, como haría el
  /// usuario con el dedo o el mouse.
  Future<void> tapAdd(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  /// Deja correr el resaltado temporal del ítem recién agregado.
  Future<void> settleHighlight(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
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

  testWidgets('al agregar un ítem lo expande y usa la categoría General', (
    tester,
  ) async {
    await pumpForm(tester, vehicleId: 1, categories: [aceite, frenos, general]);

    expect(find.text('Sin ítems'), findsOneWidget);

    await tapAdd(tester, 'Agregar');

    expect(find.text('1 ítem'), findsOneWidget);
    expect(find.text('Ítem 1'), findsOneWidget);
    expect(find.text('Categoría *'), findsOneWidget);
    expect(find.text('General'), findsWidgets);
    expect(find.text('Elige una categoría'), findsNothing);

    await settleHighlight(tester);
  });

  testWidgets('sin categoría General el ítem nuevo arranca vacío', (
    tester,
  ) async {
    await pumpForm(tester, vehicleId: 1, categories: [aceite, frenos]);

    await tapAdd(tester, 'Agregar');

    expect(find.textContaining('Sin categoría'), findsOneWidget);
    expect(find.text('General'), findsNothing);

    await tester.ensureVisible(find.text('Registrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    expect(find.text('Elige una categoría'), findsOneWidget);
    verifyNever(() => maintenanceRepo.insert(any(), any()));

    await settleHighlight(tester);
  });

  testWidgets('al agregar varios ítems el último queda visible y expandido', (
    tester,
  ) async {
    await pumpForm(tester, vehicleId: 1, categories: [aceite, frenos]);

    await tapAdd(tester, 'Agregar');
    for (var i = 0; i < 3; i++) {
      await tapAdd(tester, 'Agregar ítem');
    }

    expect(find.text('4 ítems'), findsOneWidget);
    expect(find.text('Ítem 4'), findsOneWidget);

    // Solo la fila nueva muestra sus campos; las anteriores quedan colapsadas.
    expect(find.text('Categoría *'), findsOneWidget);

    final viewport =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final row = tester.getRect(find.text('Ítem 4'));
    expect(row.top, greaterThanOrEqualTo(0));
    expect(row.bottom, lessThanOrEqualTo(viewport));

    await settleHighlight(tester);
  });

  testWidgets('al guardar un ítem sin categoría válida expande la fila', (
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
    when(() => maintenanceRepo.getItems(10)).thenAnswer(
      (_) async => [
        MaintenanceItem(
          id: 1,
          maintenanceId: 10,
          category: 'general',
          partsCost: 50000,
          createdAt: DateTime(2024, 3, 15, 10, 0),
        ),
      ],
    );

    await pumpForm(tester, maintenanceId: 10, categories: [aceite, frenos]);

    // Colapsado: se ve el resumen y avisa que falta categoría.
    expect(find.text('Ítem 1'), findsOneWidget);
    expect(find.textContaining('Sin categoría'), findsOneWidget);
    expect(find.text('Categoría *'), findsNothing);

    await tester.ensureVisible(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Categoría *'), findsOneWidget);
    expect(find.text('Elige una categoría'), findsOneWidget);
    verifyNever(() => maintenanceRepo.update(any(), any()));
  });
}
