import '../../../core/database/database_helper.dart';
import '../../../core/utils/formatters.dart';
import '../maintenance/models/workshop.dart';

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
