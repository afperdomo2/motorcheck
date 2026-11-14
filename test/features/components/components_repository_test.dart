import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/components/repository.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import '../../helpers/database_test_helper.dart';

void main() {
  setUpAll(TestDatabase.setUp);
  tearDownAll(TestDatabase.tearDown);

  Future<int> createVehicle({String type = 'car'}) {
    return VehicleRepository().insert(
      Vehicle(
        name: 'Componentes',
        type: type,
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
        categoryKey: 'car_tires',
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
    expect(components.first.categoryKey, 'car_tires');
    expect(components.first.active, isTrue);
    expect(components.first.isSystem, isFalse);

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

  test('la plantilla se crea una sola vez y protege el borrado', () async {
    final vehicleId = await createVehicle();
    final repo = ComponentsRepository();

    final created = await repo.seedDefaults(
      vehicleId: vehicleId,
      vehicleType: 'car',
      installedAt: DateTime(2026, 1, 1),
      installedKm: 150000,
    );
    expect(created, 7);

    final again = await repo.seedDefaults(
      vehicleId: vehicleId,
      vehicleType: 'car',
      installedAt: DateTime(2026, 1, 1),
      installedKm: 150000,
    );
    expect(again, 0);

    final components = await repo.getByVehicleId(vehicleId);
    expect(components.where((c) => c.type == 'tire'), hasLength(4));
    expect(components.where((c) => c.type == 'brakes'), hasLength(2));
    expect(components.where((c) => c.isSystem), hasLength(7));

    await expectLater(
      repo.delete(components.first.id!),
      throwsA(isA<StateError>()),
    );
  });

  test('el camión y otro no crean plantilla', () async {
    final repo = ComponentsRepository();
    final truckId = await createVehicle(type: 'truck');
    expect(
      await repo.seedDefaults(
        vehicleId: truckId,
        vehicleType: 'truck',
        installedAt: DateTime(2026, 1, 1),
      ),
      0,
    );

    final otherId = await createVehicle(type: 'other');
    expect(
      await repo.seedDefaults(
        vehicleId: otherId,
        vehicleType: 'other',
        installedAt: DateTime(2026, 1, 1),
      ),
      0,
    );
  });

  test(
    'el reemplazo vive en el mantenimiento y alimenta el historial',
    () async {
      final vehicleId = await createVehicle();
      final repo = ComponentsRepository();
      final now = DateTime(2026, 1, 10);

      final componentId = await repo.insert(
        VehicleComponent(
          vehicleId: vehicleId,
          name: 'Llanta trasera',
          type: 'tire',
          categoryKey: 'car_tires',
          installedAt: now,
          installedKm: 150000,
          intervalKm: 12000,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final maintenanceId = await MaintenanceRepository().insert(
        Maintenance(
          vehicleId: vehicleId,
          date: DateTime(2026, 11, 20),
          mileage: 158000,
          totalPartsCost: 250000,
          createdAt: DateTime(2026, 11, 20),
          updatedAt: DateTime(2026, 11, 20),
        ),
        [
          MaintenanceItem(
            maintenanceId: 0,
            category: 'car_tires',
            partsCost: 250000,
            componentId: componentId,
            createdAt: DateTime(2026, 11, 20),
          ),
        ],
      );

      final replacements = await repo.getReplacements(vehicleId);
      expect(replacements, hasLength(1));
      expect(replacements.first.componentId, componentId);
      expect(replacements.first.maintenanceId, maintenanceId);
      expect(replacements.first.date, DateTime(2026, 11, 20));
      expect(replacements.first.mileage, 158000);
      expect(replacements.first.partsCost, 250000);

      final latest = await repo.getLatestReplacement(componentId);
      expect(latest, isNotNull);

      await MaintenanceRepository().delete(maintenanceId);
      expect(await repo.getReplacements(vehicleId), isEmpty);
    },
  );

  test('un componente de plantilla liberado se puede borrar', () async {
    final vehicleId = await createVehicle();
    final repo = ComponentsRepository();
    await repo.seedDefaults(
      vehicleId: vehicleId,
      vehicleType: 'car',
      installedAt: DateTime(2026, 1, 1),
      installedKm: 150000,
    );

    await repo.releaseSystemComponents(vehicleId);
    final components = await repo.getByVehicleId(vehicleId);
    expect(components.every((c) => !c.isSystem), isTrue);
    await repo.delete(components.first.id!);
    expect(await repo.getByVehicleId(vehicleId), hasLength(6));
  });
}
