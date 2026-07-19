import 'package:flutter/material.dart';

class CategoryOption {
  final String key;
  final String label;
  final IconData icon;

  const CategoryOption(this.key, this.label, this.icon);
}

class MaintenanceCategories {
  MaintenanceCategories._();

  static const car = [
    CategoryOption('engine', 'Motor', Icons.construction),
    CategoryOption('oil', 'Aceite', Icons.oil_barrel),
    CategoryOption('brakes', 'Frenos', Icons.disc_full),
    CategoryOption('transmission', 'Transmisión', Icons.settings),
    CategoryOption('suspension', 'Suspensión', Icons.tire_repair),
    CategoryOption('tires', 'Llantas', Icons.circle),
    CategoryOption('filters', 'Filtros', Icons.filter_alt),
    CategoryOption('battery', 'Batería', Icons.battery_charging_full),
    CategoryOption('ac', 'Aire Acond.', Icons.ac_unit),
    CategoryOption('electrical', 'Eléctrico', Icons.electrical_services),
    CategoryOption('general', 'General', Icons.build),
  ];

  static const motorcycle = [
    CategoryOption('engine', 'Motor', Icons.construction),
    CategoryOption('oil', 'Aceite', Icons.oil_barrel),
    CategoryOption('chain', 'Cadena', Icons.link),
    CategoryOption('brakes', 'Frenos', Icons.disc_full),
    CategoryOption('tires', 'Llantas', Icons.circle),
    CategoryOption('filters', 'Filtros', Icons.filter_alt),
    CategoryOption('battery', 'Batería', Icons.battery_charging_full),
    CategoryOption('suspension', 'Suspensión', Icons.tire_repair),
    CategoryOption('general', 'General', Icons.build),
  ];

  static const bike = [
    CategoryOption('brakes', 'Frenos', Icons.disc_full),
    CategoryOption('tires', 'Llantas', Icons.circle),
    CategoryOption('chain', 'Cadena', Icons.link),
    CategoryOption('transmission', 'Transmisión', Icons.settings),
    CategoryOption('suspension', 'Suspensión', Icons.tire_repair),
    CategoryOption('general', 'General', Icons.build),
  ];

  static const truck = [
    CategoryOption('engine', 'Motor', Icons.construction),
    CategoryOption('oil', 'Aceite', Icons.oil_barrel),
    CategoryOption('brakes', 'Frenos', Icons.disc_full),
    CategoryOption('transmission', 'Transmisión', Icons.settings),
    CategoryOption('suspension', 'Suspensión', Icons.tire_repair),
    CategoryOption('tires', 'Llantas', Icons.circle),
    CategoryOption('filters', 'Filtros', Icons.filter_alt),
    CategoryOption('battery', 'Batería', Icons.battery_charging_full),
    CategoryOption('ac', 'Aire Acond.', Icons.ac_unit),
    CategoryOption('electrical', 'Eléctrico', Icons.electrical_services),
    CategoryOption('general', 'General', Icons.build),
  ];

  static const other = [CategoryOption('general', 'General', Icons.build)];

  static const Map<String, List<CategoryOption>> _map = {
    'car': car,
    'motorcycle': motorcycle,
    'bike': bike,
    'truck': truck,
    'other': other,
  };

  static final Set<CategoryOption> all = _map.values
      .expand((list) => list)
      .toSet();

  static List<CategoryOption> forVehicleType(String type) =>
      _map[type] ?? other;

  static CategoryOption? byKey(String key) {
    for (final cat in all) {
      if (cat.key == key) return cat;
    }
    return null;
  }

  static String label(String key) => byKey(key)?.label ?? key;

  static IconData icon(String key) => byKey(key)?.icon ?? Icons.build;
}
