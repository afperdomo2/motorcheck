// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_restriction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleRestriction _$VehicleRestrictionFromJson(Map<String, dynamic> json) =>
    _VehicleRestriction(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      enabled: json['enabled'] as bool? ?? false,
      city: json['city'] as String?,
      days:
          (json['days'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      startTime: json['startTime'] as String? ?? '06:00',
      endTime: json['endTime'] as String? ?? '21:00',
      exempt: json['exempt'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VehicleRestrictionToJson(_VehicleRestriction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'enabled': instance.enabled,
      'city': instance.city,
      'days': instance.days,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'exempt': instance.exempt,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
