// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenanceImpl _$$MaintenanceImplFromJson(Map<String, dynamic> json) =>
    _$MaintenanceImpl(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      mileage: (json['mileage'] as num?)?.toInt(),
      maintenanceCost: (json['maintenanceCost'] as num?)?.toDouble() ?? 0,
      totalPartsCost: (json['totalPartsCost'] as num?)?.toDouble() ?? 0,
      workshopId: (json['workshopId'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MaintenanceImplToJson(_$MaintenanceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'date': instance.date.toIso8601String(),
      'mileage': instance.mileage,
      'maintenanceCost': instance.maintenanceCost,
      'totalPartsCost': instance.totalPartsCost,
      'workshopId': instance.workshopId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
