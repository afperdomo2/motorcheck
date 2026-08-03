import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../settings/models/maintenance_category.dart';
import '../../settings/providers.dart';
import '../categories.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';
import '../models/workshop.dart';
import '../providers.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final int maintenanceId;

  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(maintenanceByIdProvider(maintenanceId));
    final itemsAsync = ref.watch(maintenanceItemsProvider(maintenanceId));
    final workshopsAsync = ref.watch(workshopsProvider);
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
    final vehicleMap = ref.watch(vehicleNamesProvider).valueOrNull ?? {};
    final categoryMap = <String, MaintenanceCategory>{
      for (final c
          in (categoriesAsync.valueOrNull ?? []).cast<MaintenanceCategory>())
        c.key: c,
    };

    final maintenance = maintenanceAsync.valueOrNull;
    final vehicle = maintenance != null
        ? vehicleMap[maintenance.vehicleId]
        : null;
    final title = maintenance != null
        ? formatDisplayDate(maintenance.date)
        : 'Detalle';
    final subtitle = vehicle?.name;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.pushReplacement('/maintenance/$maintenanceId/edit'),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteMaintenance(context, ref, maintenanceId),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: maintenanceAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(maintenanceByIdProvider(maintenanceId)),
        ),
        data: (maintenance) {
          if (maintenance == null) {
            return const ErrorState(message: 'Mantenimiento no encontrado');
          }

          return itemsAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, _) => ErrorState(
              message: err.toString(),
              onRetry: () =>
                  ref.invalidate(maintenanceItemsProvider(maintenanceId)),
            ),
            data: (items) {
              final workshops = workshopsAsync.valueOrNull ?? [];
              final workshop = _findWorkshop(workshops, maintenance.workshopId);
              final vehicle = vehicleMap[maintenance.vehicleId];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InfoCard(
                    maintenance: maintenance,
                    vehicle: vehicle,
                    workshop: workshop,
                  ),
                  if (maintenance.maintenanceCost > 0 ||
                      maintenance.totalPartsCost > 0) ...[
                    const SizedBox(height: 12),
                    _CostCard(maintenance: maintenance),
                  ],
                  const SizedBox(height: 12),
                  _ItemsCard(items: items, categoryMap: categoryMap),
                  if (maintenance.notes != null &&
                      maintenance.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _NotesCard(notes: maintenance.notes!),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Workshop? _findWorkshop(List<Workshop> workshops, int? workshopId) {
    if (workshopId == null) return null;
    for (final w in workshops) {
      if (w.id == workshopId) return w;
    }
    return null;
  }

  Future<void> _deleteMaintenance(
    BuildContext context,
    WidgetRef ref,
    int maintenanceId,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar mantenimiento',
      message:
          '¿Estás seguro de eliminar este mantenimiento y todos sus items?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      ref.read(maintenancesNotifierProvider.notifier).remove(maintenanceId);
      context.pop();
    }
  }
}

IconData _vehicleTypeIcon(String type) {
  return switch (type) {
    'motorcycle' => Icons.motorcycle,
    'bike' => Icons.pedal_bike,
    'truck' => Icons.local_shipping,
    _ => Icons.directions_car,
  };
}

class _InfoCard extends StatelessWidget {
  final Maintenance maintenance;
  final dynamic vehicle;
  final Workshop? workshop;

  const _InfoCard({
    required this.maintenance,
    required this.vehicle,
    this.workshop,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleName = vehicle?.name ?? 'Vehículo';
    final vehicleType = vehicle?.type as String? ?? 'other';
    final typeColor = AppColors.forVehicleType(vehicleType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_vehicleTypeIcon(vehicleType), color: typeColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    vehicleName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Fecha',
              value: formatDisplayDate(maintenance.date),
            ),
            if (maintenance.mileage != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.speed,
                label: 'Kilometraje',
                value: formatMileage(maintenance.mileage),
              ),
            ],
            if (workshop != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.handyman,
                label: 'Taller',
                value:
                    workshop!.location != null && workshop!.location!.isNotEmpty
                    ? '${workshop!.name} · ${workshop!.location}'
                    : workshop!.name,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final Maintenance maintenance;

  const _CostCard({required this.maintenance});

  @override
  Widget build(BuildContext context) {
    final total = maintenance.maintenanceCost + maintenance.totalPartsCost;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              formatCurrency(total),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text('Total', style: theme.textTheme.labelSmall),
            if (maintenance.maintenanceCost > 0) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.construction, size: 18),
                  const SizedBox(width: 8),
                  Text('Mano de obra', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text(
                    formatCurrency(maintenance.maintenanceCost),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
            if (maintenance.totalPartsCost > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 18),
                  const SizedBox(width: 8),
                  Text('Repuestos', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text(
                    formatCurrency(maintenance.totalPartsCost),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final List<MaintenanceItem> items;
  final Map<String, MaintenanceCategory> categoryMap;

  const _ItemsCard({required this.items, this.categoryMap = const {}});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalParts = items.fold<double>(0, (s, i) => s + i.partsCost);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Items (${items.length})',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (totalParts > 0)
                  Text(
                    formatCurrency(totalParts),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (items.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Sin items registrados',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const Divider(height: 20),
              ...items.map(
                (item) => _ItemTile(item: item, categoryMap: categoryMap),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final MaintenanceItem item;
  final Map<String, MaintenanceCategory> categoryMap;

  const _ItemTile({required this.item, this.categoryMap = const {}});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNote = item.notes != null && item.notes!.isNotEmpty;
    final cat = categoryMap[item.category];
    final icon = cat != null
        ? MaintenanceCategories.iconByName(cat.iconName)
        : Icons.build;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: hasNote
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat?.name ?? item.category,
                  style: theme.textTheme.bodyMedium,
                ),
                if (hasNote)
                  Text(
                    item.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (item.partsCost > 0)
            Text(
              formatCurrency(item.partsCost),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.note_alt_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(notes, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).disabledColor),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Flexible(
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
