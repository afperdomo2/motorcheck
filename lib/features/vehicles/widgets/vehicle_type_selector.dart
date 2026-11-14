import 'package:flutter/material.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/vehicle_avatar.dart';

class VehicleTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onChanged;

  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const _types = [
    'car',
    'motorcycle',
    'bike',
    'scooter',
    'truck',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _types.map((type) {
        final isSelected = type == selectedType;
        final color = semantic.vehicleColor(type);

        return ChoiceChip(
          selected: isSelected,
          showCheckmark: false,
          selectedColor: color.withValues(alpha: 0.16),
          side: BorderSide(color: isSelected ? color : scheme.outlineVariant),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                vehicleTypeIcon(type),
                size: 18,
                color: isSelected ? color : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(vehicleTypeLabel(type)),
            ],
          ),
          onSelected: (_) => onChanged(type),
        );
      }).toList(),
    );
  }
}
