import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
import 'package:motorcheck/features/settings/repository.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await getDatabasesPath();
    final dbFile = File(p.join(dir, 'motorcheck.db'));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  final repo = MaintenanceCategoryRepository();

  test('insert respeta el orden indicado', () async {
    final category = MaintenanceCategory(
      key: 'car_test_order',
      name: 'Prueba de orden',
      vehicleType: 'car',
      sortOrder: 99,
      createdAt: DateTime(2024),
    );
    final id = await repo.insert(category);
    addTearDown(() => repo.delete(id));

    final loaded = await repo.getById(id);

    expect(loaded, isNotNull);
    expect(loaded!.sortOrder, 99);
  });

  test('editar el nombre conserva la clave original', () async {
    final category = MaintenanceCategory(
      key: 'car_test_key',
      name: 'Nombre original',
      vehicleType: 'car',
      sortOrder: 98,
      createdAt: DateTime(2024),
    );
    final id = await repo.insert(category);
    addTearDown(() => repo.delete(id));

    final loaded = await repo.getById(id);
    await repo.update(loaded!.copyWith(key: 'clave_nueva', name: 'Renombrada'));

    final updated = await repo.getById(id);

    expect(updated, isNotNull);
    expect(updated!.key, 'car_test_key');
    expect(updated.name, 'Renombrada');
  });

  test('rechaza un nombre duplicado para el mismo tipo', () async {
    final category = MaintenanceCategory(
      key: 'car_test_duplicate',
      name: 'Duplicada',
      vehicleType: 'car',
      createdAt: DateTime(2024),
    );
    final id = await repo.insert(category);
    addTearDown(() => repo.delete(id));

    expect(
      () => repo.insert(
        MaintenanceCategory(
          key: 'car_test_duplicate_2',
          name: 'Duplicada',
          vehicleType: 'car',
          createdAt: DateTime(2024),
        ),
      ),
      throwsA(isA<CategoryKeyExistsException>()),
    );
  });
}
