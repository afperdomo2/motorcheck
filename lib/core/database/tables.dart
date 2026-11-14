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

  static const createExpenseCategories = '''
CREATE TABLE IF NOT EXISTS expense_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  icon_name TEXT NOT NULL DEFAULT 'receipt_long',
  sort_order INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
)
''';

  static const createFuelLogs = '''
CREATE TABLE IF NOT EXISTS fuel_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  odometer INTEGER NOT NULL,
  quantity REAL NOT NULL,
  unit_price REAL NOT NULL DEFAULT 0,
  total_cost REAL NOT NULL DEFAULT 0,
  fuel_type TEXT NOT NULL DEFAULT 'gasoline',
  station TEXT,
  full_tank INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';

  static const createFuelVehicleDateIndex = '''
CREATE INDEX IF NOT EXISTS idx_fuel_vehicle_date
  ON fuel_logs(vehicle_id, date DESC, odometer DESC)
''';

  static const createExpenses = '''
CREATE TABLE IF NOT EXISTS expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER,
  category_key TEXT NOT NULL,
  date TEXT NOT NULL,
  amount REAL NOT NULL DEFAULT 0,
  notes TEXT,
  receipt_path TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';

  static const createExpensesVehicleDateIndex = '''
CREATE INDEX IF NOT EXISTS idx_expenses_vehicle_date
  ON expenses(vehicle_id, date DESC)
''';

  static const createExpensesCategoryIndex = '''
CREATE INDEX IF NOT EXISTS idx_expenses_category
  ON expenses(category_key)
''';

  static const createMaintenanceAttachments = '''
CREATE TABLE IF NOT EXISTS maintenance_attachments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maintenance_id INTEGER NOT NULL,
  item_id INTEGER,
  name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (maintenance_id) REFERENCES maintenances(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES maintenance_items(id) ON DELETE CASCADE
)
''';

  static const createMaintenanceAttachmentsIndex = '''
CREATE INDEX IF NOT EXISTS idx_maintenance_attachments_maintenance
  ON maintenance_attachments(maintenance_id)
''';

  static const createChecklists = '''
CREATE TABLE IF NOT EXISTS checklists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER,
  vehicle_type TEXT,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';

  static const createChecklistItems = '''
CREATE TABLE IF NOT EXISTS checklist_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  checklist_id INTEGER NOT NULL,
  label TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0,
  FOREIGN KEY (checklist_id) REFERENCES checklists(id) ON DELETE CASCADE
)
''';

  static const createChecklistItemsIndex = '''
CREATE INDEX IF NOT EXISTS idx_checklist_items_checklist
  ON checklist_items(checklist_id)
''';

  static const createInspectionRuns = '''
CREATE TABLE IF NOT EXISTS inspection_runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  checklist_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  odometer INTEGER,
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
  FOREIGN KEY (checklist_id) REFERENCES checklists(id) ON DELETE CASCADE
)
''';

  static const createInspectionRunsIndex = '''
CREATE INDEX IF NOT EXISTS idx_inspection_runs_vehicle_date
  ON inspection_runs(vehicle_id, date DESC)
''';

  static const createInspectionAnswers = '''
CREATE TABLE IF NOT EXISTS inspection_answers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  run_id INTEGER NOT NULL,
  item_id INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'ok',
  notes TEXT,
  FOREIGN KEY (run_id) REFERENCES inspection_runs(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES checklist_items(id) ON DELETE CASCADE
)
''';

  static const createInspectionAnswersIndex = '''
CREATE INDEX IF NOT EXISTS idx_inspection_answers_run
  ON inspection_answers(run_id)
''';

  static const createBudgets = '''
CREATE TABLE IF NOT EXISTS budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER,
  period TEXT NOT NULL,
  amount REAL NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';

  static const createBudgetsUniqueIndex = '''
CREATE UNIQUE INDEX IF NOT EXISTS idx_budgets_vehicle_period
  ON budgets(vehicle_id, period)
''';

  static const createComponents = '''
CREATE TABLE IF NOT EXISTS components (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'other',
  position TEXT,
  installed_at TEXT NOT NULL,
  installed_km INTEGER,
  interval_km INTEGER,
  interval_months INTEGER,
  warning_km INTEGER,
  warning_days INTEGER,
  notes TEXT,
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
)
''';

  static const createComponentsVehicleIndex = '''
CREATE INDEX IF NOT EXISTS idx_components_vehicle
  ON components(vehicle_id, active)
''';

  static const createComponentServices = '''
CREATE TABLE IF NOT EXISTS component_services (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  component_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  odometer INTEGER,
  cost REAL DEFAULT 0,
  notes TEXT,
  reset_interval INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (component_id) REFERENCES components(id) ON DELETE CASCADE
)
''';

  static const createComponentServicesIndex = '''
CREATE INDEX IF NOT EXISTS idx_component_services_component
  ON component_services(component_id, date DESC)
''';
}
