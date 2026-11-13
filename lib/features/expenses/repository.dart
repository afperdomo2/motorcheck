import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/expense.dart';
import 'models/expense_category.dart';

class ExpenseCategoryInUseException implements Exception {
  final int count;
  const ExpenseCategoryInUseException(this.count);

  @override
  String toString() =>
      'Categoría en uso en $count gasto${count == 1 ? '' : 's'}.';
}

class ExpenseCategoryKeyExistsException implements Exception {
  const ExpenseCategoryKeyExistsException();

  @override
  String toString() => 'Ya existe una categoría de gasto con ese nombre.';
}

class ExpenseCategoryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<ExpenseCategory>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      'expense_categories',
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<ExpenseCategory?> getByKey(String key) async {
    final db = await _db.database;
    final maps = await db.query(
      'expense_categories',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> insert(ExpenseCategory category) async {
    final db = await _db.database;
    await _ensureUniqueName(db, category.name);
    final maxOrder = Sqflite.firstIntValue(
      await db.rawQuery('SELECT MAX(sort_order) FROM expense_categories'),
    );
    return db.insert('expense_categories', {
      'key': category.key,
      'name': category.name,
      'icon_name': category.iconName,
      'sort_order': category.sortOrder > 0
          ? category.sortOrder
          : (maxOrder ?? 0) + 1,
      'created_at': formatDateTime(category.createdAt),
    });
  }

  Future<void> update(ExpenseCategory category) async {
    final db = await _db.database;
    await _ensureUniqueName(db, category.name, excludeId: category.id);
    await db.update(
      'expense_categories',
      {
        'name': category.name,
        'icon_name': category.iconName,
        'sort_order': category.sortOrder,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'expense_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return;
    final key = maps.first['key'] as String;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM expenses WHERE category_key = ?',
        [key],
      ),
    );
    if (count != null && count > 0) {
      throw ExpenseCategoryInUseException(count);
    }
    await db.delete('expense_categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _ensureUniqueName(
    Database db,
    String name, {
    int? excludeId,
  }) async {
    final maps = await db.query(
      'expense_categories',
      where:
          'LOWER(name) = LOWER(?)'
          '${excludeId != null ? ' AND id != ?' : ''}',
      whereArgs: [name.trim(), ?excludeId],
    );
    if (maps.isNotEmpty) {
      throw const ExpenseCategoryKeyExistsException();
    }
  }

  ExpenseCategory _fromMap(Map<String, dynamic> m) => ExpenseCategory(
    id: m['id'] as int,
    key: m['key'] as String,
    name: m['name'] as String,
    iconName: m['icon_name'] as String? ?? 'receipt_long',
    sortOrder: m['sort_order'] as int? ?? 0,
    createdAt: parseDateTime(m['created_at'] as String),
  );
}

class ExpenseRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Expense>> getForVehicle(
    int vehicleId, {
    bool includeGlobal = true,
  }) async {
    final db = await _db.database;
    final where = includeGlobal
        ? '(vehicle_id = ? OR vehicle_id IS NULL)'
        : 'vehicle_id = ?';
    final maps = await db.query(
      'expenses',
      where: where,
      whereArgs: [vehicleId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<List<Expense>> getGlobal() async {
    final db = await _db.database;
    final maps = await db.query(
      'expenses',
      where: 'vehicle_id IS NULL',
      orderBy: 'date DESC, id DESC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<List<Expense>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('expenses', orderBy: 'date DESC, id DESC');
    return maps.map(_fromMap).toList();
  }

  Future<Expense?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> insert(Expense expense) async {
    final db = await _db.database;
    return db.insert('expenses', _toMap(expense));
  }

  Future<void> update(Expense expense) async {
    final db = await _db.database;
    await db.update(
      'expenses',
      _toMap(expense, includeId: false),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _toMap(Expense expense, {bool includeId = true}) => {
    if (includeId && expense.id != null) 'id': expense.id,
    'vehicle_id': expense.vehicleId,
    'category_key': expense.categoryKey,
    'date': formatDate(expense.date),
    'amount': expense.amount,
    'notes': expense.notes,
    'receipt_path': expense.receiptPath,
    'created_at': formatDateTime(expense.createdAt),
    'updated_at': formatDateTime(expense.updatedAt),
  };

  Expense _fromMap(Map<String, dynamic> m) => Expense(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int?,
    categoryKey: m['category_key'] as String,
    date: parseDate(m['date'] as String),
    amount: (m['amount'] as num?)?.toDouble() ?? 0,
    notes: m['notes'] as String?,
    receiptPath: m['receipt_path'] as String?,
    createdAt: parseDateTime(m['created_at'] as String),
    updatedAt: parseDateTime(m['updated_at'] as String),
  );
}
