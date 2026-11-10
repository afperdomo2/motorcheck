// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleDocument _$VehicleDocumentFromJson(Map<String, dynamic> json) =>
    _VehicleDocument(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num?)?.toInt(),
      type: json['type'] as String,
      name: json['name'] as String?,
      number: json['number'] as String?,
      issuedAt: json['issuedAt'] == null
          ? null
          : DateTime.parse(json['issuedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      filePath: json['filePath'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VehicleDocumentToJson(_VehicleDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'type': instance.type,
      'name': instance.name,
      'number': instance.number,
      'issuedAt': instance.issuedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'filePath': instance.filePath,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
