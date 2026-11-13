import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_run.freezed.dart';
part 'inspection_run.g.dart';

@freezed
abstract class InspectionRun with _$InspectionRun {
  const factory InspectionRun({
    int? id,
    required int vehicleId,
    required int checklistId,
    required DateTime date,
    int? odometer,
    String? notes,
    required DateTime createdAt,
  }) = _InspectionRun;

  factory InspectionRun.fromJson(Map<String, dynamic> json) =>
      _$InspectionRunFromJson(json);
}
