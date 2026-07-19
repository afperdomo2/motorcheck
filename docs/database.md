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
| is_default | INTEGER | DEFAULT 0 (solo un vehículo = 1 a la vez) |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

### maintenances

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| vehicle_id | INTEGER | NOT NULL, FK → vehicles(id) ON DELETE CASCADE |
| title | TEXT | NOT NULL |
| date | TEXT | NOT NULL (fecha ISO 8601) |
| mileage | INTEGER | |
| total_labor_cost | REAL | DEFAULT 0 |
| total_parts_cost | REAL | DEFAULT 0 |
| notes | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |
| updated_at | TEXT | NOT NULL (ISO 8601) |

### maintenance_items

| Columna | Tipo | Restricciones |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| maintenance_id | INTEGER | NOT NULL, FK → maintenances(id) ON DELETE CASCADE |
| name | TEXT | NOT NULL |
| category | TEXT | (oil, tires, filters, brakes, suspension, general, other) |
| labor_cost | REAL | DEFAULT 0 |
| parts_cost | REAL | DEFAULT 0 |
| notes | TEXT | |
| created_at | TEXT | NOT NULL (ISO 8601) |

## DDL

```sql
CREATE TABLE vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('car', 'motorcycle', 'bike', 'truck', 'other')),
  brand TEXT,
  model TEXT,
  year INTEGER,
  plate TEXT,
  color TEXT,
  image_path TEXT,
  is_default INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE maintenances (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  date TEXT NOT NULL,
  mileage INTEGER,
  total_labor_cost REAL DEFAULT 0,
  total_parts_cost REAL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

CREATE TABLE maintenance_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maintenance_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  category TEXT,
  labor_cost REAL DEFAULT 0,
  parts_cost REAL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (maintenance_id) REFERENCES maintenances(id) ON DELETE CASCADE
);
```

## Relaciones

```
vehicles (1) ────< (N) maintenances (1) ────< (N) maintenance_items
```

- Eliminar un vehículo → cascada a todos sus mantenimientos y sus items
- Eliminar un mantenimiento → cascada a todos sus items
- Los totales en `maintenances` están desnormalizados para fácil visualización (suma de costos de items)

## Tipos de Vehículo

| Valor | Etiqueta |
|-------|----------|
| car | Carro |
| motorcycle | Moto |
| bike | Bicicleta |
| truck | Camión |
| other | Otro |

## Categorías de Items de Mantenimiento

| Valor | Etiqueta |
|-------|----------|
| oil | Cambio de aceite |
| tires | Llantas |
| filters | Filtros |
| brakes | Frenos |
| suspension | Suspensión |
| general | Mantenimiento general |
| other | Otro |
