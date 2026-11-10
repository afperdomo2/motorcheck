// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workshop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Workshop _$WorkshopFromJson(Map<String, dynamic> json) => _Workshop(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  location: json['location'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WorkshopToJson(_Workshop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'location': instance.location,
  'createdAt': instance.createdAt.toIso8601String(),
};
