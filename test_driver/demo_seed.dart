/// Datos de demostración para las capturas de pantalla del README.
///
/// Solo se usa desde `test_driver/app.dart`, sobre una base temporal.
/// Nunca toca la base de datos real del usuario.
library;

import 'package:sqflite/sqflite.dart';

import 'package:motorcheck/core/database/component_defaults.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/core/utils/formatters.dart';

/// Siembra dos vehículos ficticios con historial completo: mantenimientos,
/// kilometraje, tanqueadas, gastos, presupuesto, documentos, componentes
/// y pico y placa. Las fechas son relativas a hoy para que las capturas
/// se vean siempre actuales.
Future<void> seedDemoData() async {
  final db = await DatabaseHelper.instance.database;
  final now = DateTime.now();
  final ts = formatDateTime(now);

  String ago(int days) => formatDate(now.subtract(Duration(days: days)));
  String ahead(int days) => formatDate(now.add(Duration(days: days)));
  String stampAgo(int days) =>
      formatDateTime(now.subtract(Duration(days: days)));
  String stampAhead(int days) => formatDateTime(now.add(Duration(days: days)));

  // --- Vehículos ---------------------------------------------------
  final corolla = await db.insert('vehicles', {
    'name': 'Toyota Corolla',
    'type': 'car',
    'brand': 'Toyota',
    'model': 'Corolla',
    'year': 2020,
    'plate': 'ABC-123',
    'color': 'Gris plata',
    'current_mileage': 45200,
    'mileage_updated_at': ts,
    'vin': '9BRK34EE0L2123456',
    'soat_expires_at': stampAhead(120),
    'rtm_expires_at': stampAhead(64),
    'is_default': 1,
    'last_selected_at': ts,
    'created_at': stampAgo(500),
    'updated_at': ts,
  });
  final moto = await db.insert('vehicles', {
    'name': 'Yamaha MT-03',
    'type': 'motorcycle',
    'brand': 'Yamaha',
    'model': 'MT-03',
    'year': 2022,
    'plate': 'XYZ-789',
    'color': 'Azul',
    'current_mileage': 12800,
    'mileage_updated_at': ts,
    'soat_expires_at': stampAhead(200),
    'is_default': 0,
    'created_at': stampAgo(300),
    'updated_at': ts,
  });

  // --- Talleres ----------------------------------------------------
  final taller1 = await db.insert('workshops', {
    'name': 'Taller El Pistón',
    'location': 'Bogotá',
    'created_at': ts,
  });
  final taller2 = await db.insert('workshops', {
    'name': 'Llantas del Norte',
    'location': 'Chapinero',
    'created_at': ts,
  });

  // --- Componentes (plantillas del sistema) ------------------------
  await _insertComponents(db, corolla, 'car', now, installedKm: 20500);
  await _insertComponents(db, moto, 'motorcycle', now, installedKm: 9000);

  // Estados de desgaste variados para la captura de componentes:
  // llanta trasera derecha vencida, trasera izquierda en aviso y
  // batería próxima a reemplazo.
  await db.update(
    'components',
    {'installed_km': 800, 'interval_km': 44000, 'updated_at': ts},
    where: 'vehicle_id = ? AND position_code = ?',
    whereArgs: [corolla, 'rear_right'],
  );
  await db.update(
    'components',
    {'installed_km': 1800, 'interval_km': 46000, 'updated_at': ts},
    where: 'vehicle_id = ? AND position_code = ?',
    whereArgs: [corolla, 'rear_left'],
  );
  await db.update(
    'components',
    {'installed_at': ago(1065), 'updated_at': ts},
    where: 'vehicle_id = ? AND type = ?',
    whereArgs: [corolla, 'battery'],
  );

  Future<int> componentId(int vehicleId, String positionCode) async {
    final rows = await db.query(
      'components',
      columns: ['id'],
      where: 'vehicle_id = ? AND position_code = ?',
      whereArgs: [vehicleId, positionCode],
      limit: 1,
    );
    return rows.first['id'] as int;
  }

  final tireFrontLeft = await componentId(corolla, 'front_left');
  final brakesFront = await componentId(corolla, 'front');

  // --- Mantenimientos ---------------------------------------------
  Future<void> maintenance({
    required int vehicleId,
    required int daysAgo,
    required int mileage,
    required double labor,
    required double parts,
    int? workshopId,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final id = await db.insert('maintenances', {
      'vehicle_id': vehicleId,
      'date': ago(daysAgo),
      'mileage': mileage,
      'maintenance_cost': labor,
      'total_parts_cost': parts,
      'workshop_id': workshopId,
      'notes': notes,
      'created_at': stampAgo(daysAgo),
      'updated_at': stampAgo(daysAgo),
    });
    for (final item in items) {
      await db.insert('maintenance_items', {
        'maintenance_id': id,
        'category': item['category'],
        'parts_cost': item['parts_cost'],
        'notes': item['notes'],
        'component_id': item['component_id'],
        'created_at': stampAgo(daysAgo),
      });
    }
  }

  await maintenance(
    vehicleId: corolla,
    daysAgo: 15,
    mileage: 44100,
    labor: 90000,
    parts: 260000,
    workshopId: taller2,
    notes: 'Rotación y alineación de llantas. Ajuste de presión.',
    items: [
      {
        'category': 'car_tires',
        'parts_cost': 260000.0,
        'notes': 'Rotación + alineación',
        'component_id': tireFrontLeft,
      },
    ],
  );
  await maintenance(
    vehicleId: corolla,
    daysAgo: 66,
    mileage: 42000,
    labor: 180000,
    parts: 320000,
    workshopId: taller1,
    notes: 'Cambio de aceite 5W-30 y filtros. Revisión general.',
    items: [
      {
        'category': 'car_oil',
        'parts_cost': 210000.0,
        'notes': 'Aceite sintético 5W-30 + filtro de aceite',
        'component_id': null,
      },
      {
        'category': 'car_filters',
        'parts_cost': 110000.0,
        'notes': 'Filtros de aire y cabina',
        'component_id': null,
      },
    ],
  );
  await maintenance(
    vehicleId: corolla,
    daysAgo: 150,
    mileage: 39500,
    labor: 120000,
    parts: 380000,
    workshopId: taller1,
    notes: 'Cambio de pastillas de freno delanteras.',
    items: [
      {
        'category': 'car_brakes',
        'parts_cost': 380000.0,
        'notes': 'Pastillas delanteras cerámicas',
        'component_id': brakesFront,
      },
    ],
  );
  await maintenance(
    vehicleId: moto,
    daysAgo: 104,
    mileage: 11500,
    labor: 60000,
    parts: 140000,
    workshopId: taller1,
    notes: 'Cambio de aceite y revisión de cadena.',
    items: [
      {
        'category': 'motorcycle_oil',
        'parts_cost': 140000.0,
        'notes': 'Aceite 10W-40',
        'component_id': null,
      },
    ],
  );

  // --- Historial de kilometraje -----------------------------------
  const corollaReadings = <(int, int)>[
    (170, 38200),
    (145, 38950),
    (120, 39600),
    (90, 40800),
    (65, 42000),
    (40, 43200),
    (20, 44300),
    (3, 45200),
  ];
  for (final (days, km) in corollaReadings) {
    await db.insert('mileage_readings', {
      'vehicle_id': corolla,
      'date': ago(days),
      'mileage': km,
      'source': 'manual',
      'created_at': stampAgo(days),
    });
  }
  const motoReadings = <(int, int)>[
    (120, 10500),
    (80, 11300),
    (45, 12100),
    (5, 12800),
  ];
  for (final (days, km) in motoReadings) {
    await db.insert('mileage_readings', {
      'vehicle_id': moto,
      'date': ago(days),
      'mileage': km,
      'source': 'manual',
      'created_at': stampAgo(days),
    });
  }

  // --- Tanqueadas --------------------------------------------------
  Future<void> fuel({
    required int vehicleId,
    required int daysAgo,
    required int odometer,
    required double quantity,
    required double unitPrice,
    String station = 'Terpel',
  }) async {
    await db.insert('fuel_logs', {
      'vehicle_id': vehicleId,
      'date': ago(daysAgo),
      'odometer': odometer,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_cost': (quantity * unitPrice).roundToDouble(),
      'fuel_type': 'gasoline',
      'station': station,
      'full_tank': 1,
      'created_at': stampAgo(daysAgo),
      'updated_at': stampAgo(daysAgo),
    });
  }

  await fuel(
    vehicleId: corolla,
    daysAgo: 85,
    odometer: 42300,
    quantity: 42.5,
    unitPrice: 12900,
  );
  await fuel(
    vehicleId: corolla,
    daysAgo: 68,
    odometer: 42950,
    quantity: 40.1,
    unitPrice: 12900,
    station: 'Primax',
  );
  await fuel(
    vehicleId: corolla,
    daysAgo: 51,
    odometer: 43600,
    quantity: 43.8,
    unitPrice: 13100,
  );
  await fuel(
    vehicleId: corolla,
    daysAgo: 34,
    odometer: 44150,
    quantity: 38.2,
    unitPrice: 13100,
    station: 'Primax',
  );
  await fuel(
    vehicleId: corolla,
    daysAgo: 17,
    odometer: 44700,
    quantity: 41.0,
    unitPrice: 13300,
  );
  await fuel(
    vehicleId: corolla,
    daysAgo: 3,
    odometer: 45150,
    quantity: 39.6,
    unitPrice: 13300,
    station: 'Primax',
  );
  await fuel(
    vehicleId: moto,
    daysAgo: 40,
    odometer: 11900,
    quantity: 12.5,
    unitPrice: 13500,
  );
  await fuel(
    vehicleId: moto,
    daysAgo: 12,
    odometer: 12550,
    quantity: 11.8,
    unitPrice: 13500,
  );

  // --- Gastos ------------------------------------------------------
  Future<void> expense({
    int? vehicleId,
    required String categoryKey,
    required int daysAgo,
    required double amount,
    String? notes,
  }) async {
    await db.insert('expenses', {
      'vehicle_id': vehicleId,
      'category_key': categoryKey,
      'date': ago(daysAgo),
      'amount': amount,
      'notes': notes,
      'created_at': stampAgo(daysAgo),
      'updated_at': stampAgo(daysAgo),
    });
  }

  await expense(
    vehicleId: corolla,
    categoryKey: 'insurance',
    daysAgo: 155,
    amount: 1450000,
    notes: 'Póliza todo riesgo anual',
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'tax',
    daysAgo: 100,
    amount: 890000,
    notes: 'Impuesto vehicular 2026',
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'fines',
    daysAgo: 130,
    amount: 320000,
    notes: 'Comparendo por exceso de velocidad',
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'tolls',
    daysAgo: 70,
    amount: 65000,
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'accessories',
    daysAgo: 50,
    amount: 180000,
    notes: 'Alfombras y accesorios',
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'tolls',
    daysAgo: 36,
    amount: 48000,
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'wash',
    daysAgo: 8,
    amount: 40000,
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'tolls',
    daysAgo: 5,
    amount: 120000,
  );
  await expense(
    vehicleId: corolla,
    categoryKey: 'parking',
    daysAgo: 2,
    amount: 95000,
    notes: 'Parqueadero del centro comercial',
  );
  await expense(
    categoryKey: 'parking',
    daysAgo: 4,
    amount: 25000,
    notes: 'Parqueadero (global)',
  );

  // --- Presupuestos ------------------------------------------------
  String period(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';
  final currentPeriod = period(now);
  final lastPeriod = period(DateTime(now.year, now.month - 1));
  await db.insert('budgets', {
    'vehicle_id': corolla,
    'period': currentPeriod,
    'amount': 300000,
    'created_at': ts,
    'updated_at': ts,
  });
  await db.insert('budgets', {
    'vehicle_id': corolla,
    'period': lastPeriod,
    'amount': 500000,
    'created_at': ts,
    'updated_at': ts,
  });

  // --- Documentos --------------------------------------------------
  Future<void> document({
    int? vehicleId,
    required String type,
    required String name,
    required String number,
    required int issuedDaysAgo,
    required int expiresAhead,
  }) async {
    await db.insert('documents', {
      'vehicle_id': vehicleId,
      'type': type,
      'name': name,
      'number': number,
      'issued_at': ago(issuedDaysAgo),
      'expires_at': ahead(expiresAhead),
      'created_at': stampAgo(issuedDaysAgo),
      'updated_at': ts,
    });
  }

  await document(
    vehicleId: corolla,
    type: 'soat',
    name: 'SOAT 2026',
    number: 'SOAT-8845123',
    issuedDaysAgo: 245,
    expiresAhead: 120,
  );
  await document(
    vehicleId: corolla,
    type: 'rtm',
    name: 'Tecnomecánica',
    number: 'RTM-5521478',
    issuedDaysAgo: 301,
    expiresAhead: 64,
  );
  await document(
    vehicleId: corolla,
    type: 'insurance',
    name: 'Seguro todo riesgo',
    number: 'POL-998231',
    issuedDaysAgo: 343,
    expiresAhead: 22,
  );
  await document(
    vehicleId: corolla,
    type: 'license',
    name: 'Licencia de conducción',
    number: 'LIC-1020304',
    issuedDaysAgo: 400,
    expiresAhead: 1460,
  );
  await document(
    vehicleId: moto,
    type: 'soat',
    name: 'SOAT moto',
    number: 'SOAT-7745612',
    issuedDaysAgo: 165,
    expiresAhead: 200,
  );

  // --- Pico y placa ------------------------------------------------
  await db.insert('vehicle_restrictions', {
    'vehicle_id': corolla,
    'enabled': 1,
    'city': 'Bogotá',
    'days': '[2, 4]',
    'start_time': '06:00',
    'end_time': '21:00',
    'exempt': 0,
    'created_at': ts,
    'updated_at': ts,
  });
}

Future<void> _insertComponents(
  Database db,
  int vehicleId,
  String vehicleType,
  DateTime now, {
  required int installedKm,
}) async {
  final ts = formatDateTime(now);
  final installedAt = formatDate(now.subtract(const Duration(days: 380)));
  for (final t in componentTemplatesFor(vehicleType)) {
    await db.insert('components', {
      'vehicle_id': vehicleId,
      'name': t.name,
      'type': t.type,
      'position': t.position,
      'position_code': t.positionCode,
      'installed_at': installedAt,
      'installed_km': installedKm,
      'interval_km': t.intervalKm,
      'interval_months': t.intervalMonths,
      'warning_km': t.warningKm,
      'warning_days': t.warningDays,
      'active': t.active ? 1 : 0,
      'is_system': 1,
      'category_key': t.categoryKey,
      'created_at': ts,
      'updated_at': ts,
    });
  }
}
