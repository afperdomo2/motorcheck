import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

class _FakeVehicleRepository extends VehicleRepository {
  _FakeVehicleRepository({required this.vehicles, this.lastSelectedId});

  final List<Vehicle> vehicles;
  final int? lastSelectedId;
  bool clearedDefault = false;
  int? defaultSet;

  @override
  Future<List<Vehicle>> getAll() async => vehicles;

  @override
  Future<int?> getLastSelectedId() async => lastSelectedId;

  @override
  Future<void> markLastSelected(int id) async {}

  @override
  Future<void> setDefault(int id) async => defaultSet = id;

  @override
  Future<void> clearDefault() async => clearedDefault = true;
}

class _MutableVehicleRepository extends VehicleRepository {
  _MutableVehicleRepository(this.vehicle);

  Vehicle vehicle;

  @override
  Future<List<Vehicle>> getAll() async => [vehicle];

  @override
  Future<Vehicle?> getById(int id) async => vehicle.id == id ? vehicle : null;

  @override
  Future<int?> getLastSelectedId() async => null;

  @override
  Future<void> markLastSelected(int id) async {}

  @override
  Future<void> update(Vehicle value) async => vehicle = value;

  @override
  Future<void> setDefault(int id) async {}

  @override
  Future<void> clearDefault() async {}
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
  test(
    'selecciona el predeterminado cuando no hay último seleccionado',
    () async {
      final container = await _containerFor(
        vehicles: [
          _vehicle(id: 1, name: 'A'),
          _vehicle(id: 2, name: 'B', isDefault: true),
        ],
      );

      expect(container.read(selectedVehicleIdProvider), 2);
    },
  );

  test('prioriza el último seleccionado sobre el predeterminado', () async {
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
    'usa el primer vehículo si no hay predeterminado ni último seleccionado',
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

  test('marca un vehículo como predeterminado', () async {
    final container = await _containerFor(
      vehicles: [
        _vehicle(id: 1, name: 'A'),
        _vehicle(id: 2, name: 'B', isDefault: true),
      ],
    );

    await container.read(vehiclesNotifierProvider.notifier).setDefault(1);

    final vehicles = container.read(vehiclesNotifierProvider).requireValue;
    expect(vehicles.firstWhere((v) => v.id == 1).isDefault, isTrue);
    expect(vehicles.firstWhere((v) => v.id == 2).isDefault, isFalse);
    final repo =
        container.read(vehicleRepositoryProvider) as _FakeVehicleRepository;
    expect(repo.defaultSet, 1);
  });

  test('quita el vehículo por defecto', () async {
    final container = await _containerFor(
      vehicles: [
        _vehicle(id: 1, name: 'A'),
        _vehicle(id: 2, name: 'B', isDefault: true),
      ],
    );

    await container.read(vehiclesNotifierProvider.notifier).clearDefault();

    final vehicles = container.read(vehiclesNotifierProvider).requireValue;
    expect(vehicles.every((v) => !v.isDefault), isTrue);
    final repo =
        container.read(vehicleRepositoryProvider) as _FakeVehicleRepository;
    expect(repo.clearedDefault, isTrue);
  });

  test(
    'selectedVehicleProvider se refresca tras actualizar el vehículo',
    () async {
      final initial = Vehicle(
        id: 1,
        name: 'A',
        type: 'car',
        currentMileage: 88000,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final repo = _MutableVehicleRepository(initial);
      final container = ProviderContainer(
        overrides: [vehicleRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final before = await container.read(selectedVehicleProvider(1).future);
      expect(before!.soatExpiresAt, isNull);

      final updated = initial.copyWith(
        soatExpiresAt: DateTime(2027, 1, 1),
        updatedAt: DateTime(2024, 2, 1),
      );
      await container.read(vehiclesNotifierProvider.notifier).update(updated);

      final after = await container.read(selectedVehicleProvider(1).future);
      expect(after!.soatExpiresAt, DateTime(2027, 1, 1));
    },
  );
}
