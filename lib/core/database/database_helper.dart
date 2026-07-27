import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';

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
      version: 7,
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
    await batch.commit(noResult: true);
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
      await db.execute(
        'ALTER TABLE vehicles ADD COLUMN soat_expires_at TEXT',
      );
      await db.execute(
        'ALTER TABLE vehicles ADD COLUMN rtm_expires_at TEXT',
      );
    }
  }
}
