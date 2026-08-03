// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MaintenanceCategoryImpl _$$MaintenanceCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$MaintenanceCategoryImpl(
  id: (json['id'] as num?)?.toInt(),
  key: json['key'] as String,
  name: json['name'] as String,
  iconName: json['iconName'] as String? ?? 'build',
  vehicleType: json['vehicleType'] as String,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$MaintenanceCategoryImplToJson(
  _$MaintenanceCategoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'name': instance.name,
  'iconName': instance.iconName,
  'vehicleType': instance.vehicleType,
  'sortOrder': instance.sortOrder,
  'createdAt': instance.createdAt.toIso8601String(),
};
