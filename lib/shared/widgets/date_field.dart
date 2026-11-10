import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final IconData prefixIcon;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
    this.prefixIcon = Icons.calendar_today_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: hasValue && onClear != null
              ? IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Limpiar fecha',
                  onPressed: onClear,
                )
              : const Icon(Icons.expand_more),
        ),
        child: Text(
          hasValue ? formatShortDate(value!) : 'Selecciona la fecha',
          style: hasValue
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
