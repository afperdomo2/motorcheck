import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/checklist.dart';
import 'models/checklist_item.dart';
import 'models/inspection_answer.dart';
import 'models/inspection_run.dart';

class ChecklistRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Checklist>> getForVehicle(
    int vehicleId,
    String vehicleType,
  ) async {
    final db = await _db.database;
    final maps = await db.query(
      'checklists',
      where:
          '(vehicle_id IS NULL OR vehicle_id = ?) AND '
          '(vehicle_type IS NULL OR vehicle_type = ?)',
      whereArgs: [vehicleId, vehicleType],
      orderBy: 'id ASC',
    );
    return maps.map(_checklistFromMap).toList();
  }

  Future<Checklist?> getChecklistById(int id) async {
    final db = await _db.database;
    final maps = await db.query('checklists', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _checklistFromMap(maps.first);
  }

  Future<List<ChecklistItem>> getItems(int checklistId) async {
    final db = await _db.database;
    final maps = await db.query(
      'checklist_items',
      where: 'checklist_id = ?',
      whereArgs: [checklistId],
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map(_itemFromMap).toList();
  }

  Future<List<InspectionRun>> getRunsForVehicle(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'inspection_runs',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map(_runFromMap).toList();
  }

  Future<InspectionRun?> getRunById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'inspection_runs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _runFromMap(maps.first);
  }

  Future<List<InspectionAnswer>> getAnswers(int runId) async {
    final db = await _db.database;
    final maps = await db.query(
      'inspection_answers',
      where: 'run_id = ?',
      whereArgs: [runId],
      orderBy: 'id ASC',
    );
    return maps.map(_answerFromMap).toList();
  }

  Future<int> saveRun(InspectionRun run, List<InspectionAnswer> answers) async {
    final db = await _db.database;
    return db.transaction((txn) async {
      final runId = await txn.insert('inspection_runs', {
        'vehicle_id': run.vehicleId,
        'checklist_id': run.checklistId,
        'date': formatDate(run.date),
        'odometer': run.odometer,
        'notes': run.notes,
        'created_at': formatDateTime(run.createdAt),
      });
      for (final answer in answers) {
        await txn.insert('inspection_answers', {
          'run_id': runId,
          'item_id': answer.itemId,
          'status': answer.status,
          'notes': answer.notes,
        });
      }
      return runId;
    });
  }

  Future<void> deleteRun(int id) async {
    final db = await _db.database;
    await db.delete('inspection_runs', where: 'id = ?', whereArgs: [id]);
  }

  Checklist _checklistFromMap(Map<String, dynamic> m) => Checklist(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int?,
    vehicleType: m['vehicle_type'] as String?,
    name: m['name'] as String,
    createdAt: parseDateTime(m['created_at'] as String),
  );

  ChecklistItem _itemFromMap(Map<String, dynamic> m) => ChecklistItem(
    id: m['id'] as int,
    checklistId: m['checklist_id'] as int,
    label: m['label'] as String,
    sortOrder: m['sort_order'] as int? ?? 0,
  );

  InspectionRun _runFromMap(Map<String, dynamic> m) => InspectionRun(
    id: m['id'] as int,
    vehicleId: m['vehicle_id'] as int,
    checklistId: m['checklist_id'] as int,
    date: parseDate(m['date'] as String),
    odometer: m['odometer'] as int?,
    notes: m['notes'] as String?,
    createdAt: parseDateTime(m['created_at'] as String),
  );

  InspectionAnswer _answerFromMap(Map<String, dynamic> m) => InspectionAnswer(
    id: m['id'] as int,
    runId: m['run_id'] as int,
    itemId: m['item_id'] as int,
    status: m['status'] as String? ?? 'ok',
    notes: m['notes'] as String?,
  );
}
