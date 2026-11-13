import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/fuel_log.dart';

class FuelStats {
  const FuelStats({
    this.count = 0,
    this.totalQuantity = 0,
    this.totalCost = 0,
    this.currentMonthSpent = 0,
    this.averageConsumption,
    this.litersPer100Km,
    this.costPerKm,
    this.lastLog,
  });

  final int count;
  final double totalQuantity;
  final double totalCost;
  final double currentMonthSpent;

  /// Distancia por unidad: km/L, km/m³ o km/kWh.
  final double? averageConsumption;
  final double? litersPer100Km;
  final double? costPerKm;
  final FuelLog? lastLog;

  bool get hasData => count > 0;

  String consumptionLabel() {
    final value = averageConsumption;
    if (value == null || value <= 0) return 'Sin datos';
    return '${value.toStringAsFixed(1)} km/${_unit(lastLog?.fuelType)}';
  }

  String per100Label() {
    final value = litersPer100Km;
    if (value == null || value <= 0) return 'Sin datos';
    return '${value.toStringAsFixed(1)} /100 km';
  }

  static String _unit(String? fuelType) {
    final option = fuelTypeFor(fuelType ?? 'gasoline');
    return option.unit;
  }
}

class FuelRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<FuelLog>> getByVehicleId(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'fuel_logs',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC, odometer DESC, id DESC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<FuelLog?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('fuel_logs', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> insert(FuelLog log) async {
    final db = await _db.database;
    return db.transaction((txn) async {
      final id = await txn.insert('fuel_logs', _toMap(log));
      await _registerMileage(txn, log.vehicleId, log.odometer, log.date);
      return id;
    });
  }

  Future<void> update(FuelLog log) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'fuel_logs',
        _toMap(log, includeId: false),
        where: 'id = ?',
        whereArgs: [log.id],
      );
      await _registerMileage(txn, log.vehicleId, log.odometer, log.date);
    });
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('fuel_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<FuelStats> getStats(int vehicleId) async {
    final logs = await getByVehicleId(vehicleId);
    if (logs.isEmpty) return const FuelStats();

    final ascending = List<FuelLog>.from(logs)
      ..sort((a, b) {
        final byOdometer = a.odometer.compareTo(b.odometer);
        if (byOdometer != 0) return byOdometer;
        return a.date.compareTo(b.date);
      });

    final now = DateTime.now();
    final currentMonthSpent = logs
        .where(
          (log) => log.date.year == now.year && log.date.month == now.month,
        )
        .fold<double>(0, (sum, log) => sum + log.totalCost);

    final totalQuantity = logs.fold<double>(
      0,
      (sum, log) => sum + log.quantity,
    );
    final totalCost = logs.fold<double>(0, (sum, log) => sum + log.totalCost);

    final fullTanks = <int>[
      for (var i = 0; i < ascending.length; i++)
        if (ascending[i].fullTank && ascending[i].quantity > 0) i,
    ];

    double? averageConsumption;
    double? litersPer100Km;
    double? costPerKm;

    if (fullTanks.length >= 2) {
      final firstIndex = fullTanks.first;
      final lastIndex = fullTanks.last;
      final distance =
          ascending[lastIndex].odometer - ascending[firstIndex].odometer;
      var fuel = 0.0;
      var fuelCost = 0.0;
      for (var i = firstIndex + 1; i <= lastIndex; i++) {
        fuel += ascending[i].quantity;
        fuelCost += ascending[i].totalCost;
      }
      if (distance > 0 && fuel > 0) {
        averageConsumption = distance / fuel;
        litersPer100Km = fuel / distance * 100;
      }
      if (distance > 0 && fuelCost > 0) {
        costPerKm = fuelCost / distance;
      }
    } else {
      final first = ascending.first;
      final last = ascending.last;
      final distance = last.odometer - first.odometer;
      if (distance > 0) {
        costPerKm = totalCost / distance;
      }
    }

    return FuelStats(
      count: logs.length,
      totalQuantity: totalQuantity,
      totalCost: totalCost,
      currentMonthSpent: currentMonthSpent,
      averageConsumption: averageConsumption,
      litersPer100Km: litersPer100Km,
      costPerKm: costPerKm,
      lastLog: logs.first,
    );
  }

  Future<void> _registerMileage(
    DatabaseExecutor txn,
    int vehicleId,
    int odometer,
    DateTime date,
  ) async {
    final now = formatDateTime(DateTime.now());
    await txn.insert('mileage_readings', {
      'vehicle_id': vehicleId,
      'date': formatDate(date),
      'mileage': odometer,
      'source': 'fuel',
      'created_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await txn.rawUpdate(
      'UPDATE vehicles SET current_mileage = ?, mileage_updated_at = ?, '
      'updated_at = ? WHERE id = ? '
      'AND (current_mileage IS NULL OR current_mileage < ?)',
      [odometer, now, now, vehicleId, odometer],
    );
  }

  Map<String, dynamic> _toMap(FuelLog log, {bool includeId = true}) => {
    if (includeId && log.id != null) 'id': log.id,
    'vehicle_id': log.vehicleId,
    'date': formatDate(log.date),
    'odometer': log.odometer,
    'quantity': log.quantity,
    'unit_price': log.unitPrice,
    'total_cost': log.totalCost,
    'fuel_type': log.fuelType,
    'station': log.station,
    'full_tank': log.fullTank ? 1 : 0,
    'notes': log.notes,
    'created_at': formatDateTime(log.createdAt),
    'updated_at': formatDateTime(log.updatedAt),
  };

  FuelLog _fromMap(Map<String, dynamic> m) => FuelLog(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int,
    date: parseDate(m['date'] as String),
    odometer: m['odometer'] as int,
    quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
    unitPrice: (m['unit_price'] as num?)?.toDouble() ?? 0,
    totalCost: (m['total_cost'] as num?)?.toDouble() ?? 0,
    fuelType: m['fuel_type'] as String? ?? 'gasoline',
    station: m['station'] as String?,
    fullTank: (m['full_tank'] as int? ?? 1) == 1,
    notes: m['notes'] as String?,
    createdAt: parseDateTime(m['created_at'] as String),
    updatedAt: parseDateTime(m['updated_at'] as String),
  );
}
