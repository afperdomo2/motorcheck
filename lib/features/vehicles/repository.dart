import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/vehicle.dart';

class VehicleRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  String get _now => formatDateTime(DateTime.now());

  Future<List<Vehicle>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('vehicles', orderBy: 'name ASC');
    return maps.map(_fromMap).toList();
  }

  Future<Vehicle?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('vehicles', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<Vehicle?> getDefault() async {
    final db = await _db.database;
    final maps = await db.query(
      'vehicles',
      where: 'is_default = ?',
      whereArgs: [1],
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> insert(Vehicle vehicle) async {
    final db = await _db.database;
    return db.insert('vehicles', _toMap(vehicle));
  }

  Future<void> update(Vehicle vehicle) async {
    final db = await _db.database;
    await db.update(
      'vehicles',
      _toMap(vehicle),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setDefault(int id) async {
    final db = await _db.database;
    await db.update('vehicles', {'is_default': 0});
    await db.update(
      'vehicles',
      {'is_default': 1, 'updated_at': _now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(Vehicle v) => {
    if (v.id != null) 'id': v.id,
    'name': v.name,
    'type': v.type,
    'brand': v.brand,
    'model': v.model,
    'year': v.year,
    'plate': v.plate,
    'color': v.color,
    'image_path': v.imagePath,
    'is_default': v.isDefault ? 1 : 0,
    'created_at': formatDateTime(v.createdAt),
    'updated_at': formatDateTime(v.updatedAt),
  };

  Vehicle _fromMap(Map<String, dynamic> m) => Vehicle(
    id: m['id'] as int,
    name: m['name'] as String,
    type: m['type'] as String,
    brand: m['brand'] as String?,
    model: m['model'] as String?,
    year: m['year'] as int?,
    plate: m['plate'] as String?,
    color: m['color'] as String?,
    imagePath: m['image_path'] as String?,
    isDefault: (m['is_default'] as int?) == 1,
    createdAt: parseDateTime(m['created_at'] as String),
    updatedAt: parseDateTime(m['updated_at'] as String),
  );
}
