import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.pushReplacement('/maintenance/$maintenanceId/edit'),
            tooltip: 'Editar',
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

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DetailCard(
                    maintenance: maintenance,
                    workshopName: workshop?.name,
                  ),
                  const SizedBox(height: 16),
                  if (items.isNotEmpty) ...[
                    Text(
                      'Items (${items.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) => _ItemTile(item: item)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => context.pushReplacement(
                        '/maintenance/$maintenanceId/edit',
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
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
}

class _DetailCard extends StatelessWidget {
  final Maintenance maintenance;
  final String? workshopName;

  const _DetailCard({required this.maintenance, this.workshopName});

  @override
  Widget build(BuildContext context) {
    final total = maintenance.maintenanceCost + maintenance.totalPartsCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mantenimiento',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Fecha',
              value: formatDate(maintenance.date),
            ),
            if (maintenance.mileage != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.speed,
                label: 'Kilometraje',
                value: formatMileage(maintenance.mileage),
              ),
            ],
            if (workshopName != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.handyman,
                label: 'Taller',
                value: workshopName!,
              ),
            ],
            if (maintenance.maintenanceCost > 0) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.attach_money,
                label: 'Precio',
                value: formatCurrency(maintenance.maintenanceCost),
              ),
            ],
            if (maintenance.totalPartsCost > 0) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'Repuestos: ${formatCurrency(maintenance.totalPartsCost)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            if (total > 0) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.summarize,
                label: 'Total',
                value: formatCurrency(total),
              ),
            ],
            if (maintenance.notes != null && maintenance.notes!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                maintenance.notes!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
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

class _ItemTile extends StatelessWidget {
  final MaintenanceItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(MaintenanceCategories.icon(item.category), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MaintenanceCategories.label(item.category),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Text(
                      item.notes!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (item.partsCost > 0)
              Text(
                formatCurrency(item.partsCost),
                style: Theme.of(context).textTheme.titleSmall,
              ),
          ],
        ),
      ),
    );
  }
}
