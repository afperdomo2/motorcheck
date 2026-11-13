import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist.freezed.dart';
part 'checklist.g.dart';

@freezed
abstract class Checklist with _$Checklist {
  const factory Checklist({
    int? id,
    int? vehicleId,
    String? vehicleType,
    required String name,
    required DateTime createdAt,
  }) = _Checklist;

  factory Checklist.fromJson(Map<String, dynamic> json) =>
      _$ChecklistFromJson(json);
}
