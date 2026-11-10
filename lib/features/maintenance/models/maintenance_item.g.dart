// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaintenanceItem _$MaintenanceItemFromJson(Map<String, dynamic> json) =>
    _MaintenanceItem(
      id: (json['id'] as num?)?.toInt(),
      maintenanceId: (json['maintenanceId'] as num).toInt(),
      category: json['category'] as String? ?? 'general',
      partsCost: (json['partsCost'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MaintenanceItemToJson(_MaintenanceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'maintenanceId': instance.maintenanceId,
      'category': instance.category,
      'partsCost': instance.partsCost,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
