import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../providers.dart';

class QuickStats extends StatelessWidget {
  final DashboardSummary summary;

  const QuickStats({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.garage,
                    size: 40,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.totalVehicles} vehículo${summary.totalVehicles == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                _StatItem(
                  label: 'Mantenimientos',
                  value: '${summary.totalMaintenances}',
                  icon: Icons.build,
                ),
                _StatItem(
                  label: 'Total gastado',
                  value: formatCurrency(summary.totalSpent),
                  icon: Icons.payments,
                ),
              ],
            ),
            if (summary.lastMaintenance != null) ...[
              const Divider(height: 32),
              Text(
                'Último mantenimiento',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.lastMaintenance!.title} - ${formatDate(summary.lastMaintenance!.date)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
