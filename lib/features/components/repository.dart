import '../../core/database/component_defaults.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/component_replacement.dart';
import 'models/vehicle_component.dart';

class ComponentsRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<VehicleComponent>> getByVehicleId(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.query(
      'components',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'active DESC, name ASC',
    );
    return maps.map(_fromMap).toList();
  }

  Future<VehicleComponent?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('components', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<int> insert(VehicleComponent component) async {
    final db = await _db.database;
    return db.insert('components', _toMap(component));
  }

  Future<void> update(VehicleComponent component) async {
    final db = await _db.database;
    await db.update(
      'components',
      _toMap(component, includeId: false),
      where: 'id = ?',
      whereArgs: [component.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'components',
      columns: ['is_system'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return;
    if ((maps.first['is_system'] as int? ?? 0) == 1) {
      throw StateError(
        'Este componente es parte de la plantilla del vehículo y no se '
        'puede eliminar. Puedes desactivarlo.',
      );
    }
    await db.delete('components', where: 'id = ?', whereArgs: [id]);
  }

  /// Convierte la plantilla actual en componentes normales (borrables).
  /// Se usa cuando el vehículo cambia de tipo y la plantilla anterior deja de
  /// aplicar.
  Future<void> releaseSystemComponents(int vehicleId) async {
    final db = await _db.database;
    await db.update(
      'components',
      {'is_system': 0},
      where: 'vehicle_id = ? AND is_system = 1',
      whereArgs: [vehicleId],
    );
  }

  /// Inserta los componentes de plantilla que falten para el vehículo.
  /// Devuelve cuántos se crearon.
  Future<int> seedDefaults({
    required int vehicleId,
    required String vehicleType,
    required DateTime installedAt,
    int? installedKm,
  }) async {
    final templates = componentTemplatesFor(vehicleType);
    if (templates.isEmpty) return 0;

    final db = await _db.database;
    final now = formatDateTime(DateTime.now());
    var created = 0;
    for (final template in templates) {
      final existing = await db.query(
        'components',
        columns: ['id'],
        where: 'vehicle_id = ? AND name = ?',
        whereArgs: [vehicleId, template.name],
        limit: 1,
      );
      if (existing.isNotEmpty) continue;
      await db.insert('components', {
        'vehicle_id': vehicleId,
        'name': template.name,
        'type': template.type,
        'category_key': template.categoryKey,
        'position': template.position,
        'installed_at': formatDate(installedAt),
        'installed_km': installedKm,
        'interval_km': template.intervalKm,
        'interval_months': template.intervalMonths,
        'warning_km': template.warningKm,
        'warning_days': template.warningDays,
        'active': template.active ? 1 : 0,
        'is_system': 1,
        'created_at': now,
        'updated_at': now,
      });
      created++;
    }
    return created;
  }

  /// Reemplazos de todos los componentes de un vehículo, del más reciente al
  /// más antiguo.
  Future<List<ComponentReplacement>> getReplacements(int vehicleId) async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      'SELECT i.component_id, i.maintenance_id, m.date, m.mileage, '
      'i.parts_cost, i.notes '
      'FROM maintenance_items i '
      'JOIN maintenances m ON m.id = i.maintenance_id '
      'WHERE m.vehicle_id = ? AND i.component_id IS NOT NULL '
      'ORDER BY m.date DESC, m.id DESC',
      [vehicleId],
    );
    return maps.map(_replacementFromMap).toList();
  }

  Future<List<ComponentReplacement>> getReplacementsForComponent(
    int componentId,
  ) async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      'SELECT i.component_id, i.maintenance_id, m.date, m.mileage, '
      'i.parts_cost, i.notes '
      'FROM maintenance_items i '
      'JOIN maintenances m ON m.id = i.maintenance_id '
      'WHERE i.component_id = ? '
      'ORDER BY m.date DESC, m.id DESC',
      [componentId],
    );
    return maps.map(_replacementFromMap).toList();
  }

  Future<ComponentReplacement?> getLatestReplacement(int componentId) async {
    final replacements = await getReplacementsForComponent(componentId);
    return replacements.isEmpty ? null : replacements.first;
  }

  Map<String, dynamic> _toMap(
    VehicleComponent component, {
    bool includeId = true,
  }) {
    return {
      if (includeId && component.id != null) 'id': component.id,
      'vehicle_id': component.vehicleId,
      'name': component.name,
      'type': component.type,
      'category_key': component.categoryKey,
      'position': component.position,
      'installed_at': formatDate(component.installedAt),
      'installed_km': component.installedKm,
      'interval_km': component.intervalKm,
      'interval_months': component.intervalMonths,
      'warning_km': component.warningKm,
      'warning_days': component.warningDays,
      'notes': component.notes,
      'active': component.active ? 1 : 0,
      'is_system': component.isSystem ? 1 : 0,
      'created_at': formatDateTime(component.createdAt),
      'updated_at': formatDateTime(component.updatedAt),
    };
  }

  VehicleComponent _fromMap(Map<String, dynamic> map) {
    return VehicleComponent(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      name: map['name'] as String,
      type: (map['type'] as String?) ?? 'other',
      categoryKey: map['category_key'] as String?,
      position: map['position'] as String?,
      installedAt: parseDate(map['installed_at'] as String),
      installedKm: map['installed_km'] as int?,
      intervalKm: map['interval_km'] as int?,
      intervalMonths: map['interval_months'] as int?,
      warningKm: map['warning_km'] as int?,
      warningDays: map['warning_days'] as int?,
      notes: map['notes'] as String?,
      active: (map['active'] as int? ?? 1) == 1,
      isSystem: (map['is_system'] as int? ?? 0) == 1,
      createdAt: parseDateTime(map['created_at'] as String),
      updatedAt: parseDateTime(map['updated_at'] as String),
    );
  }

  ComponentReplacement _replacementFromMap(Map<String, dynamic> map) {
    return ComponentReplacement(
      componentId: map['component_id'] as int,
      maintenanceId: map['maintenance_id'] as int,
      date: parseDate(map['date'] as String),
      mileage: map['mileage'] as int?,
      partsCost: (map['parts_cost'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String?,
    );
  }
}
