import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/components/models/component_service.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/components/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setUpAll(TestDatabase.setUp);
  tearDownAll(TestDatabase.tearDown);

  Future<int> createVehicle() {
    return VehicleRepository().insert(
      Vehicle(
        name: 'Componentes',
        currentMileage: 150000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  }

  test('CRUD de componentes por vehículo', () async {
    final vehicleId = await createVehicle();
    final repo = ComponentsRepository();
    final now = DateTime(2026, 1, 10);

    final id = await repo.insert(
      VehicleComponent(
        vehicleId: vehicleId,
        name: 'Llanta delantera',
        type: 'tire',
        position: 'Delantera',
        installedAt: now,
        installedKm: 150000,
        intervalKm: 10000,
        warningKm: 1000,
        createdAt: now,
        updatedAt: now,
      ),
    );

    var components = await repo.getByVehicleId(vehicleId);
    expect(components, hasLength(1));
    expect(components.first.name, 'Llanta delantera');
    expect(components.first.installedKm, 150000);
    expect(components.first.active, isTrue);

    await repo.update(
      components.first.copyWith(name: 'Llanta delantera nueva', active: false),
    );
    final updated = await repo.getById(id);
    expect(updated!.name, 'Llanta delantera nueva');
    expect(updated.active, isFalse);

    await repo.delete(id);
    components = await repo.getByVehicleId(vehicleId);
    expect(components, isEmpty);
  });

  test('un servicio con reset reinicia el ciclo del componente', () async {
    final vehicleId = await createVehicle();
    final repo = ComponentsRepository();
    final installedAt = DateTime(2026, 1, 10);

    final id = await repo.insert(
      VehicleComponent(
        vehicleId: vehicleId,
        name: 'Batería',
        type: 'battery',
        installedAt: installedAt,
        installedKm: 150000,
        intervalMonths: 36,
        createdAt: installedAt,
        updatedAt: installedAt,
      ),
    );

    await repo.registerService(
      ComponentService(
        componentId: id,
        date: DateTime(2026, 6, 20),
        odometer: 158000,
        cost: 320000,
        notes: 'Cambio de batería',
        resetInterval: true,
        createdAt: DateTime(2026, 6, 20),
      ),
    );

    final component = await repo.getById(id);
    expect(component!.installedAt, DateTime(2026, 6, 20));
    expect(component.installedKm, 158000);

    final services = await repo.getServices(id);
    expect(services, hasLength(1));
    expect(services.first.cost, 320000);
    expect(services.first.resetInterval, isTrue);
  });

  test('un servicio sin reset conserva la instalación', () async {
    final vehicleId = await createVehicle();
    final repo = ComponentsRepository();
    final installedAt = DateTime(2026, 1, 10);

    final id = await repo.insert(
      VehicleComponent(
        vehicleId: vehicleId,
        name: 'Llanta trasera',
        type: 'tire',
        installedAt: installedAt,
        installedKm: 150000,
        intervalKm: 12000,
        createdAt: installedAt,
        updatedAt: installedAt,
      ),
    );

    await repo.registerService(
      ComponentService(
        componentId: id,
        date: DateTime(2026, 4, 1),
        odometer: 153000,
        notes: 'Rotación',
        createdAt: DateTime(2026, 4, 1),
      ),
    );

    final component = await repo.getById(id);
    expect(component!.installedAt, installedAt);
    expect(component.installedKm, 150000);
    expect(await repo.getServices(id), hasLength(1));
  });

  test('eliminar un componente borra sus servicios', () async {
    final vehicleId = await createVehicle();
    final repo = ComponentsRepository();
    final now = DateTime(2026, 1, 10);

    final id = await repo.insert(
      VehicleComponent(
        vehicleId: vehicleId,
        name: 'Cadena',
        type: 'chain',
        installedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repo.registerService(
      ComponentService(componentId: id, date: now, createdAt: now),
    );

    await repo.delete(id);
    expect(await repo.getServices(id), isEmpty);
  });
}
