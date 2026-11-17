/// Posiciones válidas según el tipo de vehículo y de componente.
///
/// El camión y "otro" no tienen códigos: siguen usando texto libre.
List<String> positionCodesFor(String vehicleType, String componentType) {
  final isTwoWheel =
      vehicleType == 'motorcycle' ||
      vehicleType == 'bike' ||
      vehicleType == 'scooter';

  if (componentType == 'tire') {
    if (vehicleType == 'car') {
      return const [
        'front_left',
        'front_right',
        'rear_left',
        'rear_right',
        'spare',
      ];
    }
    if (isTwoWheel) return const ['front', 'rear'];
    return const [];
  }

  if (componentType == 'brakes') {
    if (vehicleType == 'car' || isTwoWheel) {
      return const ['front', 'rear'];
    }
    return const [];
  }

  return const [];
}

String positionLabelFor(String code, {required String componentType}) {
  final plural = componentType == 'brakes';
  return switch (code) {
    'front_left' => 'Delantera izquierda',
    'front_right' => 'Delantera derecha',
    'rear_left' => 'Trasera izquierda',
    'rear_right' => 'Trasera derecha',
    'front' => plural ? 'Delanteros' : 'Delantera',
    'rear' => plural ? 'Traseros' : 'Trasera',
    'spare' => 'Repuesto',
    _ => '',
  };
}

/// Nombre sugerido a partir del tipo y la posición.
String? componentNameForPosition(String componentType, String code) {
  if (code == 'spare' && componentType == 'tire') {
    return 'Llanta de repuesto';
  }
  final label = positionLabelFor(code, componentType: componentType);
  if (label.isEmpty) return null;
  final lower = label.toLowerCase();
  return switch (componentType) {
    'tire' => 'Llanta $lower',
    'brakes' => 'Frenos $lower',
    'suspension' => 'Suspensión $lower',
    _ => null,
  };
}

/// Nombre legible de un código, con respaldo al texto guardado.
String componentPositionLabel(
  String? code,
  String? fallback, {
  String? componentType,
}) {
  if (code == null) return fallback ?? '';
  final label = positionLabelFor(code, componentType: componentType ?? 'other');
  return label.isEmpty ? (fallback ?? '') : label;
}
