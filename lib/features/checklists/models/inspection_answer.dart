import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_answer.freezed.dart';
part 'inspection_answer.g.dart';

@freezed
abstract class InspectionAnswer with _$InspectionAnswer {
  const factory InspectionAnswer({
    int? id,
    required int runId,
    required int itemId,
    @Default('ok') String status,
    String? notes,
  }) = _InspectionAnswer;

  factory InspectionAnswer.fromJson(Map<String, dynamic> json) =>
      _$InspectionAnswerFromJson(json);
}
