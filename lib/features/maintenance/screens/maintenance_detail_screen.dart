import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';
import '../providers.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final int maintenanceId;

  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(maintenanceByIdProvider(maintenanceId));
    final itemsAsync = ref.watch(maintenanceItemsProvider(maintenanceId));

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
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DetailCard(maintenance: maintenance),
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
}

class _DetailCard extends StatelessWidget {
  final Maintenance maintenance;

  const _DetailCard({required this.maintenance});

  @override
  Widget build(BuildContext context) {
    final total = maintenance.totalLaborCost + maintenance.totalPartsCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              maintenance.title,
              style: Theme.of(context).textTheme.headlineMedium,
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
            if (total > 0) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.payments,
                label: 'Costo total',
                value: formatCurrency(total),
              ),
            ],
            if (maintenance.totalLaborCost > 0) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'Mano de obra: ${formatCurrency(maintenance.totalLaborCost)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            if (maintenance.totalPartsCost > 0) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'Repuestos: ${formatCurrency(maintenance.totalPartsCost)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final MaintenanceItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final itemTotal = item.laborCost + item.partsCost;

    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: itemTotal > 0
            ? Text('Total: ${formatCurrency(itemTotal)}')
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (item.laborCost > 0)
              Text(
                'MO: ${formatCurrency(item.laborCost)}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            if (item.partsCost > 0)
              Text(
                'Rep: ${formatCurrency(item.partsCost)}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
      ),
    );
  }
}
