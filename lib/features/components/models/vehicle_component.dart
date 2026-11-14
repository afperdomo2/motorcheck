import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_component.freezed.dart';
part 'vehicle_component.g.dart';

/// Pieza del vehículo con su propio ciclo de vida: llantas, batería, cadena,
/// frenos o suspensión. No reemplaza a los mantenimientos; convive con ellos.
@freezed
abstract class VehicleComponent with _$VehicleComponent {
  const factory VehicleComponent({
    int? id,
    required int vehicleId,
    required String name,
    @Default('other') String type,
    String? position,
    required DateTime installedAt,
    int? installedKm,
    int? intervalKm,
    int? intervalMonths,
    int? warningKm,
    int? warningDays,
    String? notes,
    @Default(true) bool active,
    @Default(false) bool isSystem,
    String? categoryKey,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VehicleComponent;

  factory VehicleComponent.fromJson(Map<String, dynamic> json) =>
      _$VehicleComponentFromJson(json);
}

class ComponentTypeOption {
  final String key;
  final String label;
  final IconData icon;

  const ComponentTypeOption(this.key, this.label, this.icon);
}

const componentTypeOptions = <ComponentTypeOption>[
  ComponentTypeOption('tire', 'Llanta', Icons.tire_repair),
  ComponentTypeOption(
    'battery',
    'Batería',
    Icons.battery_charging_full_outlined,
  ),
  ComponentTypeOption('chain', 'Cadena', Icons.link),
  ComponentTypeOption('brakes', 'Frenos', Icons.disc_full_outlined),
  ComponentTypeOption('suspension', 'Suspensión', Icons.settings_outlined),
  ComponentTypeOption('other', 'Otro', Icons.build_outlined),
];

ComponentTypeOption componentTypeFor(String type) {
  return componentTypeOptions.firstWhere(
    (option) => option.key == type,
    orElse: () => componentTypeOptions.last,
  );
}
