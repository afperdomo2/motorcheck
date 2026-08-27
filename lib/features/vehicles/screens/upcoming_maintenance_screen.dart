import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers.dart';
import '../../maintenance/providers.dart';

class UpcomingMaintenanceScreen extends ConsumerWidget {
  final int vehicleId;

  const UpcomingMaintenanceScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingMaintenanceProvider(vehicleId));
    final vehicleAsync = ref.watch(selectedVehicleProvider(vehicleId));
    final mileage = vehicleAsync.valueOrNull?.currentMileage;

    return Scaffold(
      appBar: AppBar(title: const Text('Próximos mantenimientos')),
      body: upcomingAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(upcomingMaintenanceProvider(vehicleId)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.schedule,
              title: 'Sin próximos mantenimientos',
              subtitle:
                  'Configura la frecuencia en kilómetros en las '
                  'categorías de mantenimiento',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (mileage != null)
                Card(
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
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (mileage == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Registra el kilometraje actual del '
                            'vehículo para calcular los próximos mantenimientos',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ...items.map((item) => _UpcomingCategoryCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _UpcomingCategoryCard extends StatelessWidget {
  final UpcomingMaintenance item;

  const _UpcomingCategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.statusColor();
    final label = item.statusLabel();
    final hasInterval = item.category.intervalKm != null;
    final hasLastMileage = item.lastMileage != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.category.name,
                    style: Theme.of(context).textTheme.titleSmall,
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
            if (hasInterval) ...[
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  _MiniInfo(
                    icon: Icons.speed,
                    label: 'Cada',
                    value: '${item.category.intervalKm} km',
                  ),
                  const SizedBox(width: 16),
                  _MiniInfo(
                    icon: Icons.notifications_outlined,
                    label: 'Aviso',
                    value: item.category.warningKm != null
                        ? '${item.category.warningKm} km antes'
                        : 'No configurado',
                  ),
                ],
              ),
              if (hasLastMileage) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 14,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Último: ${formatMileage(item.lastMileage)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).disabledColor),
        const SizedBox(width: 4),
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
