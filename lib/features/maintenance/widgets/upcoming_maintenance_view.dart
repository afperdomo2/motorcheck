import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';
import 'vehicle_ficha.dart';

class UpcomingMaintenanceView extends ConsumerWidget {
  final int vehicleId;

  const UpcomingMaintenanceView({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(selectedVehicleProvider(vehicleId));
    final upcomingAsync = ref.watch(upcomingMaintenanceProvider(vehicleId));

    return vehicleAsync.when(
      loading: () => const LoadingIndicator(),
      error: (err, _) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(selectedVehicleProvider(vehicleId)),
      ),
      data: (vehicle) {
        if (vehicle == null) {
          return const ErrorState(message: 'Vehículo no encontrado');
        }

        return upcomingAsync.when(
          loading: () => const LoadingIndicator(),
          error: (err, _) => ErrorState(
            message: err.toString(),
            onRetry: () =>
                ref.invalidate(upcomingMaintenanceProvider(vehicleId)),
          ),
          data: (items) {
            final programmed = items
                .where((item) => item.category.intervalKm != null)
                .toList();

            if (programmed.isEmpty) {
              if (vehicle.currentMileage == null) {
                return const EmptyState(
                  icon: Icons.speed,
                  title: 'Sin kilometraje registrado',
                  subtitle:
                      'Registra el kilometraje actual del vehículo para '
                      'calcular los próximos mantenimientos',
                );
              }
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
                Card(child: VehicleFicha(vehicle: vehicle)),
                const SizedBox(height: 16),
                ...programmed.map((item) => _UpcomingCategoryCard(item: item)),
              ],
            );
          },
        );
      },
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
