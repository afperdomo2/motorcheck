import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/mileage_reading.dart';

class MileageStats {
  const MileageStats({
    this.currentMileage,
    this.lastReadingDate,
    this.averageKmPerDay,
    this.firstReading,
    this.lastReading,
  });

  final int? currentMileage;
  final DateTime? lastReadingDate;
  final double? averageKmPerDay;
  final MileageReading? firstReading;
  final MileageReading? lastReading;

  bool get hasEnoughData => averageKmPerDay != null && averageKmPerDay! > 0;

  int? get daysSinceLastReading {
    final last = lastReadingDate;
    if (last == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(last.year, last.month, last.day);
    return today.difference(day).inDays;
  }

  DateTime? estimatedDateFor(int remainingKm) {
    final avg = averageKmPerDay;
    if (avg == null || avg <= 0) return null;
    final days = (remainingKm / avg).ceil();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: days));
  }
}

class MileageRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<MileageReading>> getByVehicleId(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'mileage_readings',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date ASC, mileage ASC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<MileageReading?> getLastReading(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'mileage_readings',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC, mileage DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  /// Registra una lectura y sube el kilometraje del vehículo solo si la nueva
  /// lectura es mayor. La corrección manual se hace desde Editar vehículo.
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('mileage_readings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addReading({
    required int vehicleId,
    required int mileage,
    DateTime? date,
    String source = 'manual',
  }) async {
    final db = await _db.database;
    final readingDate = date ?? DateTime.now();
    final now = DateTime.now();

    await db.insert('mileage_readings', {
      'vehicle_id': vehicleId,
      'date': formatDate(readingDate),
      'mileage': mileage,
      'source': source,
      'created_at': formatDateTime(now),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.rawUpdate(
      'UPDATE vehicles '
      'SET current_mileage = ?, mileage_updated_at = ?, updated_at = ? '
      'WHERE id = ? AND (current_mileage IS NULL OR current_mileage < ?)',
      [mileage, formatDateTime(now), formatDateTime(now), vehicleId, mileage],
    );
  }

  Future<MileageStats> getStats(int vehicleId) async {
    final readings = await getByVehicleId(vehicleId);
    if (readings.isEmpty) return const MileageStats();

    final last = readings.last;
    final recentThreshold = DateTime.now().subtract(const Duration(days: 180));
    final recent = readings
        .where((r) => !r.date.isBefore(recentThreshold))
        .toList();
    final sample = recent.length >= 2 ? recent : readings;
    final first = sample.first;
    final sampleLast = sample.last;

    final days = sampleLast.date.difference(first.date).inDays;
    final distance = sampleLast.mileage - first.mileage;
    final average = days > 0 && distance > 0 ? distance / days : null;

    return MileageStats(
      currentMileage: last.mileage,
      lastReadingDate: last.date,
      averageKmPerDay: average,
      firstReading: first,
      lastReading: last,
    );
  }

  MileageReading _fromMap(Map<String, dynamic> m) => MileageReading(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int,
    date: parseDate(m['date'] as String),
    mileage: m['mileage'] as int,
    source: m['source'] as String? ?? 'manual',
    createdAt: parseDateTime(m['created_at'] as String),
  );
}
