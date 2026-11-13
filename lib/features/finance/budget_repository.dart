import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/budget.dart';

class BudgetRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  String get currentPeriod {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<Budget?> getForVehiclePeriod(int vehicleId, String period) async {
    final db = await _db.database;
    final maps = await db.query(
      'budgets',
      where: 'vehicle_id = ? AND period = ?',
      whereArgs: [vehicleId, period],
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> upsert(Budget budget) async {
    final db = await _db.database;
    final existing = await getForVehiclePeriod(
      budget.vehicleId!,
      budget.period,
    );
    if (existing == null) {
      return db.insert('budgets', {
        'vehicle_id': budget.vehicleId,
        'period': budget.period,
        'amount': budget.amount,
        'created_at': formatDateTime(budget.createdAt),
        'updated_at': formatDateTime(budget.updatedAt),
      });
    }
    await db.update(
      'budgets',
      {'amount': budget.amount, 'updated_at': formatDateTime(budget.updatedAt)},
      where: 'id = ?',
      whereArgs: [existing.id],
    );
    return existing.id!;
  }

  Future<void> delete(int vehicleId, String period) async {
    final db = await _db.database;
    await db.delete(
      'budgets',
      where: 'vehicle_id = ? AND period = ?',
      whereArgs: [vehicleId, period],
    );
  }

  Budget _fromMap(Map<String, dynamic> m) => Budget(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int?,
    period: m['period'] as String,
    amount: (m['amount'] as num?)?.toDouble() ?? 0,
    createdAt: parseDateTime(m['created_at'] as String),
    updatedAt: parseDateTime(m['updated_at'] as String),
  );
}
