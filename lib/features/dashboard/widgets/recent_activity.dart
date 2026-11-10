import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../maintenance/models/maintenance.dart';
import '../../maintenance/models/maintenance_item.dart';
import '../../maintenance/providers.dart';
import '../../settings/models/maintenance_category.dart';
import '../../settings/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';

class RecentActivity extends ConsumerWidget {
  final DashboardSummary summary;

  const RecentActivity({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (summary.recentMaintenances.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
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
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
    final categoryMap = <String, MaintenanceCategory>{
      for (final c in categoriesAsync.valueOrNull ?? <MaintenanceCategory>[])
        c.key: c,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Actividad reciente',
          actionLabel: 'Ver todo',
          onAction: () async {
            try {
              final target = await ref.read(dashboardVehicleProvider.future);
              if (target?.id != null) {
                await ref
                    .read(vehiclesNotifierProvider.notifier)
                    .selectVehicle(target!.id!);
              }
            } catch (error) {
              logError(
                'abrir mantenimientos desde inicio',
                error,
                StackTrace.current,
              );
            }
            if (context.mounted) context.go('/maintenance');
          },
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < summary.recentMaintenances.length; i++) ...[
                if (i > 0) const Divider(),
                _ActivityRow(
                  maintenance: summary.recentMaintenances[i],
                  items:
                      itemsByMaintenance[summary.recentMaintenances[i].id] ??
                      const [],
                  vehicle: vehicles.cast<Vehicle?>().firstWhere(
                    (v) => v?.id == summary.recentMaintenances[i].vehicleId,
                    orElse: () => null,
                  ),
                  categoryMap: categoryMap,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Maintenance maintenance;
  final List<MaintenanceItem> items;
  final Vehicle? vehicle;
  final Map<String, MaintenanceCategory> categoryMap;

  const _ActivityRow({
    required this.maintenance,
    required this.items,
    required this.vehicle,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = maintenance.maintenanceCost + maintenance.totalPartsCost;

    return InkWell(
      onTap: () => context.push('/maintenance/${maintenance.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VehicleAvatar(type: vehicle?.type ?? 'other', size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle?.name ?? 'Vehículo',
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (total > 0)
                        Text(
                          formatCurrency(total),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatWeekdayDay(maintenance.date)}'
                    '${maintenance.mileage != null ? ' · ${formatMileage(maintenance.mileage)}' : ''}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _CategoryChips(items: items, categoryMap: categoryMap),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<MaintenanceItem> items;
  final Map<String, MaintenanceCategory> categoryMap;

  const _CategoryChips({required this.items, required this.categoryMap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unique = <String>{};
    for (final item in items) {
      unique.add(item.category);
    }
    final keys = unique.take(2).toList();
    final remaining = unique.length - keys.length;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final key in keys)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              categoryMap[key]?.name ?? key,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '+$remaining',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }
}
