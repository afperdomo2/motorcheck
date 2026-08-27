import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/maintenance.dart';
import 'models/maintenance_item.dart';

class MaintenanceRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Maintenance>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('maintenances', orderBy: 'date DESC');
    return maps.map(_maintenanceFromMap).toList();
  }

  Future<List<Maintenance>> getByVehicleId(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenances',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
    return maps.map(_maintenanceFromMap).toList();
  }

  Future<Maintenance?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenances',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _maintenanceFromMap(maps.first);
  }

  Future<List<MaintenanceItem>> getItems(int maintenanceId) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenance_items',
      where: 'maintenance_id = ?',
      whereArgs: [maintenanceId],
    );
    return maps.map(_itemFromMap).toList();
  }

  Future<int> insert(
    Maintenance maintenance,
    List<MaintenanceItem> items,
  ) async {
    final db = await _db.database;
    return db.transaction((txn) async {
      final id = await txn.insert(
        'maintenances',
        _maintenanceToMap(maintenance),
      );
      await _insertItems(txn, id, items);
      if (maintenance.mileage != null) {
        await txn.update(
          'vehicles',
          {
            'current_mileage': maintenance.mileage,
            'mileage_updated_at': formatDateTime(DateTime.now()),
            'updated_at': formatDateTime(DateTime.now()),
          },
          where: 'id = ?',
          whereArgs: [maintenance.vehicleId],
        );
      }
      return id;
    });
  }

  Future<void> update(
    Maintenance maintenance,
    List<MaintenanceItem> items,
  ) async {
    final db = await _db.database;
    await db.update(
      'maintenances',
      _maintenanceToMap(maintenance),
      where: 'id = ?',
      whereArgs: [maintenance.id],
    );
    await db.delete(
      'maintenance_items',
      where: 'maintenance_id = ?',
      whereArgs: [maintenance.id],
    );
    await _insertItems(db, maintenance.id!, items);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('maintenances', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Maintenance>> getRecentByVehicleId(
    int vehicleId, {
    int limit = 5,
  }) async {
    final db = await _db.database;
    final maps = await db.query(
      'maintenances',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map(_maintenanceFromMap).toList();
  }

  Future<int> countByVehicleId(int vehicleId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM maintenances WHERE vehicle_id = ?',
      [vehicleId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<({int count, double totalCost, DateTime? lastDate})>
  getMaintenanceSummary(int vehicleId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count, '
      'COALESCE(SUM(maintenance_cost + total_parts_cost), 0) as total, '
      'MAX(date) as last_date '
      'FROM maintenances WHERE vehicle_id = ?',
      [vehicleId],
    );
    final row = result.first;
    return (
      count: (row['count'] as int?) ?? 0,
      totalCost: (row['total'] as num?)?.toDouble() ?? 0,
      lastDate: row['last_date'] != null
          ? parseDate(row['last_date'] as String)
          : null,
    );
  }

  Future<List<MaintenanceItem>> getItemsByMaintenanceIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await _db.database;
    final placeholders = ids.map((_) => '?').join(',');
    final maps = await db.rawQuery(
      'SELECT * FROM maintenance_items WHERE maintenance_id IN ($placeholders)',
      ids,
    );
    return maps.map(_itemFromMap).toList();
  }

  Future<({int? mileage, DateTime? date})> getLastMileageByCategory(
    int vehicleId,
    String categoryKey,
  ) async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      'SELECT m.mileage, m.date '
      'FROM maintenances m '
      'JOIN maintenance_items i ON i.maintenance_id = m.id '
      'WHERE m.vehicle_id = ? AND i.category = ? AND m.mileage IS NOT NULL '
      'ORDER BY m.date DESC LIMIT 1',
      [vehicleId, categoryKey],
    );
    if (maps.isEmpty) return (mileage: null, date: null);
    final row = maps.first;
    return (
      mileage: row['mileage'] as int?,
      date: row['date'] != null ? parseDate(row['date'] as String) : null,
    );
  }

  Future<void> _insertItems(
    DatabaseExecutor db,
    int maintenanceId,
    List<MaintenanceItem> items,
  ) async {
    for (final item in items) {
      await db.insert('maintenance_items', _itemToMap(item, maintenanceId));
    }
  }

  Map<String, dynamic> _maintenanceToMap(Maintenance m) => {
    if (m.id != null) 'id': m.id,
    'vehicle_id': m.vehicleId,
    'date': formatDate(m.date),
    'mileage': m.mileage,
    'maintenance_cost': m.maintenanceCost,
    'total_parts_cost': m.totalPartsCost,
    'workshop_id': m.workshopId,
    'notes': m.notes,
    'created_at': formatDateTime(m.createdAt),
    'updated_at': formatDateTime(m.updatedAt),
  };

  Maintenance _maintenanceFromMap(Map<String, dynamic> m) => Maintenance(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int,
    date: parseDate(m['date'] as String),
    mileage: m['mileage'] as int?,
    maintenanceCost: (m['maintenance_cost'] as num?)?.toDouble() ?? 0,
    totalPartsCost: (m['total_parts_cost'] as num?)?.toDouble() ?? 0,
    workshopId: m['workshop_id'] as int?,
    notes: m['notes'] as String?,
    createdAt: parseDateTime(m['created_at'] as String),
    updatedAt: parseDateTime(m['updated_at'] as String),
  );

  Map<String, dynamic> _itemToMap(MaintenanceItem item, int maintenanceId) => {
    'maintenance_id': maintenanceId,
    'category': item.category,
    'parts_cost': item.partsCost,
    'notes': item.notes,
    'created_at': formatDateTime(item.createdAt),
  };

  MaintenanceItem _itemFromMap(Map<String, dynamic> m) => MaintenanceItem(
    id: m['id'] as int,
    maintenanceId: m['maintenance_id'] as int,
    category: m['category'] as String? ?? 'general',
    partsCost: (m['parts_cost'] as num?)?.toDouble() ?? 0,
    notes: m['notes'] as String?,
    createdAt: parseDateTime(m['created_at'] as String),
  );
}
