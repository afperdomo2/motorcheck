import '../../core/database/database_helper.dart';
import '../../core/utils/formatters.dart';
import 'models/component_service.dart';
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
    await db.delete('components', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ComponentService>> getServices(int componentId) async {
    final db = await _db.database;
    final maps = await db.query(
      'component_services',
      where: 'component_id = ?',
      whereArgs: [componentId],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map(_serviceFromMap).toList();
  }

  Future<int> insertService(ComponentService service) async {
    final db = await _db.database;
    return db.insert('component_services', _serviceToMap(service));
  }

  Future<void> deleteService(int id) async {
    final db = await _db.database;
    await db.delete('component_services', where: 'id = ?', whereArgs: [id]);
  }

  /// Guarda un servicio y, si `resetInterval` es `true`, reinicia el ciclo del
  /// componente con la fecha y el odómetro del servicio.
  Future<void> registerService(ComponentService service) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('component_services', _serviceToMap(service));
      if (!service.resetInterval) return;

      final maps = await txn.query(
        'components',
        where: 'id = ?',
        whereArgs: [service.componentId],
      );
      if (maps.isEmpty) return;
      final component = _fromMap(maps.first);
      await txn.update(
        'components',
        {
          'installed_at': formatDate(service.date),
          'installed_km': service.odometer ?? component.installedKm,
          'updated_at': formatDateTime(DateTime.now()),
        },
        where: 'id = ?',
        whereArgs: [service.componentId],
      );
    });
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
      'position': component.position,
      'installed_at': formatDate(component.installedAt),
      'installed_km': component.installedKm,
      'interval_km': component.intervalKm,
      'interval_months': component.intervalMonths,
      'warning_km': component.warningKm,
      'warning_days': component.warningDays,
      'notes': component.notes,
      'active': component.active ? 1 : 0,
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
      position: map['position'] as String?,
      installedAt: parseDate(map['installed_at'] as String),
      installedKm: map['installed_km'] as int?,
      intervalKm: map['interval_km'] as int?,
      intervalMonths: map['interval_months'] as int?,
      warningKm: map['warning_km'] as int?,
      warningDays: map['warning_days'] as int?,
      notes: map['notes'] as String?,
      active: (map['active'] as int? ?? 1) == 1,
      createdAt: parseDateTime(map['created_at'] as String),
      updatedAt: parseDateTime(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> _serviceToMap(ComponentService service) {
    return {
      if (service.id != null) 'id': service.id,
      'component_id': service.componentId,
      'date': formatDate(service.date),
      'odometer': service.odometer,
      'cost': service.cost,
      'notes': service.notes,
      'reset_interval': service.resetInterval ? 1 : 0,
      'created_at': formatDateTime(service.createdAt),
    };
  }

  ComponentService _serviceFromMap(Map<String, dynamic> map) {
    return ComponentService(
      id: map['id'] as int?,
      componentId: map['component_id'] as int,
      date: parseDate(map['date'] as String),
      odometer: map['odometer'] as int?,
      cost: (map['cost'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String?,
      resetInterval: (map['reset_interval'] as int? ?? 0) == 1,
      createdAt: parseDateTime(map['created_at'] as String),
    );
  }
}
