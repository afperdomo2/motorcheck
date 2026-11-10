import 'dart:convert';

import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/vehicle_restriction.dart';

class RestrictionRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<VehicleRestriction?> getByVehicleId(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'vehicle_restrictions',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> upsert(VehicleRestriction restriction) async {
    final db = await _db.database;
    final existing = await getByVehicleId(restriction.vehicleId);
    if (existing == null) {
      return db.insert('vehicle_restrictions', _toMap(restriction));
    }
    await db.update(
      'vehicle_restrictions',
      _toMap(restriction, includeId: false),
      where: 'id = ?',
      whereArgs: [existing.id],
    );
    return existing.id!;
  }

  Future<void> delete(int vehicleId) async {
    final db = await _db.database;
    await db.delete(
      'vehicle_restrictions',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
  }

  Map<String, dynamic> _toMap(
    VehicleRestriction restriction, {
    bool includeId = true,
  }) => {
    if (includeId && restriction.id != null) 'id': restriction.id,
    'vehicle_id': restriction.vehicleId,
    'enabled': restriction.enabled ? 1 : 0,
    'city': restriction.city,
    'days': jsonEncode(restriction.days),
    'start_time': restriction.startTime,
    'end_time': restriction.endTime,
    'exempt': restriction.exempt ? 1 : 0,
    'notes': restriction.notes,
    'created_at': formatDateTime(restriction.createdAt),
    'updated_at': formatDateTime(restriction.updatedAt),
  };

  VehicleRestriction _fromMap(Map<String, dynamic> m) {
    final daysRaw = m['days'] as String? ?? '[]';
    final decoded = jsonDecode(daysRaw) as List<dynamic>;
    return VehicleRestriction(
      id: m['id'] as int,
      vehicleId: m['vehicle_id'] as int,
      enabled: (m['enabled'] as int? ?? 0) == 1,
      city: m['city'] as String?,
      days: decoded.map((e) => e as int).toList(),
      startTime: m['start_time'] as String? ?? '06:00',
      endTime: m['end_time'] as String? ?? '21:00',
      exempt: (m['exempt'] as int? ?? 0) == 1,
      notes: m['notes'] as String?,
      createdAt: parseDateTime(m['created_at'] as String),
      updatedAt: parseDateTime(m['updated_at'] as String),
    );
  }
}
