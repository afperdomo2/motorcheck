import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

enum FinanceSection { summary, fuel, expenses }

class FinanceSectionSelector extends StatelessWidget {
  const FinanceSectionSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final FinanceSection selected;
  final ValueChanged<FinanceSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final compact = MediaQuery.textScalerOf(context).scale(1) > 1.35;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Segment(
            section: FinanceSection.summary,
            selected: selected == FinanceSection.summary,
            icon: Icons.pie_chart_outline,
            selectedIcon: Icons.pie_chart,
            label: 'Resumen',
            compactLabel: 'Resumen',
            compact: compact,
            onTap: onChanged,
          ),
          _Segment(
            section: FinanceSection.fuel,
            selected: selected == FinanceSection.fuel,
            icon: Icons.local_gas_station_outlined,
            selectedIcon: Icons.local_gas_station,
            label: 'Combustible',
            compactLabel: 'Comb.',
            compact: compact,
            onTap: onChanged,
          ),
          _Segment(
            section: FinanceSection.expenses,
            selected: selected == FinanceSection.expenses,
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long,
            label: 'Gastos',
            compactLabel: 'Gastos',
            compact: compact,
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.section,
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.compactLabel,
    required this.compact,
    required this.onTap,
  });

  final FinanceSection section;
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String compactLabel;
  final bool compact;
  final ValueChanged<FinanceSection> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final shownLabel = compact ? compactLabel : label;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('finance-section-${section.name}'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => onTap(section),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? selectedIcon : icon,
                        size: 18,
                        color: foreground,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        shownLabel,
                        maxLines: 1,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
