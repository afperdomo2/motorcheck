// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mileage_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MileageReading _$MileageReadingFromJson(Map<String, dynamic> json) =>
    _MileageReading(
      id: (json['id'] as num?)?.toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      mileage: (json['mileage'] as num).toInt(),
      source: json['source'] as String? ?? 'manual',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MileageReadingToJson(_MileageReading instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'date': instance.date.toIso8601String(),
      'mileage': instance.mileage,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
    };
