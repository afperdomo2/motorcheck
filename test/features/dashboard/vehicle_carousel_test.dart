import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/widgets/vehicle_carousel.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/reminders/health_score.dart';
import 'package:motorcheck/features/reminders/providers.dart';
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

Vehicle _vehicle(int id, String name, String plate, int mileage) {
  return Vehicle(
    id: id,
    name: name,
    type: 'car',
    plate: plate,
    currentMileage: mileage,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<Vehicle> vehicles,
  double textScale = 1,
}) async {
  final container = ProviderContainer(
    overrides: [
      vehiclesProvider.overrideWith((ref) async => vehicles),
      vehicleRepositoryProvider.overrideWithValue(_FakeVehicleRepository()),
      for (final vehicle in vehicles) ...[
        vehicleHealthProvider(vehicle.id!).overrideWith(
          (ref) async =>
              const HealthScore(value: 92, label: 'Al día', reasons: []),
        ),
        vehicleMonthSpendProvider(
          vehicle.id!,
        ).overrideWith((ref) async => 620000),
        upcomingMaintenanceProvider(
          vehicle.id!,
        ).overrideWith((ref) async => []),
      ],
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(360, 800),
            textScaler: TextScaler.linear(textScale),
          ),
          child: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: VehicleCarousel(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  final mazda = _vehicle(1, 'Mazda 33', 'HJK-123', 89000);
  final yamaha = _vehicle(2, 'Yamaha FZ', 'MZX-01', 23400);

  testWidgets('muestra el vehículo actual y cambia al deslizar', (
    tester,
  ) async {
    final container = await _pump(tester, vehicles: [mazda, yamaha]);

    expect(find.text('Mazda 33'), findsOneWidget);
    expect(find.text('HJK-123 · 89.000 km'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.textContaining('620k'), findsOneWidget);

    await tester.fling(
      find.byType(VehicleCarousel),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();

    expect(container.read(selectedVehicleIdProvider), 2);
    expect(find.text('Yamaha FZ'), findsOneWidget);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    await _pump(tester, vehicles: [mazda, yamaha], textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
