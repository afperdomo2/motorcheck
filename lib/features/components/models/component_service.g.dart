// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComponentService _$ComponentServiceFromJson(Map<String, dynamic> json) =>
    _ComponentService(
      id: (json['id'] as num?)?.toInt(),
      componentId: (json['componentId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      odometer: (json['odometer'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      resetInterval: json['resetInterval'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ComponentServiceToJson(_ComponentService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'componentId': instance.componentId,
      'date': instance.date.toIso8601String(),
      'odometer': instance.odometer,
      'cost': instance.cost,
      'notes': instance.notes,
      'resetInterval': instance.resetInterval,
      'createdAt': instance.createdAt.toIso8601String(),
    };
