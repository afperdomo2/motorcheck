// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InspectionAnswer _$InspectionAnswerFromJson(Map<String, dynamic> json) =>
    _InspectionAnswer(
      id: (json['id'] as num?)?.toInt(),
      runId: (json['runId'] as num).toInt(),
      itemId: (json['itemId'] as num).toInt(),
      status: json['status'] as String? ?? 'ok',
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$InspectionAnswerToJson(_InspectionAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runId': instance.runId,
      'itemId': instance.itemId,
      'status': instance.status,
      'notes': instance.notes,
    };
