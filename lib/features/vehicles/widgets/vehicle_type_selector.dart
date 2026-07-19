import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VehicleTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onChanged;

  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const _types = [
    _TypeOption('car', 'Carro', Icons.directions_car),
    _TypeOption('motorcycle', 'Moto', Icons.motorcycle),
    _TypeOption('bike', 'Bicicleta', Icons.pedal_bike),
    _TypeOption('truck', 'Camión', Icons.local_shipping),
    _TypeOption('other', 'Otro', Icons.help_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _types.map((type) {
        final isSelected = type.value == selectedType;
        return ChoiceChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type.icon, size: 18),
              const SizedBox(width: 4),
              Text(type.label),
            ],
          ),
          onSelected: (_) => onChanged(type.value),
          selectedColor: AppColors.forVehicleType(
            type.value,
          ).withValues(alpha: 0.2),
        );
      }).toList(),
    );
  }
}

class _TypeOption {
  final String value;
  final String label;
  final IconData icon;

  const _TypeOption(this.value, this.label, this.icon);
}
