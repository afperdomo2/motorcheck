import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../maintenance/categories.dart';
import '../../maintenance/providers.dart';
import '../providers.dart';

class RecentActivity extends ConsumerWidget {
  final DashboardSummary summary;

  const RecentActivity({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final ids = summary.recentMaintenances.map((m) => m.id!).toList()..sort();
    final itemsAsync = ref.watch(workshopItemsProvider(ids.join(',')));
    final itemsByMaintenance = itemsAsync.valueOrNull ?? {};

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
            ...summary.recentMaintenances.map((maintenance) {
              final items = itemsByMaintenance[maintenance.id] ?? [];
              final total =
                  maintenance.maintenanceCost + maintenance.totalPartsCost;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.build, size: 20)),
                title: _buildCategoryChips(context, items),
                subtitle: total > 0
                    ? Text(
                        formatCurrency(total),
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : maintenance.mileage != null
                    ? Text(
                        formatMileage(maintenance.mileage),
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : null,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatDate(maintenance.date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
                onTap: () => context.push('/maintenance/${maintenance.id}'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, List items) {
    if (items.isEmpty) {
      return Text(
        'Sin categorías',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
      );
    }

    final uniqueCategories = items
        .map<dynamic>((i) => i.category)
        .toSet()
        .toList();
    const showMax = 2;
    final visible = uniqueCategories.take(showMax);
    final remaining = uniqueCategories.length - showMax;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...visible.map((key) {
          final cat = MaintenanceCategories.byKey(key.toString());
          return Chip(
            avatar: Icon(cat?.icon ?? Icons.build, size: 14),
            label: Text(
              cat?.label ?? key.toString(),
              style: const TextStyle(fontSize: 11),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.only(right: 4),
          );
        }),
        if (remaining > 0)
          Chip(
            label: Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
      ],
    );
  }
}
