import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../providers.dart';

class QuickStats extends StatelessWidget {
  final DashboardSummary summary;

  const QuickStats({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.build_outlined,
                value: '${summary.totalMaintenances}',
                label: 'Mantenimientos',
                onTap: () => context.go('/maintenance'),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outlineVariant,
            ),
            Expanded(
              child: StatTile(
                icon: Icons.payments_outlined,
                value: formatCurrency(summary.currentMonthSpent),
                label: 'Mantenimiento ${summary.currentMonthLabel}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
