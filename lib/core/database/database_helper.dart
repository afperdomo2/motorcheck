import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';
import '../utils/formatters.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static DatabaseHelper? _instance;
  static Database? _database;

  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'motorcheck.db');

    return openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute(Tables.createVehicles);
    batch.execute(Tables.createWorkshops);
    batch.execute(Tables.createMaintenances);
    batch.execute(Tables.createMaintenanceItems);
    batch.execute(Tables.createMaintenanceCategories);
    await batch.commit(noResult: true);
    await _seedDefaultCategories(db);
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
      await db.execute(Tables.createMaintenanceCategories);
      await _seedDefaultCategories(db);
      await _migrateCategoryKeys(db);
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
      await db.insert('maintenance_categories', {...row, 'created_at': now});
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
