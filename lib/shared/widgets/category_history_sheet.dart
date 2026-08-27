import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../features/maintenance/categories.dart';
import '../../features/maintenance/providers.dart';
import '../../features/maintenance/repository.dart';
import '../../features/settings/models/maintenance_category.dart';
import '../../features/vehicles/models/vehicle.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'loading_indicator.dart';

class CategoryHistorySheet extends ConsumerWidget {
  final Vehicle vehicle;
  final MaintenanceCategory category;

  const CategoryHistorySheet({
    super.key,
    required this.vehicle,
    required this.category,
  });

  static Future<void> show(
    BuildContext context, {
    required Vehicle vehicle,
    required MaintenanceCategory category,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          CategoryHistorySheet(vehicle: vehicle, category: category),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final icon = MaintenanceCategories.iconByName(category.iconName);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Icon(icon, size: 24, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            Expanded(
              child: CategoryHistoryView(
                vehicle: vehicle,
                category: category,
                controller: scrollController,
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategoryHistoryView extends ConsumerWidget {
  final Vehicle vehicle;
  final MaintenanceCategory category;
  final ScrollController? controller;

  const CategoryHistoryView({
    super.key,
    required this.vehicle,
    required this.category,
    this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleId = vehicle.id;
    if (vehicleId == null) {
      return const ErrorState(message: 'Vehículo sin guardar');
    }

    final historyAsync = ref.watch(
      maintenanceCategoryHistoryProvider((
        vehicleId: vehicleId,
        category: category.key,
      )),
    );
    final upcomingItems = ref
        .watch(upcomingMaintenanceProvider(vehicleId))
        .valueOrNull;
    final upcoming = _upcomingFor(upcomingItems, category.key);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _CurrentMileageCard(mileage: vehicle.currentMileage),
        const SizedBox(height: 12),
        _AlertCard(upcoming: upcoming),
        const SizedBox(height: 16),
        Text('Historial', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        historyAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoadingIndicator(),
          ),
          error: (err, _) => ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(
              maintenanceCategoryHistoryProvider((
                vehicleId: vehicleId,
                category: category.key,
              )),
            ),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return const EmptyState(
                icon: Icons.history,
                title: 'Sin registros previos',
                subtitle: 'Este item aún no se ha realizado en este vehículo',
              );
            }
            return _HistoryTable(entries: entries);
          },
        ),
      ],
    );
  }

  UpcomingMaintenance? _upcomingFor(
    List<UpcomingMaintenance>? items,
    String categoryKey,
  ) {
    if (items == null) return null;
    for (final item in items) {
      if (item.category.key == categoryKey) return item;
    }
    return null;
  }
}

class _CurrentMileageCard extends StatelessWidget {
  final int? mileage;

  const _CurrentMileageCard({required this.mileage});

  @override
  Widget build(BuildContext context) {
    if (mileage == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Registra el kilometraje actual del vehículo para '
                  'calcular los próximos mantenimientos',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.speed,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kilometraje actual',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  formatMileage(mileage),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final UpcomingMaintenance? upcoming;

  const _AlertCard({required this.upcoming});

  @override
  Widget build(BuildContext context) {
    if (upcoming == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final color = upcoming!.statusColor();
    final label = upcoming!.statusLabel();
    final hasInterval = upcoming!.category.intervalKm != null;
    final hasLastMileage = upcoming!.lastMileage != null;
    final nextServiceKm = hasInterval && hasLastMileage
        ? upcoming!.lastMileage! + upcoming!.category.intervalKm!
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_outlined, size: 22, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Próximo mantenimiento',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (!hasInterval) ...[
              const SizedBox(height: 8),
              Text(
                'Configura la frecuencia en kilómetros en Categorías '
                'para saber cuándo toca el próximo mantenimiento',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ] else if (!hasLastMileage) ...[
              const SizedBox(height: 8),
              Text(
                'Aún no hay registro previo de este item en este vehículo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _InfoLine(
                icon: Icons.speed,
                label: 'Próximo a los',
                value: formatMileage(nextServiceKm),
              ),
              if (upcoming!.remainingKm != null) ...[
                const SizedBox(height: 6),
                _InfoLine(
                  icon: upcoming!.isOverdue
                      ? Icons.error_outline
                      : Icons.timelapse,
                  label: upcoming!.isOverdue ? 'Vencido hace' : 'Faltan',
                  value: upcoming!.isOverdue
                      ? '${-upcoming!.remainingKm!} km'
                      : '${upcoming!.remainingKm} km',
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniInfo(
                    icon: Icons.loop,
                    label: 'Cada',
                    value: '${upcoming!.category.intervalKm} km',
                  ),
                  const SizedBox(width: 16),
                  _MiniInfo(
                    icon: Icons.notifications_outlined,
                    label: 'Aviso',
                    value: upcoming!.category.warningKm != null
                        ? '${upcoming!.category.warningKm} km antes'
                        : 'No configurado',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.history, size: 14, color: theme.disabledColor),
                  const SizedBox(width: 4),
                  Text(
                    'Último: ${formatMileage(upcoming!.lastMileage)}',
                    style: theme.textTheme.bodySmall,
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

class _HistoryTable extends StatelessWidget {
  final List<CategoryHistoryEntry> entries;

  const _HistoryTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      color: AppColors.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 88, child: Text('Fecha', style: headerStyle)),
                SizedBox(width: 64, child: Text('Km', style: headerStyle)),
                SizedBox(width: 68, child: Text('Costo', style: headerStyle)),
                Expanded(
                  child: Text(
                    'Nota',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...entries.map((entry) => _HistoryRow(entry: entry, isLast: false)),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final CategoryHistoryEntry entry;
  final bool isLast;

  const _HistoryRow({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = _notesText(entry);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              formatShortDate(entry.date),
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              formatMileage(entry.mileage),
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 68,
            child: Text(
              entry.partsCost > 0 ? formatCurrency(entry.partsCost) : '-',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              notes,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _notesText(CategoryHistoryEntry entry) {
    final parts = [
      entry.notes,
      entry.maintenanceNotes,
    ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);
    final unique = <String>{};
    final result = parts.where((s) => unique.add(s));
    final joined = result.join(' · ');
    return joined.isEmpty ? '-' : joined;
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.disabledColor),
        const SizedBox(width: 6),
        Text('$label: ', style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.disabledColor),
        const SizedBox(width: 4),
        Text('$label: ', style: theme.textTheme.bodySmall),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
