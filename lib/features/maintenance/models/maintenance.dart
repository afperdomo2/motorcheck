import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance.freezed.dart';
part 'maintenance.g.dart';

@freezed
class Maintenance with _$Maintenance {
  const factory Maintenance({
    int? id,
    required int vehicleId,
    required DateTime date,
    int? mileage,
    @Default(0) double maintenanceCost,
    @Default(0) double totalPartsCost,
    int? workshopId,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Maintenance;

  factory Maintenance.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceFromJson(json);
}
