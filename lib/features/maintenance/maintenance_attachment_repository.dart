import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/maintenance_attachment.dart';

class MaintenanceAttachmentRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<MaintenanceAttachment>> getByMaintenanceId(
    int maintenanceId,
  ) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenance_attachments',
      where: 'maintenance_id = ?',
      whereArgs: [maintenanceId],
      orderBy: 'created_at DESC, id DESC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<int> insert(MaintenanceAttachment attachment) async {
    final db = await _db.database;
    return db.insert('maintenance_attachments', {
      'maintenance_id': attachment.maintenanceId,
      'item_id': attachment.itemId,
      'name': attachment.name,
      'file_path': attachment.filePath,
      'created_at': formatDateTime(attachment.createdAt),
    });
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete(
      'maintenance_attachments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  MaintenanceAttachment _fromMap(Map<String, dynamic> m) =>
      MaintenanceAttachment(
        id: m['id'] as int,
        maintenanceId: m['maintenance_id'] as int,
        itemId: m['item_id'] as int?,
        name: m['name'] as String,
        filePath: m['file_path'] as String,
        createdAt: parseDateTime(m['created_at'] as String),
      );
}
