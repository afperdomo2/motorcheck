# Esquema de Base de Datos

## Ubicación del archivo y backend

| Plataforma | Backend | Ruta |
|-----------|---------|------|
| Android/iOS | `sqflite` (plugin nativo) | `getDatabasesPath()/motorcheck.db` |
| Linux | `sqflite_common_ffi` | `~/.local/share/com.example.motorcheck/motorcheck.db` |
| Windows/macOS | `sqflite_common_ffi` | `getApplicationSupportDirectory()/motorcheck.db` |

- `initDatabaseFactory()` (`lib/core/database/database_factory.dart`) se llama
  desde `main()` y activa la implementación FFI solo en escritorio.
- En escritorio `DatabaseHelper` resuelve el directorio con
  `getApplicationSupportDirectory()`; si el plugin no está disponible (tests)
  cae a `getDatabasesPath()`.
- Los tests usan `sqfliteFfiInit()` + `databaseFactory = databaseFactoryFfi`
  sobre una base temporal.

## Tablas

### vehicles

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| name | TEXT | NOT NULL |
| type | TEXT | NOT NULL (car, motorcycle, bike, truck, other) |
| brand | TEXT | |
| model | TEXT | |
| year | INTEGER | |
| plate | TEXT | |
| color | TEXT | |
| image_path | TEXT | |
| current_mileage | INTEGER | |
| mileage_updated_at | TEXT | |
| vin | TEXT | |
| soat_expires_at | TEXT | |
| rtm_expires_at | TEXT | |
| is_default | INTEGER | DEFAULT 0 (solo un vehículo = 1 a la vez) |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

### workshops

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| name | TEXT | NOT NULL |
| location | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |

### maintenances

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| vehicle_id | INTEGER | NOT NULL, FK → vehicles(id) ON DELETE CASCADE |
| date | TEXT | NOT NULL (fecha ISO 8601) |
| mileage | INTEGER | |
| maintenance_cost | REAL | DEFAULT 0 |
| total_parts_cost | REAL | DEFAULT 0 |
| workshop_id | INTEGER | FK → workshops(id) ON DELETE SET NULL |
| notes | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

### maintenance_items

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| maintenance_id | INTEGER | NOT NULL, FK → maintenances(id) ON DELETE CASCADE |
| category | TEXT | DEFAULT 'general' |
| parts_cost | REAL | DEFAULT 0 |
| notes | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |

### mileage_readings

Historial de lecturas de odómetro. Alimenta el promedio km/día y la fecha
estimada del próximo mantenimiento.

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| vehicle_id | INTEGER | NOT NULL, FK → vehicles(id) ON DELETE CASCADE |
| date | TEXT | NOT NULL (fecha ISO 8601) |
| mileage | INTEGER | NOT NULL |
| source | TEXT | NOT NULL DEFAULT 'manual' (manual, maintenance, backfill) |
| created_at | TEXT | NOT NULL (ISO 8601) |

Índice único `(vehicle_id, date, mileage)` e índice por `(vehicle_id, date DESC)`.

### documents

Fuente de verdad de SOAT, RTM, impuesto, seguro y licencia. `vehicle_id` es
nullable para documentos del conductor.

El **vigente** de cada tipo es el de mayor `expires_at`. Los documentos
anteriores quedan como historial, se muestran con la etiqueta “Histórico” y no
generan recordatorios. Al borrar un SOAT/RTM se limpia la columna legado
correspondiente para que no se reconstruya.

Los backfills de documentos y kilometraje se ejecutan solo en las migraciones
(v13/v14); `_ensureSchemaIntegrity` no los repite en cada apertura.

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| vehicle_id | INTEGER | FK → vehicles(id) ON DELETE CASCADE |
| type | TEXT | NOT NULL (soat, rtm, tax, insurance, license, other) |
| name | TEXT | |
| number | TEXT | |
| issued_at | TEXT | |
| expires_at | TEXT | NOT NULL (fecha ISO 8601) |
| file_path | TEXT | Ruta local del adjunto |
| notes | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

El formulario de vehículo sincroniza SOAT y RTM con esta tabla mediante
`DocumentsNotifier.syncVehicleDates`: inserta, actualiza o elimina el documento
correspondiente. La UI de vehículos no lee las columnas legacy.

### vehicle_restrictions

Regla semanal de pico y placa por vehículo.

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| vehicle_id | INTEGER | NOT NULL UNIQUE, FK → vehicles(id) ON DELETE CASCADE |
| enabled | INTEGER | NOT NULL DEFAULT 0 |
| city | TEXT | |
| days | TEXT | JSON con días ISO (`[1,3,5]`) |
| start_time | TEXT | DEFAULT '06:00' |
| end_time | TEXT | DEFAULT '21:00' |
| exempt | INTEGER | NOT NULL DEFAULT 0 |
| notes | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

### expense_categories

Categorías configurables para gastos distintos al mantenimiento.

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| key | TEXT | NOT NULL UNIQUE |
| name | TEXT | NOT NULL |
| icon_name | TEXT | NOT NULL DEFAULT 'receipt_long' |
| sort_order | INTEGER | DEFAULT 0 |
| created_at | TEXT | NOT NULL (ISO 8601) |

### fuel_logs

Registro de tanqueadas y base del consumo real.

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| vehicle_id | INTEGER | NOT NULL, FK → vehicles(id) ON DELETE CASCADE |
| date | TEXT | NOT NULL (fecha ISO 8601) |
| odometer | INTEGER | NOT NULL |
| quantity | REAL | NOT NULL |
| unit_price | REAL | NOT NULL DEFAULT 0 |
| total_cost | REAL | NOT NULL DEFAULT 0 |
| fuel_type | TEXT | NOT NULL DEFAULT 'gasoline' |
| station | TEXT | |
| full_tank | INTEGER | NOT NULL DEFAULT 1 |
| notes | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

### expenses

Gastos del vehículo o globales (`vehicle_id` nullable).

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| vehicle_id | INTEGER | FK → vehicles(id) ON DELETE CASCADE |
| category_key | TEXT | NOT NULL |
| date | TEXT | NOT NULL (fecha ISO 8601) |
| amount | REAL | NOT NULL DEFAULT 0 |
| notes | TEXT | |
| receipt_path | TEXT | Ruta local del recibo |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

## Regla de kilometraje

`vehicles.current_mileage` es la fuente de verdad y **solo sube
automáticamente**:

- Registrar o editar un mantenimiento con un km mayor actualiza el vehículo.
- Un mantenimiento con un km menor se permite (puede ser histórico) pero no
  baja el vehículo.
- Eliminar un mantenimiento no baja el kilometraje.
- `mileage_updated_at` y `updated_at` del vehículo se actualizan solo cuando el
  km sube.
- La corrección manual se hace desde Editar vehículo.

## DDL

```sql
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
);

CREATE TABLE workshops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  location TEXT,
  created_at TEXT NOT NULL
);

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
);

CREATE TABLE maintenance_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maintenance_id INTEGER NOT NULL,
  category TEXT DEFAULT 'general',
  parts_cost REAL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (maintenance_id) REFERENCES maintenances(id) ON DELETE CASCADE
);

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
);

CREATE TABLE mileage_readings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  mileage INTEGER NOT NULL,
  source TEXT NOT NULL DEFAULT 'manual',
  created_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_mileage_unique
  ON mileage_readings(vehicle_id, date, mileage);
CREATE INDEX idx_mileage_vehicle_date
  ON mileage_readings(vehicle_id, date DESC);

CREATE TABLE documents (
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
);

CREATE TABLE vehicle_restrictions (
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
);

CREATE TABLE expense_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  icon_name TEXT NOT NULL DEFAULT 'receipt_long',
  sort_order INTEGER DEFAULT 0,
  created_at TEXT NOT NULL
);

CREATE TABLE fuel_logs (
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
);

CREATE INDEX idx_fuel_vehicle_date
  ON fuel_logs(vehicle_id, date DESC, odometer DESC);

CREATE TABLE expenses (
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
);

CREATE INDEX idx_expenses_vehicle_date
  ON expenses(vehicle_id, date DESC);
CREATE INDEX idx_expenses_category
  ON expenses(category_key);
```

## Relaciones

```
workshops (1) ────< (N) maintenances (1) ────< (N) maintenance_items
                    │
vehicles (1) ──────┼──< (N) mileage_readings
                    ├──< (N) documents
                    ├──< (N) fuel_logs
                    ├──< (N) expenses
                    └──(1) vehicle_restrictions

expense_categories (1) ────< (N) expenses
```

- Eliminar un vehículo → cascada a mantenimientos, items, lecturas de km,
  documentos y regla de pico y placa
- Eliminar un mantenimiento → cascada a todos sus items
- Eliminar un taller → el `workshop_id` del mantenimiento se pone en NULL
- Los costos en `maintenances` están desnormalizados para fácil visualización (suma de costos de items)
- `documents.vehicle_id` es nullable: los documentos del conductor (licencia)
  no pertenecen a un vehículo
- `expenses.vehicle_id` es nullable: los gastos globales no se suman al costo
  por km de un vehículo, pero aparecen en la lista de gastos
- Eliminar un vehículo → cascada a `fuel_logs`, `expenses`, `mileage_readings`,
  documentos y regla de pico y placa

## Tipos de Vehículo

| Valor | Etiqueta |
|-------|----------|
| car | Carro |
| motorcycle | Moto |
| bike | Bicicleta |
| truck | Camión |
| other | Otro |

## Categorías de Items de Mantenimiento

Las categorías son parametrizables por el usuario desde Configuración → Categorías.
Se almacenan en la tabla `maintenance_categories`. El campo `maintenance_items.category`
almacena la `key` de la tabla como FK lógico (ej: `car_engine`, `motorcycle_oil`).

### maintenance_categories

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| key | TEXT | NOT NULL UNIQUE |
| name | TEXT | NOT NULL (nombre visible, ej: "Motor", "Aceite") |
| icon_name | TEXT | NOT NULL DEFAULT 'build' (nombre de Material Icon) |
| vehicle_type | TEXT | NOT NULL (car / motorcycle / bike / truck / other) |
| sort_order | INTEGER | DEFAULT 0 |
| interval_km | INTEGER | NULL (km recomendados entre mantenimientos) |
| warning_km | INTEGER | NULL (avisar cuando falten X km) |
| interval_months | INTEGER | NULL (meses recomendados entre mantenimientos) |
| warning_days | INTEGER | NULL (avisar cuando falten X días) |
| created_at | TEXT | NOT NULL (ISO 8601) |

### Seed Inicial (38 categorías por defecto)

| Tipo Vehículo | Keys |
|--------------|------|
| car | car_engine, car_oil, car_brakes, car_transmission, car_suspension, car_tires, car_filters, car_battery, car_ac, car_electrical, car_general |
| motorcycle | motorcycle_engine, motorcycle_oil, motorcycle_chain, motorcycle_brakes, motorcycle_tires, motorcycle_filters, motorcycle_battery, motorcycle_suspension, motorcycle_general |
| bike | bike_brakes, bike_tires, bike_chain, bike_transmission, bike_suspension, bike_general |
| truck | truck_engine, truck_oil, truck_brakes, truck_transmission, truck_suspension, truck_tires, truck_filters, truck_battery, truck_ac, truck_electrical, truck_general |
| other | other_general |

El borrado es hard-delete, pero el repositorio verifica que la categoría no esté en uso en `maintenance_items` antes de eliminar.

## Versión de Base de Datos

Versión actual: **16**. Migraciones incrementales vía `onUpgrade` en `DatabaseHelper`:
- v2: agregó `current_mileage`
- v3: agregó `workshops` + `maintenance_cost` + `workshop_id` en maintenances
- v4: reestructuró `maintenance_items` (renombró columnas)
- v5: agregó `location` a workshops
- v6: agregó `mileage_updated_at`
- v7: agregó `vin`, `soat_expires_at`, `rtm_expires_at`
- v8: agregó `maintenance_categories` + seed + remapeo de keys antiguas (`engine` → `car_engine`, etc.)
- v9: agregó `last_selected_at` a vehicles
- v10: agregó `interval_km` y `warning_km` a maintenance_categories
- v11: refuerzo de columnas `interval_km` / `warning_km` con verificación PRAGMA
- v12: refuerzo de columna `last_selected_at` en vehicles con verificación PRAGMA
- v13: agregó `interval_months` y `warning_days` + tabla `mileage_readings` + backfill
- v14: agregó tabla `documents` + backfill de SOAT/RTM desde `vehicles`
- v15: agregó tabla `vehicle_restrictions`
- v16: agregó `fuel_logs`, `expense_categories` y `expenses` + seed de categorías

## Respaldo

`BackupService` genera un ZIP con `data.json` (todas las tablas y preferencias),
`manifest.json` y `attachments/` con los archivos adjuntos de documentos y
gastos. Restaurar reemplaza todos los datos y crea una copia de seguridad previa.
La exportación CSV genera un ZIP con un archivo por tabla.

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
