import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_restriction.freezed.dart';
part 'vehicle_restriction.g.dart';

@freezed
abstract class VehicleRestriction with _$VehicleRestriction {
  const factory VehicleRestriction({
    int? id,
    required int vehicleId,
    @Default(false) bool enabled,
    String? city,
    @Default(<int>[]) List<int> days,
    @Default('06:00') String startTime,
    @Default('21:00') String endTime,
    @Default(false) bool exempt,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VehicleRestriction;

  factory VehicleRestriction.fromJson(Map<String, dynamic> json) =>
      _$VehicleRestrictionFromJson(json);
}

const weekdayLabels = <int, String>{
  1: 'Lunes',
  2: 'Martes',
  3: 'Miércoles',
  4: 'Jueves',
  5: 'Viernes',
  6: 'Sábado',
  7: 'Domingo',
};

String restrictionDaysLabel(List<int> days) {
  if (days.isEmpty) return 'Sin días configurados';
  final sorted = [...days]..sort();
  if (sorted.length == 7) return 'Todos los días';
  return sorted.map((day) => weekdayLabels[day] ?? '').join(', ');
}
