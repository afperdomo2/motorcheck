// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenanceImpl _$$MaintenanceImplFromJson(Map<String, dynamic> json) =>
    _$MaintenanceImpl(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      mileage: (json['mileage'] as num?)?.toInt(),
      totalLaborCost: (json['totalLaborCost'] as num?)?.toDouble() ?? 0,
      totalPartsCost: (json['totalPartsCost'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MaintenanceImplToJson(_$MaintenanceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'mileage': instance.mileage,
      'totalLaborCost': instance.totalLaborCost,
      'totalPartsCost': instance.totalPartsCost,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
