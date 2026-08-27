# Esquema de Base de Datos

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
  created_at TEXT NOT NULL
);
```

## Relaciones

```
workshops (1) ────< (N) maintenances (1) ────< (N) maintenance_items
                    │
vehicles (1) ──────┘
```

- Eliminar un vehículo → cascada a todos sus mantenimientos y sus items
- Eliminar un mantenimiento → cascada a todos sus items
- Eliminar un taller → el `workshop_id` del mantenimiento se pone en NULL
- Los costos en `maintenances` están desnormalizados para fácil visualización (suma de costos de items)

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
| created_at | TEXT | NOT NULL (ISO 8601) |

### Seed Inicial (43 categorías por defecto)

| Tipo Vehículo | Keys |
|--------------|------|
| car | car_engine, car_oil, car_brakes, car_transmission, car_suspension, car_tires, car_filters, car_battery, car_ac, car_electrical, car_general |
| motorcycle | motorcycle_engine, motorcycle_oil, motorcycle_chain, motorcycle_brakes, motorcycle_tires, motorcycle_filters, motorcycle_battery, motorcycle_suspension, motorcycle_general |
| bike | bike_brakes, bike_tires, bike_chain, bike_transmission, bike_suspension, bike_general |
| truck | truck_engine, truck_oil, truck_brakes, truck_transmission, truck_suspension, truck_tires, truck_filters, truck_battery, truck_ac, truck_electrical, truck_general |
| other | other_general |

El borrado es hard-delete, pero el repositorio verifica que la categoría no esté en uso en `maintenance_items` antes de eliminar.

## Versión de Base de Datos

Versión actual: **12**. Migraciones incrementales vía `onUpgrade` en `DatabaseHelper`:
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

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
