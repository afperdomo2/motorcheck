import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final IconData prefixIcon;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.prefixIcon = Icons.calendar_today_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: const Icon(Icons.expand_more),
        ),
        child: Text(
          formatShortDate(value),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
