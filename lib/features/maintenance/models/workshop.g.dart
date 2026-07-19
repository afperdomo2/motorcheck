// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workshop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkshopImpl _$$WorkshopImplFromJson(Map<String, dynamic> json) =>
    _$WorkshopImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WorkshopImplToJson(_$WorkshopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'createdAt': instance.createdAt.toIso8601String(),
    };
