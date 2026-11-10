// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaintenanceCategory _$MaintenanceCategoryFromJson(Map<String, dynamic> json) =>
    _MaintenanceCategory(
      id: (json['id'] as num?)?.toInt(),
      key: json['key'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String? ?? 'build',
      vehicleType: json['vehicleType'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      intervalKm: (json['intervalKm'] as num?)?.toInt(),
      warningKm: (json['warningKm'] as num?)?.toInt(),
      intervalMonths: (json['intervalMonths'] as num?)?.toInt(),
      warningDays: (json['warningDays'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MaintenanceCategoryToJson(
  _MaintenanceCategory instance,
) => <String, dynamic>{
  'id': instance.id,
  'key': instance.key,
  'name': instance.name,
  'iconName': instance.iconName,
  'vehicleType': instance.vehicleType,
  'sortOrder': instance.sortOrder,
  'intervalKm': instance.intervalKm,
  'warningKm': instance.warningKm,
  'intervalMonths': instance.intervalMonths,
  'warningDays': instance.warningDays,
  'createdAt': instance.createdAt.toIso8601String(),
};
