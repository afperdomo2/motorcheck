import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../providers.dart';

class RecentActivity extends StatelessWidget {
  final DashboardSummary summary;

  const RecentActivity({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.recentMaintenances.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Sin mantenimientos registrados',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad reciente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...summary.recentMaintenances.map(
              (maintenance) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.build, size: 20)),
                title: Text(maintenance.title),
                subtitle: Text(formatDate(maintenance.date)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push('/maintenance/${maintenance.id}/edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
