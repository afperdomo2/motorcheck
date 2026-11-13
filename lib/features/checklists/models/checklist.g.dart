// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Checklist _$ChecklistFromJson(Map<String, dynamic> json) => _Checklist(
  id: (json['id'] as num?)?.toInt(),
  vehicleId: (json['vehicleId'] as num?)?.toInt(),
  vehicleType: json['vehicleType'] as String?,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ChecklistToJson(_Checklist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'vehicleType': instance.vehicleType,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
    };
