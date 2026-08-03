import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_category.freezed.dart';
part 'maintenance_category.g.dart';

@freezed
class MaintenanceCategory with _$MaintenanceCategory {
  const factory MaintenanceCategory({
    int? id,
    required String key,
    required String name,
    @Default('build') String iconName,
    required String vehicleType,
    @Default(0) int sortOrder,
    required DateTime createdAt,
  }) = _MaintenanceCategory;

  factory MaintenanceCategory.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceCategoryFromJson(json);
}
