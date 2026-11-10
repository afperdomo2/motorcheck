import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

class _FakeVehicleRepository extends VehicleRepository {
  _FakeVehicleRepository({required this.vehicles, this.lastSelectedId});

  final List<Vehicle> vehicles;
  final int? lastSelectedId;

  @override
  Future<List<Vehicle>> getAll() async => vehicles;

  @override
  Future<int?> getLastSelectedId() async => lastSelectedId;

  @override
  Future<void> markLastSelected(int id) async {}
}

Vehicle _vehicle({
  required int id,
  required String name,
  bool isDefault = false,
}) {
  return Vehicle(
    id: id,
    name: name,
    isDefault: isDefault,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

Future<ProviderContainer> _containerFor({
  required List<Vehicle> vehicles,
  int? lastSelectedId,
}) async {
  final container = ProviderContainer(
    overrides: [
      vehicleRepositoryProvider.overrideWithValue(
        _FakeVehicleRepository(
          vehicles: vehicles,
          lastSelectedId: lastSelectedId,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);

  container.read(vehiclesNotifierProvider);
  await container.read(vehiclesNotifierProvider.notifier).loadVehicles();

  return container;
}

void main() {
  test('selecciona el favorito cuando no hay último seleccionado', () async {
    final container = await _containerFor(
      vehicles: [
        _vehicle(id: 1, name: 'A'),
        _vehicle(id: 2, name: 'B', isDefault: true),
      ],
    );

    expect(container.read(selectedVehicleIdProvider), 2);
  });

  test('prioriza el último seleccionado sobre el favorito', () async {
    final container = await _containerFor(
      vehicles: [
        _vehicle(id: 1, name: 'A'),
        _vehicle(id: 2, name: 'B', isDefault: true),
      ],
      lastSelectedId: 1,
    );

    expect(container.read(selectedVehicleIdProvider), 1);
  });

  test(
    'usa el primer vehículo si no hay favorito ni último seleccionado',
    () async {
      final container = await _containerFor(
        vehicles: [
          _vehicle(id: 1, name: 'A'),
          _vehicle(id: 2, name: 'B'),
        ],
      );

      expect(container.read(selectedVehicleIdProvider), 1);
    },
  );

  test('no cambia la selección actual si sigue siendo válida', () async {
    final container = await _containerFor(
      vehicles: [
        _vehicle(id: 1, name: 'A'),
        _vehicle(id: 2, name: 'B', isDefault: true),
      ],
    );
    container.read(selectedVehicleIdProvider.notifier).state = 1;

    await container.read(vehiclesNotifierProvider.notifier).loadVehicles();

    expect(container.read(selectedVehicleIdProvider), 1);
  });
}
