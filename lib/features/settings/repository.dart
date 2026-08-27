import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/formatters.dart';
import '../maintenance/models/workshop.dart';
import 'models/maintenance_category.dart';

class WorkshopRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Workshop>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('workshops', orderBy: 'name ASC');
    return maps.map(_fromMap).toList();
  }

  Future<Workshop?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('workshops', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> insert(String name, {String? location}) async {
    final db = await _db.database;
    return db.insert('workshops', {
      'name': name,
      'location': location,
      'created_at': formatDateTime(DateTime.now()),
    });
  }

  Future<void> update(Workshop workshop) async {
    final db = await _db.database;
    await db.update(
      'workshops',
      {'name': workshop.name, 'location': workshop.location},
      where: 'id = ?',
      whereArgs: [workshop.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('workshops', where: 'id = ?', whereArgs: [id]);
  }

  Workshop _fromMap(Map<String, dynamic> m) => Workshop(
    id: m['id'] as int,
    name: m['name'] as String,
    location: m['location'] as String?,
    createdAt: parseDateTime(m['created_at'] as String),
  );
}

class CategoryInUseException implements Exception {
  final int count;
  const CategoryInUseException(this.count);

  @override
  String toString() =>
      'Categoría en uso en $count mantenimiento'
      '${count == 1 ? '' : 's'}.';
}

class MaintenanceCategoryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<MaintenanceCategory>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenance_categories',
      orderBy: 'vehicle_type ASC, sort_order ASC',
    );
    return maps.map(_catFromMap).toList();
  }

  Future<List<MaintenanceCategory>> getByVehicleType(String type) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenance_categories',
      where: 'vehicle_type = ?',
      whereArgs: [type],
      orderBy: 'sort_order ASC',
    );
    return maps.map(_catFromMap).toList();
  }

  Future<MaintenanceCategory?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenance_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _catFromMap(maps.first);
  }

  Future<MaintenanceCategory?> getByKey(String key) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenance_categories',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return _catFromMap(maps.first);
  }

  Future<int> insert(MaintenanceCategory category) async {
    final db = await _db.database;
    await _ensureUniqueKey(db, category.key);
    final maxOrder = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT MAX(sort_order) FROM maintenance_categories '
        'WHERE vehicle_type = ?',
        [category.vehicleType],
      ),
    );
    return db.insert('maintenance_categories', {
      'key': category.key,
      'name': category.name,
      'icon_name': category.iconName,
      'vehicle_type': category.vehicleType,
      'sort_order': (maxOrder ?? 0) + 1,
      'interval_km': category.intervalKm,
      'warning_km': category.warningKm,
      'created_at': formatDateTime(category.createdAt),
    });
  }

  Future<void> update(MaintenanceCategory category) async {
    final db = await _db.database;
    final existing = await getById(category.id!);
    if (existing == null) return;

    final maps = await db.query(
      'maintenance_categories',
      where: 'key = ? AND id != ?',
      whereArgs: [category.key, category.id],
    );
    if (maps.isNotEmpty) {
      throw Exception(
        'Ya existe una categoría con la clave "${category.key}".',
      );
    }

    await db.update(
      'maintenance_categories',
      {
        'key': category.key,
        'name': category.name,
        'icon_name': category.iconName,
        'sort_order': category.sortOrder,
        'interval_km': category.intervalKm,
        'warning_km': category.warningKm,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    final category = await getById(id);
    if (category == null) return;

    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM maintenance_items WHERE category = ?',
        [category.key],
      ),
    );
    if (count != null && count > 0) {
      throw CategoryInUseException(count);
    }

    await db.delete('maintenance_categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _ensureUniqueKey(Database db, String key) async {
    final maps = await db.query(
      'maintenance_categories',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      throw Exception('Ya existe una categoría con la clave "$key".');
    }
  }

  MaintenanceCategory _catFromMap(Map<String, dynamic> m) =>
      MaintenanceCategory(
        id: m['id'] as int,
        key: m['key'] as String,
        name: m['name'] as String,
        iconName: m['icon_name'] as String? ?? 'build',
        vehicleType: m['vehicle_type'] as String,
        sortOrder: m['sort_order'] as int? ?? 0,
        intervalKm: m['interval_km'] as int?,
        warningKm: m['warning_km'] as int?,
        createdAt: parseDateTime(m['created_at'] as String),
      );
}
