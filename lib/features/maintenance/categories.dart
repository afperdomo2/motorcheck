import 'package:flutter/material.dart';

class CategoryOption {
  final String key;
  final String label;
  final IconData icon;

  const CategoryOption(this.key, this.label, this.icon);
}

class MaintenanceCategories {
  MaintenanceCategories._();

  static const _iconMap = {
    'build': Icons.build,
    'construction': Icons.construction,
    'oil_barrel': Icons.oil_barrel,
    'disc_full': Icons.disc_full,
    'settings': Icons.settings,
    'tire_repair': Icons.tire_repair,
    'circle': Icons.circle,
    'filter_alt': Icons.filter_alt,
    'battery_charging_full': Icons.battery_charging_full,
    'ac_unit': Icons.ac_unit,
    'electrical_services': Icons.electrical_services,
    'link': Icons.link,
    'water_drop': Icons.water_drop,
    'local_gas_station': Icons.local_gas_station,
    'directions_car': Icons.directions_car,
    'cleaning_services': Icons.cleaning_services,
    'cable': Icons.cable,
    'handyman': Icons.handyman,
    'brightness_high': Icons.brightness_high,
    'sensors': Icons.sensors,
    'air': Icons.air,
    'radio': Icons.radio,
    'camera': Icons.camera,
    'visibility': Icons.visibility,
    'speed': Icons.speed,
    'bolt': Icons.bolt,
    'palette': Icons.palette,
    'security': Icons.security,
    'star': Icons.star,
  };

  static IconData iconByName(String iconName) =>
      _iconMap[iconName] ?? Icons.build;

  static Map<String, IconData> get iconMap => Map.unmodifiable(_iconMap);
}
