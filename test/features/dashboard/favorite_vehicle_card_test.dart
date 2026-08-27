import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:motorcheck/features/dashboard/widgets/favorite_vehicle_card.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
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

Vehicle _vehicle({
  int id = 1,
  String name = 'Mi Carro',
  bool isDefault = false,
}) {
  return Vehicle(
    id: id,
    name: name,
    type: 'car',
    brand: 'Toyota',
    model: 'Corolla',
    isDefault: isDefault,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: FavoriteVehicleCard()),
      ),
      GoRoute(
        path: '/maintenance',
        builder: (_, _) => const Scaffold(body: Text('PantallaMantenimientos')),
      ),
      GoRoute(
        path: '/vehicles/:id',
        builder: (_, _) => const Scaffold(body: Text('PantallaDetalles')),
      ),
      GoRoute(
        path: '/vehicles/:id/upcoming',
        builder: (_, _) => const Scaffold(body: Text('PantallaProximos')),
      ),
    ],
  );
}

List<Override> _overrides(Vehicle? defaultVehicle, List<Vehicle> vehicles) {
  return [
    defaultVehicleProvider.overrideWith((ref) async => defaultVehicle),
    vehiclesProvider.overrideWith((ref) async => vehicles),
    upcomingMaintenanceProvider(1).overrideWith((ref) async => []),
  ];
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  List<Override> overrides, {
  GoRouter? router,
}) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router ?? _router()),
    ),
  );
  await tester.pumpAndSettle();

  return container;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('muestra el vehículo favorito', (tester) async {
    final vehicle = _vehicle(isDefault: true);

    await _pump(tester, _overrides(vehicle, [vehicle]));

    expect(find.text('Mi Carro'), findsOneWidget);
    expect(find.text('Mantenimientos'), findsOneWidget);
    expect(find.text('Detalles'), findsOneWidget);
    expect(find.text('Próximos'), findsOneWidget);
  });

  testWidgets('usa el primer vehículo como respaldo sin favorito', (
    tester,
  ) async {
    final vehicles = [
      _vehicle(id: 1, name: 'Primero'),
      _vehicle(id: 2, name: 'Segundo'),
    ];

    await _pump(tester, _overrides(null, vehicles));

    expect(find.text('Primero'), findsOneWidget);
    expect(find.text('Segundo'), findsNothing);
  });

  testWidgets('no se muestra cuando no hay vehículos', (tester) async {
    await _pump(tester, _overrides(null, []));

    expect(find.byType(Card), findsNothing);
  });

  testWidgets('tocar Mantenimientos selecciona el vehículo y navega', (
    tester,
  ) async {
    final vehicle = _vehicle(isDefault: true);
    final overrides = [
      ..._overrides(vehicle, [vehicle]),
      vehicleRepositoryProvider.overrideWithValue(_FakeVehicleRepository()),
    ];
    final container = await _pump(tester, overrides);

    await tester.tap(find.text('Mantenimientos'));
    await tester.pumpAndSettle();

    expect(container.read(selectedVehicleIdProvider), 1);
    expect(find.text('PantallaMantenimientos'), findsOneWidget);
  });

  testWidgets('tocar Detalles navega a la pantalla de detalles', (
    tester,
  ) async {
    final vehicle = _vehicle(isDefault: true);

    await _pump(tester, _overrides(vehicle, [vehicle]));

    await tester.tap(find.text('Detalles'));
    await tester.pumpAndSettle();

    expect(find.text('PantallaDetalles'), findsOneWidget);
  });

  testWidgets('tocar Próximos navega a próximos mantenimientos', (
    tester,
  ) async {
    final vehicle = _vehicle(isDefault: true);

    await _pump(tester, _overrides(vehicle, [vehicle]));

    await tester.tap(find.text('Próximos'));
    await tester.pumpAndSettle();

    expect(find.text('PantallaProximos'), findsOneWidget);
  });

  testWidgets('muestra badge con la cantidad de próximos en aviso', (
    tester,
  ) async {
    final vehicle = _vehicle(isDefault: true);
    final category = MaintenanceCategory(
      id: 1,
      key: 'car_oil',
      name: 'Aceite',
      vehicleType: 'car',
      intervalKm: 1000,
      createdAt: DateTime(2024),
    );
    final upcoming = UpcomingMaintenance(
      category: category,
      remainingKm: 50,
      isWarning: true,
    );

    final overrides = [
      defaultVehicleProvider.overrideWith((ref) async => vehicle),
      vehiclesProvider.overrideWith((ref) async => [vehicle]),
      upcomingMaintenanceProvider(1).overrideWith((ref) async => [upcoming]),
    ];

    await _pump(tester, overrides);

    final badges = tester
        .widgetList<Badge>(find.byType(Badge))
        .where((b) => b.isLabelVisible)
        .toList();
    expect(badges, hasLength(1));
    expect(find.text('1'), findsOneWidget);
  });
}
