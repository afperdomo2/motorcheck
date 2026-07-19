import 'package:freezed_annotation/freezed_annotation.dart';

part 'workshop.freezed.dart';
part 'workshop.g.dart';

@freezed
class Workshop with _$Workshop {
  const factory Workshop({
    int? id,
    required String name,
    String? location,
    required DateTime createdAt,
  }) = _Workshop;

  factory Workshop.fromJson(Map<String, dynamic> json) =>
      _$WorkshopFromJson(json);
}
