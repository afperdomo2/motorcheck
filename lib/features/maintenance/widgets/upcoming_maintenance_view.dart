import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_chip.dart';
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
        message: 'No se pudo cargar el vehículo',
        onRetry: () => ref.invalidate(selectedVehicleProvider(vehicleId)),
      ),
      data: (vehicle) {
        if (vehicle == null) {
          return const ErrorState(message: 'Vehículo no encontrado');
        }

        return upcomingAsync.when(
          loading: () => const LoadingIndicator(),
          error: (err, _) => ErrorState(
            message: 'No se pudieron calcular los próximos mantenimientos',
            onRetry: () =>
                ref.invalidate(upcomingMaintenanceProvider(vehicleId)),
          ),
          data: (items) {
            final programmed = items.where((item) => item.hasInterval).toList();

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
                    'Configura la frecuencia en kilómetros o meses en las '
                    'categorías de mantenimiento',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Card(child: VehicleFicha(vehicle: vehicle)),
                const SizedBox(height: AppSpacing.lg),
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
    final theme = Theme.of(context);
    final status = !item.hasInterval
        ? AppStatus.neutral
        : item.isOverdue
        ? AppStatus.danger
        : item.isWarning
        ? AppStatus.warning
        : AppStatus.ok;
    final label = item.statusLabel();
    final hasLastMileage = item.lastMileage != null;
    final intervalParts = <String>[
      if (item.category.intervalKm != null) '${item.category.intervalKm} km',
      if (item.category.intervalMonths != null)
        '${item.category.intervalMonths} meses',
    ];
    final warningParts = <String>[
      if (item.category.warningKm != null) '${item.category.warningKm} km',
      if (item.category.warningDays != null)
        '${item.category.warningDays} días',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.category.name,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                StatusChip(status: status, label: label, icon: Icons.schedule),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniInfo(
                  icon: Icons.speed,
                  label: 'Cada',
                  value: intervalParts.isEmpty
                      ? 'Sin frecuencia'
                      : intervalParts.join(' · '),
                ),
                const SizedBox(height: AppSpacing.xs),
                _MiniInfo(
                  icon: Icons.notifications_outlined,
                  label: 'Aviso',
                  value: warningParts.isEmpty
                      ? 'No configurado'
                      : '${warningParts.join(' · ')} antes',
                ),
              ],
            ),
            if (hasLastMileage) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Último: ${formatMileage(item.lastMileage)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (item.nextServiceDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Próximo: ${formatDisplayDate(item.nextServiceDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
