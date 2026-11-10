import 'package:flutter/material.dart';

import '../../core/theme/app_semantic_colors.dart';

IconData vehicleTypeIcon(String type) => switch (type) {
  'car' => Icons.directions_car,
  'motorcycle' => Icons.motorcycle,
  'bike' => Icons.pedal_bike,
  'truck' => Icons.local_shipping,
  _ => Icons.help_outline,
};

String vehicleTypeLabel(String type) => switch (type) {
  'car' => 'Carro',
  'motorcycle' => 'Moto',
  'bike' => 'Bicicleta',
  'truck' => 'Camión',
  _ => 'Otro',
};

class VehicleAvatar extends StatelessWidget {
  final String type;
  final double size;

  const VehicleAvatar({super.key, required this.type, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    final color = semantic.vehicleColor(type);
    final label = vehicleTypeLabel(type);

    return Semantics(
      label: 'Vehículo tipo $label',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Icon(vehicleTypeIcon(type), color: color, size: size * 0.52),
      ),
    );
  }
}
