import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/vehicle_document.dart';

class DocumentsRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<VehicleDocument>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'documents',
      orderBy: 'expires_at DESC, id DESC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<List<VehicleDocument>> getByVehicleId(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'documents',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'expires_at DESC, id DESC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<List<VehicleDocument>> getGlobal() async {
    final db = await _db.database;
    final maps = await db.query(
      'documents',
      where: 'vehicle_id IS NULL',
      orderBy: 'expires_at DESC, id DESC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<VehicleDocument?> getLatestByType(int vehicleId, String type) async {
    final db = await _db.database;
    final maps = await db.query(
      'documents',
      where: 'vehicle_id = ? AND type = ?',
      whereArgs: [vehicleId, type],
      orderBy: 'expires_at DESC, id DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<VehicleDocument?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('documents', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> insert(VehicleDocument document) async {
    final db = await _db.database;
    return db.insert('documents', _toMap(document));
  }

  Future<void> update(VehicleDocument document) async {
    final db = await _db.database;
    await db.update(
      'documents',
      _toMap(document, includeId: false),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  /// Mantiene las columnas legado de SOAT/RTM alineadas solo por
  /// compatibilidad. La fuente de verdad sigue siendo `documents`.
  Future<void> setLegacyVehicleDate(
    int vehicleId,
    String type,
    DateTime? date,
  ) async {
    final column = switch (type) {
      'soat' => 'soat_expires_at',
      'rtm' => 'rtm_expires_at',
      _ => null,
    };
    if (column == null) return;
    final db = await _db.database;
    await db.update(
      'vehicles',
      {column: date != null ? formatDateTime(date) : null},
      where: 'id = ?',
      whereArgs: [vehicleId],
    );
  }

  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM documents');
    return (result.first['count'] as int?) ?? 0;
  }

  Map<String, dynamic> _toMap(
    VehicleDocument document, {
    bool includeId = true,
  }) => {
    if (includeId && document.id != null) 'id': document.id,
    'vehicle_id': document.vehicleId,
    'type': document.type,
    'name': document.name,
    'number': document.number,
    'issued_at': document.issuedAt != null
        ? formatDate(document.issuedAt!)
        : null,
    'expires_at': formatDate(document.expiresAt),
    'file_path': document.filePath,
    'notes': document.notes,
    'created_at': formatDateTime(document.createdAt),
    'updated_at': formatDateTime(document.updatedAt),
  };

  VehicleDocument _fromMap(Map<String, dynamic> m) => VehicleDocument(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int?,
    type: m['type'] as String,
    name: m['name'] as String?,
    number: m['number'] as String?,
    issuedAt: m['issued_at'] != null
        ? parseDate(m['issued_at'] as String)
        : null,
    expiresAt: parseDate(m['expires_at'] as String),
    filePath: m['file_path'] as String?,
    notes: m['notes'] as String?,
    createdAt: parseDateTime(m['created_at'] as String),
    updatedAt: parseDateTime(m['updated_at'] as String),
  );
}
