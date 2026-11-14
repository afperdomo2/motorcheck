// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleComponent _$VehicleComponentFromJson(Map<String, dynamic> json) =>
    _VehicleComponent(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String? ?? 'other',
      position: json['position'] as String?,
      installedAt: DateTime.parse(json['installedAt'] as String),
      installedKm: (json['installedKm'] as num?)?.toInt(),
      intervalKm: (json['intervalKm'] as num?)?.toInt(),
      intervalMonths: (json['intervalMonths'] as num?)?.toInt(),
      warningKm: (json['warningKm'] as num?)?.toInt(),
      warningDays: (json['warningDays'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      active: json['active'] as bool? ?? true,
      isSystem: json['isSystem'] as bool? ?? false,
      categoryKey: json['categoryKey'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VehicleComponentToJson(_VehicleComponent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'name': instance.name,
      'type': instance.type,
      'position': instance.position,
      'installedAt': instance.installedAt.toIso8601String(),
      'installedKm': instance.installedKm,
      'intervalKm': instance.intervalKm,
      'intervalMonths': instance.intervalMonths,
      'warningKm': instance.warningKm,
      'warningDays': instance.warningDays,
      'notes': instance.notes,
      'active': instance.active,
      'isSystem': instance.isSystem,
      'categoryKey': instance.categoryKey,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
