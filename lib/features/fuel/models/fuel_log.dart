import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fuel_log.freezed.dart';
part 'fuel_log.g.dart';

@freezed
abstract class FuelLog with _$FuelLog {
  const factory FuelLog({
    int? id,
    required int vehicleId,
    required DateTime date,
    required int odometer,
    required double quantity,
    @Default(0) double unitPrice,
    @Default(0) double totalCost,
    @Default('gasoline') String fuelType,
    String? station,
    @Default(true) bool fullTank,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FuelLog;

  factory FuelLog.fromJson(Map<String, dynamic> json) =>
      _$FuelLogFromJson(json);
}

class FuelTypeOption {
  final String key;
  final String label;
  final String unit;
  final IconData icon;

  const FuelTypeOption(this.key, this.label, this.unit, this.icon);
}

const fuelTypeOptions = <FuelTypeOption>[
  FuelTypeOption('gasoline', 'Gasolina', 'L', Icons.local_gas_station),
  FuelTypeOption('diesel', 'Diésel', 'L', Icons.local_gas_station),
  FuelTypeOption('gnv', 'GNV', 'm³', Icons.air),
  FuelTypeOption('electric', 'Eléctrico', 'kWh', Icons.bolt),
  FuelTypeOption('other', 'Otro', 'L', Icons.local_gas_station),
];

FuelTypeOption fuelTypeFor(String key) {
  return fuelTypeOptions.firstWhere(
    (option) => option.key == key,
    orElse: () => fuelTypeOptions.first,
  );
}
