// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InspectionRun _$InspectionRunFromJson(Map<String, dynamic> json) =>
    _InspectionRun(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      checklistId: (json['checklistId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      odometer: (json['odometer'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InspectionRunToJson(_InspectionRun instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'checklistId': instance.checklistId,
      'date': instance.date.toIso8601String(),
      'odometer': instance.odometer,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
