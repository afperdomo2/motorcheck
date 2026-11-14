import 'package:freezed_annotation/freezed_annotation.dart';

part 'component_service.freezed.dart';
part 'component_service.g.dart';

/// Registro de servicio de un componente: cambio, rotación o revisión.
///
/// Si `resetInterval` es `true`, el servicio reinicia el ciclo del componente
/// (por ejemplo, un cambio de llanta o de batería). Las rotaciones y revisiones
/// se guardan con `false` para conservar la fecha de instalación.
@freezed
abstract class ComponentService with _$ComponentService {
  const factory ComponentService({
    int? id,
    required int componentId,
    required DateTime date,
    int? odometer,
    @Default(0) double cost,
    String? notes,
    @Default(false) bool resetInterval,
    required DateTime createdAt,
  }) = _ComponentService;

  factory ComponentService.fromJson(Map<String, dynamic> json) =>
      _$ComponentServiceFromJson(json);
}
