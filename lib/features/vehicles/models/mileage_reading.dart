import 'package:freezed_annotation/freezed_annotation.dart';

part 'mileage_reading.freezed.dart';
part 'mileage_reading.g.dart';

@freezed
abstract class MileageReading with _$MileageReading {
  const factory MileageReading({
    int? id,
    required int vehicleId,
    required DateTime date,
    required int mileage,
    @Default('manual') String source,
    required DateTime createdAt,
  }) = _MileageReading;

  factory MileageReading.fromJson(Map<String, dynamic> json) =>
      _$MileageReadingFromJson(json);
}
