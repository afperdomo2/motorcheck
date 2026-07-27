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

Las categorías varían por tipo de vehículo. Definidas en `lib/features/maintenance/categories.dart`:

| Tipo | Cantidad | Categorías |
|------|----------|------------|
| car | 11 | motor, aceite, frenos, transmisión, suspensión, llantas, filtros, batería, A/C, eléctrico, general |
| truck | 11 | (mismas que car) |
| motorcycle | 9 | motor, aceite, cadena, frenos, llantas, filtros, batería, suspensión, general |
| bike | 6 | frenos, llantas, cadena, transmisión, suspensión, general |
| other | 1 | general |

## Versión de Base de Datos

Versión actual: **7**. Migraciones incrementales vía `onUpgrade` en `DatabaseHelper`:
- v2: agregó `current_mileage`
- v3: agregó `workshops` + `maintenance_cost` + `workshop_id` en maintenances
- v4: reestructuró `maintenance_items` (renombró columnas)
- v5: agregó `location` a workshops
- v6: agregó `mileage_updated_at`
- v7: agregó `vin`, `soat_expires_at`, `rtm_expires_at`

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
