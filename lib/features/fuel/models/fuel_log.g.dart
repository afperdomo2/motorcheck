// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FuelLog _$FuelLogFromJson(Map<String, dynamic> json) => _FuelLog(
  id: (json['id'] as num?)?.toInt(),
  vehicleId: (json['vehicleId'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  odometer: (json['odometer'] as num).toInt(),
  quantity: (json['quantity'] as num).toDouble(),
  unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
  totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
  fuelType: json['fuelType'] as String? ?? 'gasoline',
  station: json['station'] as String?,
  fullTank: json['fullTank'] as bool? ?? true,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$FuelLogToJson(_FuelLog instance) => <String, dynamic>{
  'id': instance.id,
  'vehicleId': instance.vehicleId,
  'date': instance.date.toIso8601String(),
  'odometer': instance.odometer,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'totalCost': instance.totalCost,
  'fuelType': instance.fuelType,
  'station': instance.station,
  'fullTank': instance.fullTank,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
