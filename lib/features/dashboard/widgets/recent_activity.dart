import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../maintenance/categories.dart';
import '../../maintenance/models/maintenance.dart';
import '../../maintenance/providers.dart';
import '../../settings/models/maintenance_category.dart';
import '../../settings/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';

IconData _vehicleIcon(String? type) => switch (type) {
  'motorcycle' => Icons.motorcycle,
  'bike' => Icons.pedal_bike,
  'truck' => Icons.local_shipping,
  'other' => Icons.help_outline,
  _ => Icons.directions_car,
};

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
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final vehicles = vehiclesAsync.valueOrNull ?? [];
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
    final categoryMap = <String, MaintenanceCategory>{
      for (final c
          in (categoriesAsync.valueOrNull ?? []).cast<MaintenanceCategory>())
        c.key: c,
    };

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
              final vehicle = vehicles.cast<Vehicle?>().firstWhere(
                (v) => v?.id == maintenance.vehicleId,
                orElse: () => null,
              );

              return InkWell(
                onTap: () => context.push('/maintenance/${maintenance.id}'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _vehicleIcon(vehicle?.type),
                            size: 16,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              vehicle?.name ?? 'Vehículo',
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (total > 0)
                            Text(
                              formatCurrency(total),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _shortDate(maintenance.date),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildSecondLine(
                        context,
                        items,
                        maintenance,
                        categoryMap,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondLine(
    BuildContext context,
    List items,
    Maintenance maintenance,
    Map<String, MaintenanceCategory> categoryMap,
  ) {
    final hasItems = items.isNotEmpty;
    final hasMileage = maintenance.mileage != null;

    if (!hasItems && !hasMileage) return const SizedBox.shrink();

    final parts = <Widget>[];

    if (hasItems) {
      final uniqueCategories = items
          .map<dynamic>((i) => i.category)
          .toSet()
          .toList();
      const showMax = 2;
      final visible = uniqueCategories.take(showMax);
      final remaining = uniqueCategories.length - showMax;

      parts.addAll(
        visible.map((key) {
          final cat = categoryMap[key.toString()];
          final icon = cat != null
              ? MaintenanceCategories.iconByName(cat.iconName)
              : Icons.build;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 10),
                const SizedBox(width: 2),
                Text(
                  cat?.name ?? key.toString(),
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
          );
        }),
      );

      if (remaining > 0) {
        parts.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      }
    }

    if (hasMileage) {
      if (parts.isNotEmpty) {
        parts.add(
          Text(
            '·',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        );
      }
      parts.add(
        Text(
          formatMileage(maintenance.mileage),
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).disabledColor,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: Wrap(
        spacing: 4,
        runSpacing: 3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: parts,
      ),
    );
  }

  String _shortDate(DateTime date) {
    const months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month]}';
  }
}
