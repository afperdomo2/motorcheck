import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:motorcheck/core/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('database initialization creates all tables', () async {
    final db = await DatabaseHelper.instance.database;

    final vehicleTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='vehicles'",
    );
    expect(vehicleTable.isNotEmpty, isTrue);

    final maintenancesTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='maintenances'",
    );
    expect(maintenancesTable.isNotEmpty, isTrue);

    final itemsTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='maintenance_items'",
    );
    expect(itemsTable.isNotEmpty, isTrue);
  });

  test('vehicles table has expected columns', () async {
    final db = await DatabaseHelper.instance.database;

    final columns = await db.rawQuery('PRAGMA table_info(vehicles)');
    final columnNames = columns.map((c) => c['name'] as String).toList();

    expect(columnNames.contains('id'), isTrue);
    expect(columnNames.contains('name'), isTrue);
    expect(columnNames.contains('type'), isTrue);
    expect(columnNames.contains('brand'), isTrue);
    expect(columnNames.contains('model'), isTrue);
    expect(columnNames.contains('year'), isTrue);
    expect(columnNames.contains('plate'), isTrue);
    expect(columnNames.contains('color'), isTrue);
    expect(columnNames.contains('image_path'), isTrue);
    expect(columnNames.contains('current_mileage'), isTrue);
    expect(columnNames.contains('mileage_updated_at'), isTrue);
    expect(columnNames.contains('is_default'), isTrue);
    expect(columnNames.contains('created_at'), isTrue);
    expect(columnNames.contains('updated_at'), isTrue);
  });
}
