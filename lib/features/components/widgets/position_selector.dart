import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/component_position.dart';

class PositionSelector extends StatelessWidget {
  const PositionSelector({
    super.key,
    required this.componentType,
    required this.codes,
    required this.selected,
    required this.onChanged,
  });

  final String componentType;
  final List<String> codes;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final code in codes)
          ChoiceChip(
            label: Text(positionLabelFor(code, componentType: componentType)),
            selected: selected == code,
            onSelected: (_) => onChanged(code),
          ),
        ChoiceChip(
          label: const Text('Sin posición'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
      ],
    );
  }
}
