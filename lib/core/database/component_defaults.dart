/// Plantillas de componentes por tipo de vehículo.
///
/// Viven en `core` para que tanto la migración de la base como el feature de
/// componentes usen la misma definición.
class ComponentTemplate {
  const ComponentTemplate({
    required this.name,
    required this.type,
    required this.categoryKey,
    this.position,
    this.positionCode,
    this.intervalKm,
    this.intervalMonths,
    this.warningKm,
    this.warningDays,
    this.active = true,
  });

  final String name;
  final String type;
  final String categoryKey;
  final String? position;
  final String? positionCode;
  final int? intervalKm;
  final int? intervalMonths;
  final int? warningKm;
  final int? warningDays;
  final bool active;
}

const _car = <ComponentTemplate>[
  ComponentTemplate(
    name: 'Llanta delantera izquierda',
    type: 'tire',
    categoryKey: 'car_tires',
    position: 'Delantera izquierda',
    positionCode: 'front_left',
    intervalKm: 50000,
    warningKm: 3000,
  ),
  ComponentTemplate(
    name: 'Llanta delantera derecha',
    type: 'tire',
    categoryKey: 'car_tires',
    position: 'Delantera derecha',
    positionCode: 'front_right',
    intervalKm: 50000,
    warningKm: 3000,
  ),
  ComponentTemplate(
    name: 'Llanta trasera izquierda',
    type: 'tire',
    categoryKey: 'car_tires',
    position: 'Trasera izquierda',
    positionCode: 'rear_left',
    intervalKm: 50000,
    warningKm: 3000,
  ),
  ComponentTemplate(
    name: 'Llanta trasera derecha',
    type: 'tire',
    categoryKey: 'car_tires',
    position: 'Trasera derecha',
    positionCode: 'rear_right',
    intervalKm: 50000,
    warningKm: 3000,
  ),
  ComponentTemplate(
    name: 'Batería',
    type: 'battery',
    categoryKey: 'car_battery',
    intervalMonths: 36,
    warningDays: 30,
  ),
  ComponentTemplate(
    name: 'Frenos delanteros',
    type: 'brakes',
    categoryKey: 'car_brakes',
    position: 'Delanteros',
    positionCode: 'front',
    intervalKm: 30000,
    warningKm: 2000,
  ),
  ComponentTemplate(
    name: 'Frenos traseros',
    type: 'brakes',
    categoryKey: 'car_brakes',
    position: 'Traseros',
    positionCode: 'rear',
    intervalKm: 30000,
    warningKm: 2000,
  ),
];

const _motorcycle = <ComponentTemplate>[
  ComponentTemplate(
    name: 'Llanta delantera',
    type: 'tire',
    categoryKey: 'motorcycle_tires',
    position: 'Delantera',
    positionCode: 'front',
    intervalKm: 15000,
    warningKm: 1000,
  ),
  ComponentTemplate(
    name: 'Llanta trasera',
    type: 'tire',
    categoryKey: 'motorcycle_tires',
    position: 'Trasera',
    positionCode: 'rear',
    intervalKm: 12000,
    warningKm: 1000,
  ),
  ComponentTemplate(
    name: 'Kit de arrastre',
    type: 'chain',
    categoryKey: 'motorcycle_chain',
    position: 'Cadena y piñones',
    intervalKm: 18000,
    warningKm: 1000,
  ),
  ComponentTemplate(
    name: 'Frenos delanteros',
    type: 'brakes',
    categoryKey: 'motorcycle_brakes',
    position: 'Delanteros',
    positionCode: 'front',
    intervalKm: 10000,
    warningKm: 1000,
  ),
  ComponentTemplate(
    name: 'Frenos traseros',
    type: 'brakes',
    categoryKey: 'motorcycle_brakes',
    position: 'Traseros',
    positionCode: 'rear',
    intervalKm: 10000,
    warningKm: 1000,
  ),
  ComponentTemplate(
    name: 'Batería',
    type: 'battery',
    categoryKey: 'motorcycle_battery',
    intervalMonths: 24,
    warningDays: 30,
  ),
];

const _bike = <ComponentTemplate>[
  ComponentTemplate(
    name: 'Llanta delantera',
    type: 'tire',
    categoryKey: 'bike_tires',
    position: 'Delantera',
    positionCode: 'front',
    intervalKm: 5000,
    warningKm: 500,
  ),
  ComponentTemplate(
    name: 'Llanta trasera',
    type: 'tire',
    categoryKey: 'bike_tires',
    position: 'Trasera',
    positionCode: 'rear',
    intervalKm: 5000,
    warningKm: 500,
  ),
  ComponentTemplate(
    name: 'Cadena',
    type: 'chain',
    categoryKey: 'bike_chain',
    intervalKm: 4000,
    warningKm: 300,
  ),
  ComponentTemplate(
    name: 'Frenos delanteros',
    type: 'brakes',
    categoryKey: 'bike_brakes',
    position: 'Delanteros',
    positionCode: 'front',
    intervalKm: 3000,
    warningKm: 300,
  ),
  ComponentTemplate(
    name: 'Frenos traseros',
    type: 'brakes',
    categoryKey: 'bike_brakes',
    position: 'Traseros',
    positionCode: 'rear',
    intervalKm: 3000,
    warningKm: 300,
  ),
  ComponentTemplate(
    name: 'Batería',
    type: 'battery',
    categoryKey: 'bike_battery',
    intervalMonths: 24,
    warningDays: 30,
    active: false,
  ),
];

const _scooter = <ComponentTemplate>[
  ComponentTemplate(
    name: 'Llanta delantera',
    type: 'tire',
    categoryKey: 'scooter_tires',
    position: 'Delantera',
    positionCode: 'front',
    intervalKm: 5000,
    warningKm: 500,
  ),
  ComponentTemplate(
    name: 'Llanta trasera',
    type: 'tire',
    categoryKey: 'scooter_tires',
    position: 'Trasera',
    positionCode: 'rear',
    intervalKm: 5000,
    warningKm: 500,
  ),
  ComponentTemplate(
    name: 'Batería',
    type: 'battery',
    categoryKey: 'scooter_battery',
    intervalMonths: 24,
    warningDays: 30,
  ),
  ComponentTemplate(
    name: 'Frenos delanteros',
    type: 'brakes',
    categoryKey: 'scooter_brakes',
    position: 'Delanteros',
    positionCode: 'front',
    intervalKm: 3000,
    warningKm: 300,
  ),
  ComponentTemplate(
    name: 'Frenos traseros',
    type: 'brakes',
    categoryKey: 'scooter_brakes',
    position: 'Traseros',
    positionCode: 'rear',
    intervalKm: 3000,
    warningKm: 300,
  ),
];

List<ComponentTemplate> componentTemplatesFor(String vehicleType) {
  return switch (vehicleType) {
    'car' => _car,
    'motorcycle' => _motorcycle,
    'bike' => _bike,
    'scooter' => _scooter,
    _ => const [],
  };
}

/// Categoría de mantenimiento asociada a un componente, según el tipo de
/// vehículo. Sirve para silenciar la alerta duplicada de la categoría y para
/// precargar el ítem cuando se reemplaza la pieza.
String? componentCategoryKeyFor(String vehicleType, String componentType) {
  return switch ((vehicleType, componentType)) {
    ('car', 'tire') => 'car_tires',
    ('car', 'brakes') => 'car_brakes',
    ('car', 'battery') => 'car_battery',
    ('car', 'suspension') => 'car_suspension',
    ('motorcycle', 'tire') => 'motorcycle_tires',
    ('motorcycle', 'brakes') => 'motorcycle_brakes',
    ('motorcycle', 'chain') => 'motorcycle_chain',
    ('motorcycle', 'battery') => 'motorcycle_battery',
    ('motorcycle', 'suspension') => 'motorcycle_suspension',
    ('bike', 'tire') => 'bike_tires',
    ('bike', 'brakes') => 'bike_brakes',
    ('bike', 'chain') => 'bike_chain',
    ('bike', 'suspension') => 'bike_suspension',
    ('scooter', 'tire') => 'scooter_tires',
    ('scooter', 'brakes') => 'scooter_brakes',
    ('scooter', 'battery') => 'scooter_battery',
    ('truck', 'tire') => 'truck_tires',
    ('truck', 'brakes') => 'truck_brakes',
    ('truck', 'battery') => 'truck_battery',
    ('truck', 'suspension') => 'truck_suspension',
    _ => null,
  };
}

/// Infiere el código de posición desde un texto libre. Se usa en la migración
/// v22 para rellenar `position_code` sin perder registros.
String? positionCodeFromText(String? text) {
  if (text == null) return null;
  final value = normalizePositionText(text);
  if (value.isEmpty) return null;

  if (value.contains('repuesto') || value.contains('spare')) return 'spare';

  final left = value.contains('izq');
  final right = value.contains('der');
  final front =
      value.contains('delant') || value.contains('front') || value == 'del';
  final rear = value.contains('tras') || value.contains('rear');

  if (front && left) return 'front_left';
  if (front && right) return 'front_right';
  if (rear && left) return 'rear_left';
  if (rear && right) return 'rear_right';
  if (front) return 'front';
  if (rear) return 'rear';
  return null;
}

String normalizePositionText(String input) {
  const accents = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'ã': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ñ': 'n',
  };
  final buffer = StringBuffer();
  for (final char in input.toLowerCase().split('')) {
    buffer.write(accents[char] ?? char);
  }
  return buffer.toString().trim();
}
