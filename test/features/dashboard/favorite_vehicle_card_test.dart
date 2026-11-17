import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:motorcheck/features/dashboard/widgets/favorite_vehicle_card.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/restrictions/providers.dart';
import 'package:motorcheck/features/restrictions/restriction_status.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

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
        path: '/vehicles/:id',
        builder: (_, _) => const Scaffold(body: Text('PantallaDetalles')),
      ),
      GoRoute(
        path: '/vehicles/:id/upcoming',
        builder: (_, _) => const Scaffold(body: Text('PantallaProximos')),
      ),
      GoRoute(
        path: '/vehicles/:id/restriction',
        builder: (_, _) => const Scaffold(body: Text('PantallaRestriccion')),
      ),
    ],
  );
}

List<Override> _overrides(List<Vehicle> vehicles) {
  return [
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

  testWidgets('muestra el vehículo principal y sus acciones', (tester) async {
    final vehicle = _vehicle(isDefault: true);

    await _pump(tester, _overrides([vehicle]));

    expect(find.text('Mi Carro'), findsOneWidget);
    expect(find.text('Actualizar km'), findsOneWidget);
    expect(find.text('Próximos'), findsOneWidget);
    expect(find.text('Detalles'), findsNothing);
    expect(find.text('Mantenimientos'), findsNothing);
  });

  testWidgets('usa el primer vehículo como respaldo sin principal', (
    tester,
  ) async {
    final vehicles = [
      _vehicle(id: 1, name: 'Primero'),
      _vehicle(id: 2, name: 'Segundo'),
    ];

    await _pump(tester, _overrides(vehicles));

    expect(find.text('Primero'), findsOneWidget);
    expect(find.text('Segundo'), findsNothing);
  });

  testWidgets('no se muestra cuando no hay vehículos', (tester) async {
    await _pump(tester, _overrides([]));

    expect(find.byType(Card), findsNothing);
  });

  testWidgets('tocar la tarjeta navega a la pantalla de detalles', (
    tester,
  ) async {
    final vehicle = _vehicle(isDefault: true);

    await _pump(tester, _overrides([vehicle]));

    await tester.tap(find.text('Mi Carro'));
    await tester.pumpAndSettle();

    expect(find.text('PantallaDetalles'), findsOneWidget);
  });

  testWidgets('tocar Próximos navega a próximos mantenimientos', (
    tester,
  ) async {
    final vehicle = _vehicle(isDefault: true);

    await _pump(tester, _overrides([vehicle]));

    await tester.tap(find.text('Próximos'));
    await tester.pumpAndSettle();

    expect(find.text('PantallaProximos'), findsOneWidget);
  });

  testWidgets('muestra la cantidad de próximos en aviso', (tester) async {
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
      vehiclesProvider.overrideWith((ref) async => [vehicle]),
      upcomingMaintenanceProvider(1).overrideWith((ref) async => [upcoming]),
    ];

    await _pump(tester, overrides);

    expect(find.text('Próximos (1)'), findsOneWidget);
  });

  testWidgets('muestra pico y placa y navega a editarlo', (tester) async {
    final vehicle = _vehicle(isDefault: true);
    final status = RestrictionStatus(
      configured: true,
      restrictedToday: true,
      restrictedNow: false,
      todayLabel: 'Hoy no circulas · 06:00–21:00',
      nextLabel: 'Martes 17 nov · 06:00–21:00',
      nextRestrictionDate: DateTime(2026, 11, 17),
    );
    final overrides = [
      ..._overrides([vehicle]),
      vehicleRestrictionStatusProvider(1).overrideWith((ref) async => status),
    ];

    await _pump(tester, overrides);

    const label = 'Pico y placa · Hoy no circulas · 06:00–21:00';
    expect(find.text(label), findsOneWidget);

    await tester.tap(find.text(label));
    await tester.pumpAndSettle();

    expect(find.text('PantallaRestriccion'), findsOneWidget);
  });

  testWidgets('no muestra pico y placa sin configurar', (tester) async {
    final vehicle = _vehicle(isDefault: true);
    const status = RestrictionStatus(
      configured: false,
      restrictedToday: false,
      restrictedNow: false,
      todayLabel: 'Sin configurar',
      nextLabel: 'Configura tus días de pico y placa',
    );
    final overrides = [
      ..._overrides([vehicle]),
      vehicleRestrictionStatusProvider(1).overrideWith((ref) async => status),
    ];

    await _pump(tester, overrides);

    expect(find.textContaining('Pico y placa'), findsNothing);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final vehicle = _vehicle(
      isDefault: true,
      name: 'Bicicleta Trek eléctrica de montaña',
    );

    await _pump(tester, _overrides([vehicle]));

    expect(tester.takeException(), isNull);
  });
}
