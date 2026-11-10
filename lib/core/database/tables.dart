class Tables {
  Tables._();

  static const createVehicles = '''
CREATE TABLE vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  year INTEGER,
  plate TEXT,
  color TEXT,
  image_path TEXT,
  current_mileage INTEGER,
  mileage_updated_at TEXT,
  vin TEXT,
  soat_expires_at TEXT,
  rtm_expires_at TEXT,
  is_default INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''';

  static const createWorkshops = '''
CREATE TABLE workshops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  location TEXT,
  created_at TEXT NOT NULL
)
''';

  static const createMaintenances = '''
CREATE TABLE maintenances (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  mileage INTEGER,
  maintenance_cost REAL DEFAULT 0,
  total_parts_cost REAL DEFAULT 0,
  workshop_id INTEGER,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
  FOREIGN KEY (workshop_id) REFERENCES workshops(id) ON DELETE SET NULL
)
''';

  static const createMaintenanceItems = '''
CREATE TABLE maintenance_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maintenance_id INTEGER NOT NULL,
  category TEXT DEFAULT 'general',
  parts_cost REAL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (maintenance_id) REFERENCES maintenances(id) ON DELETE CASCADE
)
''';

  static const createMaintenanceCategories = '''
CREATE TABLE maintenance_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  icon_name TEXT NOT NULL DEFAULT 'build',
  vehicle_type TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  interval_km INTEGER,
  warning_km INTEGER,
  interval_months INTEGER,
  warning_days INTEGER,
  created_at TEXT NOT NULL
)
''';

  static const createMileageReadings = '''
CREATE TABLE IF NOT EXISTS mileage_readings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  mileage INTEGER NOT NULL,
  source TEXT NOT NULL DEFAULT 'manual',
  created_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';

  static const createMileageUniqueIndex = '''
CREATE UNIQUE INDEX IF NOT EXISTS idx_mileage_unique
  ON mileage_readings(vehicle_id, date, mileage)
''';

  static const createMileageVehicleDateIndex = '''
CREATE INDEX IF NOT EXISTS idx_mileage_vehicle_date
  ON mileage_readings(vehicle_id, date DESC)
''';

  static const createDocuments = '''
CREATE TABLE IF NOT EXISTS documents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER,
  type TEXT NOT NULL,
  name TEXT,
  number TEXT,
  issued_at TEXT,
  expires_at TEXT NOT NULL,
  file_path TEXT,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';

  static const createDocumentsVehicleIndex = '''
CREATE INDEX IF NOT EXISTS idx_documents_vehicle
  ON documents(vehicle_id)
''';

  static const createDocumentsExpiresIndex = '''
CREATE INDEX IF NOT EXISTS idx_documents_expires
  ON documents(expires_at)
''';

  static const createVehicleRestrictions = '''
CREATE TABLE IF NOT EXISTS vehicle_restrictions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL UNIQUE,
  enabled INTEGER NOT NULL DEFAULT 0,
  city TEXT,
  days TEXT NOT NULL DEFAULT '[]',
  start_time TEXT NOT NULL DEFAULT '06:00',
  end_time TEXT NOT NULL DEFAULT '21:00',
  exempt INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';
}
