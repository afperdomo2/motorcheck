import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_item.freezed.dart';
part 'maintenance_item.g.dart';

@freezed
abstract class MaintenanceItem with _$MaintenanceItem {
  const factory MaintenanceItem({
    int? id,
    required int maintenanceId,
    @Default('general') String category,
    @Default(0) double partsCost,
    String? notes,
    int? componentId,
    required DateTime createdAt,
  }) = _MaintenanceItem;

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceItemFromJson(json);
}
