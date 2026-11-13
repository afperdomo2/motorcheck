// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaintenanceAttachment _$MaintenanceAttachmentFromJson(
  Map<String, dynamic> json,
) => _MaintenanceAttachment(
  id: (json['id'] as num?)?.toInt(),
  maintenanceId: (json['maintenanceId'] as num).toInt(),
  itemId: (json['itemId'] as num?)?.toInt(),
  name: json['name'] as String,
  filePath: json['filePath'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MaintenanceAttachmentToJson(
  _MaintenanceAttachment instance,
) => <String, dynamic>{
  'id': instance.id,
  'maintenanceId': instance.maintenanceId,
  'itemId': instance.itemId,
  'name': instance.name,
  'filePath': instance.filePath,
  'createdAt': instance.createdAt.toIso8601String(),
};
