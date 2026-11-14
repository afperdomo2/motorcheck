import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'database_factory.dart';
import 'tables.dart';
import '../utils/formatters.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static DatabaseHelper? _instance;
  static Database? _database;
  static String? _directoryOverride;

  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  /// Solo para pruebas: aísla la base de datos en un directorio temporal.
  static void useDirectoryForTesting(String? path) {
    _directoryOverride = path;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await _resolveDatabaseDirectory();
    final path = join(dbPath, 'motorcheck.db');

    return openDatabase(
      path,
      version: 20,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _ensureSchemaIntegrity,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Directorio donde vive `motorcheck.db`.
  ///
  /// En escritorio se usa el directorio de soporte de la app
  /// (`~/.local/share/com.example.motorcheck` en Linux). En móvil se usa el
  /// directorio estándar de `sqflite`.
  Future<String> _resolveDatabaseDirectory() async {
    if (_directoryOverride != null) return _directoryOverride!;
    if (isDesktopDatabasePlatform) {
      try {
        final dir = await getApplicationSupportDirectory();
        return dir.path;
      } catch (_) {
        // En tests no hay plugins registrados: se cae a la ruta de FFI.
      }
    }
    return getDatabasesPath();
  }

  Future<void> _ensureSchemaIntegrity(Database db) async {
    final vehicleColumns = await db.rawQuery("PRAGMA table_info('vehicles')");
    final hasLastSelected = vehicleColumns.any(
      (c) => c['name'] == 'last_selected_at',
    );
    if (!hasLastSelected) {
      await db.execute('ALTER TABLE vehicles ADD COLUMN last_selected_at TEXT');
    }

    final catColumns = await db.rawQuery(
      "PRAGMA table_info('maintenance_categories')",
    );
    final hasInterval = catColumns.any((c) => c['name'] == 'interval_km');
    if (!hasInterval) {
      await db.execute(
        'ALTER TABLE maintenance_categories ADD COLUMN interval_km INTEGER',
      );
    }
    final hasWarning = catColumns.any((c) => c['name'] == 'warning_km');
    if (!hasWarning) {
      await db.execute(
        'ALTER TABLE maintenance_categories ADD COLUMN warning_km INTEGER',
      );
    }
    if (!await _hasColumn(db, 'maintenance_categories', 'interval_months')) {
      await db.execute(
        'ALTER TABLE maintenance_categories ADD COLUMN interval_months INTEGER',
      );
    }
    if (!await _hasColumn(db, 'maintenance_categories', 'warning_days')) {
      await db.execute(
        'ALTER TABLE maintenance_categories ADD COLUMN warning_days INTEGER',
      );
    }

    await db.execute(Tables.createMileageReadings);
    await db.execute(Tables.createMileageUniqueIndex);
    await db.execute(Tables.createMileageVehicleDateIndex);
    await db.execute(Tables.createDocuments);
    await db.execute(Tables.createDocumentsVehicleIndex);
    await db.execute(Tables.createDocumentsExpiresIndex);
    await db.execute(Tables.createVehicleRestrictions);
    await db.execute(Tables.createExpenseCategories);
    await db.execute(Tables.createFuelLogs);
    await db.execute(Tables.createFuelVehicleDateIndex);
    await db.execute(Tables.createExpenses);
    await db.execute(Tables.createExpensesVehicleDateIndex);
    await db.execute(Tables.createExpensesCategoryIndex);
    await db.execute(Tables.createMaintenanceAttachments);
    await db.execute(Tables.createMaintenanceAttachmentsIndex);
    await db.execute(Tables.createChecklists);
    await db.execute(Tables.createChecklistItems);
    await db.execute(Tables.createChecklistItemsIndex);
    await db.execute(Tables.createInspectionRuns);
    await db.execute(Tables.createInspectionRunsIndex);
    await db.execute(Tables.createInspectionAnswers);
    await db.execute(Tables.createInspectionAnswersIndex);
    await db.execute(Tables.createBudgets);
    await db.execute(Tables.createBudgetsUniqueIndex);
    await db.execute(Tables.createComponents);
    await db.execute(Tables.createComponentsVehicleIndex);
    await db.execute(Tables.createComponentServices);
    await db.execute(Tables.createComponentServicesIndex);

    // Los backfills viven solo en `_onUpgrade` (v13/v14). Ejecutarlos en cada
    // apertura resucitaría documentos o lecturas que el usuario haya borrado.
  }

  Future<bool> _hasColumn(Database db, String table, String column) async {
    final columns = await db.rawQuery("PRAGMA table_info('$table')");
    return columns.any((c) => c['name'] == column);
  }

  Future<void> _backfillMileageReadings(Database db) async {
    await db.rawInsert(
      'INSERT OR IGNORE INTO mileage_readings '
      '(vehicle_id, date, mileage, source, created_at) '
      'SELECT id, substr(COALESCE(mileage_updated_at, updated_at, created_at), 1, 10), '
      'current_mileage, \'backfill\', created_at '
      'FROM vehicles WHERE current_mileage IS NOT NULL',
    );
    await db.rawInsert(
      'INSERT OR IGNORE INTO mileage_readings '
      '(vehicle_id, date, mileage, source, created_at) '
      'SELECT vehicle_id, date, mileage, \'maintenance\', created_at '
      'FROM maintenances WHERE mileage IS NOT NULL',
    );
  }

  Future<void> _backfillDocuments(Database db) async {
    await db.rawInsert(
      'INSERT INTO documents '
      '(vehicle_id, type, name, expires_at, created_at, updated_at) '
      'SELECT v.id, \'soat\', \'SOAT\', v.soat_expires_at, '
      'v.created_at, v.updated_at '
      'FROM vehicles v '
      'WHERE v.soat_expires_at IS NOT NULL '
      'AND NOT EXISTS (SELECT 1 FROM documents d '
      'WHERE d.vehicle_id = v.id AND d.type = \'soat\')',
    );
    await db.rawInsert(
      'INSERT INTO documents '
      '(vehicle_id, type, name, expires_at, created_at, updated_at) '
      'SELECT v.id, \'rtm\', \'Tecnomecánica\', v.rtm_expires_at, '
      'v.created_at, v.updated_at '
      'FROM vehicles v '
      'WHERE v.rtm_expires_at IS NOT NULL '
      'AND NOT EXISTS (SELECT 1 FROM documents d '
      'WHERE d.vehicle_id = v.id AND d.type = \'rtm\')',
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute(Tables.createVehicles);
    batch.execute(Tables.createWorkshops);
    batch.execute(Tables.createMaintenances);
    batch.execute(Tables.createMaintenanceItems);
    batch.execute(Tables.createMaintenanceCategories);
    batch.execute(Tables.createMileageReadings);
    batch.execute(Tables.createMileageUniqueIndex);
    batch.execute(Tables.createMileageVehicleDateIndex);
    batch.execute(Tables.createDocuments);
    batch.execute(Tables.createDocumentsVehicleIndex);
    batch.execute(Tables.createDocumentsExpiresIndex);
    batch.execute(Tables.createVehicleRestrictions);
    batch.execute(Tables.createExpenseCategories);
    batch.execute(Tables.createFuelLogs);
    batch.execute(Tables.createFuelVehicleDateIndex);
    batch.execute(Tables.createExpenses);
    batch.execute(Tables.createExpensesVehicleDateIndex);
    batch.execute(Tables.createExpensesCategoryIndex);
    batch.execute(Tables.createMaintenanceAttachments);
    batch.execute(Tables.createMaintenanceAttachmentsIndex);
    batch.execute(Tables.createChecklists);
    batch.execute(Tables.createChecklistItems);
    batch.execute(Tables.createChecklistItemsIndex);
    batch.execute(Tables.createInspectionRuns);
    batch.execute(Tables.createInspectionRunsIndex);
    batch.execute(Tables.createInspectionAnswers);
    batch.execute(Tables.createInspectionAnswersIndex);
    batch.execute(Tables.createBudgets);
    batch.execute(Tables.createBudgetsUniqueIndex);
    batch.execute(Tables.createComponents);
    batch.execute(Tables.createComponentsVehicleIndex);
    batch.execute(Tables.createComponentServices);
    batch.execute(Tables.createComponentServicesIndex);
    await batch.commit(noResult: true);
    await _seedDefaultCategories(db);
    await _seedExpenseCategories(db);
    await _seedDefaultChecklists(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE vehicles ADD COLUMN current_mileage INTEGER',
      );
    }
    if (oldVersion < 3) {
      await db.execute(Tables.createWorkshops);
      await db.execute(
        'ALTER TABLE maintenances ADD COLUMN maintenance_cost REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE maintenances ADD COLUMN workshop_id INTEGER REFERENCES workshops(id) ON DELETE SET NULL',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        'CREATE TABLE maintenance_items_new ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'maintenance_id INTEGER NOT NULL, '
        'category TEXT DEFAULT \'general\', '
        'parts_cost REAL DEFAULT 0, '
        'notes TEXT, '
        'created_at TEXT NOT NULL, '
        'FOREIGN KEY (maintenance_id) REFERENCES maintenances(id) ON DELETE CASCADE'
        ')',
      );
      await db.execute(
        'INSERT INTO maintenance_items_new '
        '(id, maintenance_id, category, parts_cost, notes, created_at) '
        'SELECT id, maintenance_id, COALESCE(category, \'general\'), '
        'COALESCE(parts_cost, 0), notes, created_at '
        'FROM maintenance_items',
      );
      await db.execute('DROP TABLE maintenance_items');
      await db.execute(
        'ALTER TABLE maintenance_items_new RENAME TO maintenance_items',
      );
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE workshops ADD COLUMN location TEXT');
    }
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE vehicles ADD COLUMN mileage_updated_at TEXT',
      );
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE vehicles ADD COLUMN vin TEXT');
      await db.execute('ALTER TABLE vehicles ADD COLUMN soat_expires_at TEXT');
      await db.execute('ALTER TABLE vehicles ADD COLUMN rtm_expires_at TEXT');
    }
    if (oldVersion < 8) {
      await db.execute(
        Tables.createMaintenanceCategories.replaceFirst(
          'CREATE TABLE',
          'CREATE TABLE IF NOT EXISTS',
        ),
      );
      await _seedDefaultCategories(db);
      await _migrateCategoryKeys(db);
    }
    if (oldVersion < 9) {
      await db.execute('ALTER TABLE vehicles ADD COLUMN last_selected_at TEXT');
    }
    if (oldVersion < 10) {
      await db.execute(
        'ALTER TABLE maintenance_categories ADD COLUMN interval_km INTEGER',
      );
      await db.execute(
        'ALTER TABLE maintenance_categories ADD COLUMN warning_km INTEGER',
      );
    }
    if (oldVersion < 11) {
      final columns = await db.rawQuery(
        "PRAGMA table_info('maintenance_categories')",
      );
      final hasInterval = columns.any((c) => c['name'] == 'interval_km');
      if (!hasInterval) {
        await db.execute(
          'ALTER TABLE maintenance_categories ADD COLUMN interval_km INTEGER',
        );
        await db.execute(
          'ALTER TABLE maintenance_categories ADD COLUMN warning_km INTEGER',
        );
      }
    }
    if (oldVersion < 12) {
      final vehicleColumns = await db.rawQuery("PRAGMA table_info('vehicles')");
      final hasLastSelected = vehicleColumns.any(
        (c) => c['name'] == 'last_selected_at',
      );
      if (!hasLastSelected) {
        await db.execute(
          'ALTER TABLE vehicles ADD COLUMN last_selected_at TEXT',
        );
      }
    }
    if (oldVersion < 13) {
      if (!await _hasColumn(db, 'maintenance_categories', 'interval_months')) {
        await db.execute(
          'ALTER TABLE maintenance_categories ADD COLUMN interval_months INTEGER',
        );
      }
      if (!await _hasColumn(db, 'maintenance_categories', 'warning_days')) {
        await db.execute(
          'ALTER TABLE maintenance_categories ADD COLUMN warning_days INTEGER',
        );
      }
      await db.execute(Tables.createMileageReadings);
      await db.execute(Tables.createMileageUniqueIndex);
      await db.execute(Tables.createMileageVehicleDateIndex);
      await _backfillMileageReadings(db);
    }
    if (oldVersion < 14) {
      await db.execute(Tables.createDocuments);
      await db.execute(Tables.createDocumentsVehicleIndex);
      await db.execute(Tables.createDocumentsExpiresIndex);
      await _backfillDocuments(db);
    }
    if (oldVersion < 15) {
      await db.execute(Tables.createVehicleRestrictions);
    }
    if (oldVersion < 16) {
      await db.execute(Tables.createExpenseCategories);
      await db.execute(Tables.createFuelLogs);
      await db.execute(Tables.createFuelVehicleDateIndex);
      await db.execute(Tables.createExpenses);
      await db.execute(Tables.createExpensesVehicleDateIndex);
      await db.execute(Tables.createExpensesCategoryIndex);
      await _seedExpenseCategories(db);
    }
    if (oldVersion < 17) {
      await db.execute(Tables.createMaintenanceAttachments);
      await db.execute(Tables.createMaintenanceAttachmentsIndex);
    }
    if (oldVersion < 18) {
      await db.execute(Tables.createChecklists);
      await db.execute(Tables.createChecklistItems);
      await db.execute(Tables.createChecklistItemsIndex);
      await db.execute(Tables.createInspectionRuns);
      await db.execute(Tables.createInspectionRunsIndex);
      await db.execute(Tables.createInspectionAnswers);
      await db.execute(Tables.createInspectionAnswersIndex);
      await _seedDefaultChecklists(db);
    }
    if (oldVersion < 19) {
      await db.execute(Tables.createBudgets);
      await db.execute(Tables.createBudgetsUniqueIndex);
    }
    if (oldVersion < 20) {
      await db.execute(Tables.createComponents);
      await db.execute(Tables.createComponentsVehicleIndex);
      await db.execute(Tables.createComponentServices);
      await db.execute(Tables.createComponentServicesIndex);
    }
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final now = formatDateTime(DateTime.now());
    const defaults = <Map<String, dynamic>>[
      {
        'key': 'car_engine',
        'name': 'Motor',
        'icon_name': 'construction',
        'vehicle_type': 'car',
        'sort_order': 1,
      },
      {
        'key': 'car_oil',
        'name': 'Aceite',
        'icon_name': 'oil_barrel',
        'vehicle_type': 'car',
        'sort_order': 2,
      },
      {
        'key': 'car_brakes',
        'name': 'Frenos',
        'icon_name': 'disc_full',
        'vehicle_type': 'car',
        'sort_order': 3,
      },
      {
        'key': 'car_transmission',
        'name': 'Transmisión',
        'icon_name': 'settings',
        'vehicle_type': 'car',
        'sort_order': 4,
      },
      {
        'key': 'car_suspension',
        'name': 'Suspensión',
        'icon_name': 'tire_repair',
        'vehicle_type': 'car',
        'sort_order': 5,
      },
      {
        'key': 'car_tires',
        'name': 'Llantas',
        'icon_name': 'circle',
        'vehicle_type': 'car',
        'sort_order': 6,
      },
      {
        'key': 'car_filters',
        'name': 'Filtros',
        'icon_name': 'filter_alt',
        'vehicle_type': 'car',
        'sort_order': 7,
      },
      {
        'key': 'car_battery',
        'name': 'Batería',
        'icon_name': 'battery_charging_full',
        'vehicle_type': 'car',
        'sort_order': 8,
      },
      {
        'key': 'car_ac',
        'name': 'Aire Acond.',
        'icon_name': 'ac_unit',
        'vehicle_type': 'car',
        'sort_order': 9,
      },
      {
        'key': 'car_electrical',
        'name': 'Eléctrico',
        'icon_name': 'electrical_services',
        'vehicle_type': 'car',
        'sort_order': 10,
      },
      {
        'key': 'car_general',
        'name': 'General',
        'icon_name': 'build',
        'vehicle_type': 'car',
        'sort_order': 11,
      },
      {
        'key': 'motorcycle_engine',
        'name': 'Motor',
        'icon_name': 'construction',
        'vehicle_type': 'motorcycle',
        'sort_order': 1,
      },
      {
        'key': 'motorcycle_oil',
        'name': 'Aceite',
        'icon_name': 'oil_barrel',
        'vehicle_type': 'motorcycle',
        'sort_order': 2,
      },
      {
        'key': 'motorcycle_chain',
        'name': 'Cadena',
        'icon_name': 'link',
        'vehicle_type': 'motorcycle',
        'sort_order': 3,
      },
      {
        'key': 'motorcycle_brakes',
        'name': 'Frenos',
        'icon_name': 'disc_full',
        'vehicle_type': 'motorcycle',
        'sort_order': 4,
      },
      {
        'key': 'motorcycle_tires',
        'name': 'Llantas',
        'icon_name': 'circle',
        'vehicle_type': 'motorcycle',
        'sort_order': 5,
      },
      {
        'key': 'motorcycle_filters',
        'name': 'Filtros',
        'icon_name': 'filter_alt',
        'vehicle_type': 'motorcycle',
        'sort_order': 6,
      },
      {
        'key': 'motorcycle_battery',
        'name': 'Batería',
        'icon_name': 'battery_charging_full',
        'vehicle_type': 'motorcycle',
        'sort_order': 7,
      },
      {
        'key': 'motorcycle_suspension',
        'name': 'Suspensión',
        'icon_name': 'tire_repair',
        'vehicle_type': 'motorcycle',
        'sort_order': 8,
      },
      {
        'key': 'motorcycle_general',
        'name': 'General',
        'icon_name': 'build',
        'vehicle_type': 'motorcycle',
        'sort_order': 9,
      },
      {
        'key': 'bike_brakes',
        'name': 'Frenos',
        'icon_name': 'disc_full',
        'vehicle_type': 'bike',
        'sort_order': 1,
      },
      {
        'key': 'bike_tires',
        'name': 'Llantas',
        'icon_name': 'circle',
        'vehicle_type': 'bike',
        'sort_order': 2,
      },
      {
        'key': 'bike_chain',
        'name': 'Cadena',
        'icon_name': 'link',
        'vehicle_type': 'bike',
        'sort_order': 3,
      },
      {
        'key': 'bike_transmission',
        'name': 'Transmisión',
        'icon_name': 'settings',
        'vehicle_type': 'bike',
        'sort_order': 4,
      },
      {
        'key': 'bike_suspension',
        'name': 'Suspensión',
        'icon_name': 'tire_repair',
        'vehicle_type': 'bike',
        'sort_order': 5,
      },
      {
        'key': 'bike_general',
        'name': 'General',
        'icon_name': 'build',
        'vehicle_type': 'bike',
        'sort_order': 6,
      },
      {
        'key': 'truck_engine',
        'name': 'Motor',
        'icon_name': 'construction',
        'vehicle_type': 'truck',
        'sort_order': 1,
      },
      {
        'key': 'truck_oil',
        'name': 'Aceite',
        'icon_name': 'oil_barrel',
        'vehicle_type': 'truck',
        'sort_order': 2,
      },
      {
        'key': 'truck_brakes',
        'name': 'Frenos',
        'icon_name': 'disc_full',
        'vehicle_type': 'truck',
        'sort_order': 3,
      },
      {
        'key': 'truck_transmission',
        'name': 'Transmisión',
        'icon_name': 'settings',
        'vehicle_type': 'truck',
        'sort_order': 4,
      },
      {
        'key': 'truck_suspension',
        'name': 'Suspensión',
        'icon_name': 'tire_repair',
        'vehicle_type': 'truck',
        'sort_order': 5,
      },
      {
        'key': 'truck_tires',
        'name': 'Llantas',
        'icon_name': 'circle',
        'vehicle_type': 'truck',
        'sort_order': 6,
      },
      {
        'key': 'truck_filters',
        'name': 'Filtros',
        'icon_name': 'filter_alt',
        'vehicle_type': 'truck',
        'sort_order': 7,
      },
      {
        'key': 'truck_battery',
        'name': 'Batería',
        'icon_name': 'battery_charging_full',
        'vehicle_type': 'truck',
        'sort_order': 8,
      },
      {
        'key': 'truck_ac',
        'name': 'Aire Acond.',
        'icon_name': 'ac_unit',
        'vehicle_type': 'truck',
        'sort_order': 9,
      },
      {
        'key': 'truck_electrical',
        'name': 'Eléctrico',
        'icon_name': 'electrical_services',
        'vehicle_type': 'truck',
        'sort_order': 10,
      },
      {
        'key': 'truck_general',
        'name': 'General',
        'icon_name': 'build',
        'vehicle_type': 'truck',
        'sort_order': 11,
      },
      {
        'key': 'other_general',
        'name': 'General',
        'icon_name': 'build',
        'vehicle_type': 'other',
        'sort_order': 1,
      },
    ];
    for (final row in defaults) {
      await db.insert('maintenance_categories', {
        ...row,
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedExpenseCategories(Database db) async {
    final now = formatDateTime(DateTime.now());
    const defaults = <Map<String, dynamic>>[
      {
        'key': 'insurance',
        'name': 'Seguro',
        'icon_name': 'security',
        'sort_order': 1,
      },
      {
        'key': 'tax',
        'name': 'Impuesto',
        'icon_name': 'account_balance',
        'sort_order': 2,
      },
      {'key': 'tolls', 'name': 'Peajes', 'icon_name': 'toll', 'sort_order': 3},
      {
        'key': 'parking',
        'name': 'Parqueadero',
        'icon_name': 'local_parking',
        'sort_order': 4,
      },
      {'key': 'fines', 'name': 'Multas', 'icon_name': 'gavel', 'sort_order': 5},
      {
        'key': 'wash',
        'name': 'Lavado',
        'icon_name': 'local_car_wash',
        'sort_order': 6,
      },
      {
        'key': 'accessories',
        'name': 'Accesorios',
        'icon_name': 'shopping_bag',
        'sort_order': 7,
      },
      {
        'key': 'other',
        'name': 'Otros',
        'icon_name': 'receipt_long',
        'sort_order': 8,
      },
    ];
    for (final row in defaults) {
      await db.insert('expense_categories', {
        ...row,
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _seedDefaultChecklists(Database db) async {
    final existing = await db.query(
      'checklists',
      where: 'name = ? AND vehicle_id IS NULL',
      whereArgs: ['Inspección pre-viaje'],
    );
    if (existing.isNotEmpty) return;

    final now = formatDateTime(DateTime.now());
    final checklistId = await db.insert('checklists', {
      'vehicle_id': null,
      'vehicle_type': null,
      'name': 'Inspección pre-viaje',
      'created_at': now,
    });

    const items = [
      'Luces delanteras y traseras',
      'Frenos',
      'Presión de llantas',
      'Cadena / transmisión',
      'Documentos',
      'Espejos y dirección',
      'Niveles y fugas',
      'Casco y seguridad',
    ];
    for (var i = 0; i < items.length; i++) {
      await db.insert('checklist_items', {
        'checklist_id': checklistId,
        'label': items[i],
        'sort_order': i + 1,
      });
    }
  }

  Future<void> _migrateCategoryKeys(Database db) async {
    final oldKeys = {
      'engine': 'car_engine',
      'oil': 'car_oil',
      'brakes': 'car_brakes',
      'transmission': 'car_transmission',
      'suspension': 'car_suspension',
      'tires': 'car_tires',
      'filters': 'car_filters',
      'battery': 'car_battery',
      'ac': 'car_ac',
      'electrical': 'car_electrical',
      'general': 'car_general',
    };

    final items = await db.query('maintenance_items');
    for (final item in items) {
      final oldCat = item['category'] as String? ?? 'general';
      final newKey = oldKeys[oldCat] ?? 'car_general';
      if (newKey != oldCat) {
        await db.update(
          'maintenance_items',
          {'category': newKey},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }
  }
}
