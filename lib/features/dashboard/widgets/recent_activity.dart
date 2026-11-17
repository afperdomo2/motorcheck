import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../maintenance/models/maintenance.dart';
import '../../maintenance/models/maintenance_item.dart';
import '../../maintenance/providers.dart';
import '../../settings/models/maintenance_category.dart';
import '../../settings/providers.dart';
import '../../vehicles/current_vehicle_provider.dart';
import '../../vehicles/models/vehicle.dart';
import '../providers.dart';

class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenancesAsync = ref.watch(dashboardRecentMaintenancesProvider);
    final maintenances = maintenancesAsync.valueOrNull ?? const [];
    final vehicle = ref.watch(currentVehicleProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Últimos mantenimientos',
          actionLabel: 'Ver todo',
          onAction: () => context.go('/maintenance'),
        ),
        if (maintenancesAsync.isLoading && maintenances.isEmpty)
          const _LoadingCard()
        else if (maintenancesAsync.hasError)
          _ErrorCard(
            onRetry: () => ref.invalidate(dashboardRecentMaintenancesProvider),
          )
        else if (maintenances.isEmpty)
          _EmptyCard(vehicleId: vehicle?.id)
        else
          _ActivityList(maintenances: maintenances, vehicle: vehicle),
      ],
    );
  }
}

class _ActivityList extends ConsumerWidget {
  const _ActivityList({required this.maintenances, required this.vehicle});

  final List<Maintenance> maintenances;
  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = maintenances.map((maintenance) => maintenance.id!).toList()
      ..sort();
    final itemsByMaintenance =
        ref.watch(workshopItemsProvider(ids.join(','))).valueOrNull ?? {};
    final categories =
        ref.watch(maintenanceCategoriesProvider).valueOrNull ??
        <MaintenanceCategory>[];
    final categoryMap = {
      for (final category in categories) category.key: category,
    };

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < maintenances.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _ActivityRow(
              maintenance: maintenances[i],
              items: itemsByMaintenance[maintenances[i].id] ?? const [],
              vehicle: vehicle,
              categoryMap: categoryMap,
            ),
          ],
        ],
      ),
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
        for (final key in keys) _chip(context, categoryMap[key]?.name ?? key),
        if (remaining > 0) _chip(context, '+$remaining'),
      ],
    );
  }

  Widget _chip(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'No se pudieron cargar los mantenimientos',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.vehicleId});

  final int? vehicleId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Sin mantenimientos registrados',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (vehicleId != null)
              TextButton(
                onPressed: () =>
                    context.push('/maintenance/add?vehicleId=$vehicleId'),
                child: const Text('Registrar'),
              ),
          ],
        ),
      ),
    );
  }
}
