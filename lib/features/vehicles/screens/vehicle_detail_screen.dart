import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../maintenance/providers.dart';
import '../models/vehicle.dart';
import '../providers.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(selectedVehicleProvider(vehicleId));
    final summaryAsync = ref.watch(
      vehicleMaintenanceSummaryProvider(vehicleId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículo'),
        actions: [
          PopupMenuButton<_VehicleAction>(
            tooltip: 'Opciones',
            onSelected: (action) {
              switch (action) {
                case _VehicleAction.edit:
                  context.pushReplacement('/vehicles/$vehicleId/edit');
                case _VehicleAction.delete:
                  _deleteVehicle(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _VehicleAction.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: AppSpacing.md),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _VehicleAction.delete,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: vehicleAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(selectedVehicleProvider(vehicleId)),
        ),
        data: (vehicle) {
          if (vehicle == null) {
            return const ErrorState(message: 'Vehículo no encontrado');
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(selectedVehicleProvider(vehicleId));
              ref.invalidate(vehicleMaintenanceSummaryProvider(vehicleId));
              ref.invalidate(upcomingMaintenanceProvider(vehicleId));
              await Future.wait([
                ref.read(selectedVehicleProvider(vehicleId).future),
                ref.read(vehicleMaintenanceSummaryProvider(vehicleId).future),
                ref.read(upcomingMaintenanceProvider(vehicleId).future),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _VehicleHeader(vehicle: vehicle),
                const SizedBox(height: AppSpacing.lg),
                _InfoCard(vehicle: vehicle),
                const SizedBox(height: AppSpacing.lg),
                summaryAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (err, _) => const SizedBox.shrink(),
                  data: (summary) => _MaintenanceSummaryCard(
                    summary: summary,
                    vehicleId: vehicleId,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _MetadataCard(vehicle: vehicle),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteVehicle(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar vehículo',
      message:
          '¿Estás seguro de eliminar este vehículo? '
          'Se perderán todos sus mantenimientos.',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      ref.read(vehiclesNotifierProvider.notifier).remove(vehicleId);
      AppSnackBar.success('Vehículo eliminado');
      context.pop();
    }
  }
}

enum _VehicleAction { edit, delete }

class _VehicleHeader extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleHeader({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final typeColor = semantic.vehicleColor(vehicle.type);

    return Column(
      children: [
        VehicleAvatar(type: vehicle.type, size: 88),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                vehicle.name,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            if (vehicle.isDefault) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.star, color: theme.colorScheme.primary, size: 22),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(vehicleTypeIcon(vehicle.type), size: 14, color: typeColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                vehicleTypeLabel(vehicle.type),
                style: theme.textTheme.labelMedium?.copyWith(color: typeColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Vehicle vehicle;

  const _InfoCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            if (vehicle.brand != null)
              _InfoRow(
                icon: Icons.factory_outlined,
                label: 'Marca',
                value: vehicle.brand!,
              ),
            if (vehicle.model != null)
              _InfoRow(
                icon: Icons.info_outline,
                label: 'Modelo',
                value: vehicle.model!,
              ),
            if (vehicle.year != null)
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Año',
                value: vehicle.year.toString(),
              ),
            if (vehicle.plate != null)
              _InfoRow(
                icon: Icons.pin_outlined,
                label: 'Placa',
                value: vehicle.plate!,
              ),
            if (vehicle.color != null)
              _InfoRow(
                icon: Icons.palette_outlined,
                label: 'Color',
                value: vehicle.color!,
              ),
            if (vehicle.currentMileage != null)
              _InfoRow(
                icon: Icons.speed,
                label: 'Kilometraje',
                value: formatMileage(vehicle.currentMileage),
              ),
            if (vehicle.vin != null)
              _InfoRow(icon: Icons.numbers, label: 'VIN', value: vehicle.vin!),
            if (vehicle.soatExpiresAt != null)
              _ExpiryRow(
                icon: Icons.health_and_safety_outlined,
                label: 'SOAT',
                date: vehicle.soatExpiresAt!,
              ),
            if (vehicle.rtmExpiresAt != null)
              _ExpiryRow(
                icon: Icons.engineering_outlined,
                label: 'Tecnomecánica',
                date: vehicle.rtmExpiresAt!,
              ),
            if (vehicle.brand == null &&
                vehicle.model == null &&
                vehicle.year == null &&
                vehicle.plate == null &&
                vehicle.color == null &&
                vehicle.vin == null &&
                vehicle.soatExpiresAt == null &&
                vehicle.rtmExpiresAt == null &&
                vehicle.currentMileage == null)
              const EmptyState(
                icon: Icons.info_outline,
                title: 'Sin información adicional',
                subtitle: 'Edita el vehículo para agregar más detalles',
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ', style: theme.textTheme.bodyMedium),
          Flexible(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime date;

  const _ExpiryRow({
    required this.icon,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _daysUntil(date);
    final status = days < 0
        ? AppStatus.danger
        : days <= 30
        ? AppStatus.warning
        : AppStatus.ok;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text('$label: ', style: theme.textTheme.bodyMedium),
              Flexible(
                child: Text(
                  formatDisplayDate(date),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg + AppSpacing.md,
              top: AppSpacing.xs,
            ),
            child: StatusChip(
              status: status,
              label: _daysLabel(days),
              icon: Icons.schedule,
            ),
          ),
        ],
      ),
    );
  }

  static int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  static String _daysLabel(int days) {
    if (days < 0) return 'Vencido hace ${-days} días';
    if (days == 0) return 'Vence hoy';
    return 'Vence en $days días';
  }
}

class _MaintenanceSummaryCard extends StatelessWidget {
  final ({int count, double totalCost, DateTime? lastDate}) summary;
  final int vehicleId;

  const _MaintenanceSummaryCard({
    required this.summary,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.count == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.build_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Text('Sin mantenimientos registrados'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      context.push('/vehicles/$vehicleId/upcoming'),
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Próximos mantenimientos'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mantenimientos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (summary.lastDate != null)
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Último',
                value: formatDisplayDate(summary.lastDate!),
              ),
            _InfoRow(
              icon: Icons.receipt_long,
              label: 'Total registros',
              value: summary.count.toString(),
            ),
            if (summary.totalCost > 0)
              _InfoRow(
                icon: Icons.attach_money,
                label: 'Total gastado',
                value: formatCurrency(summary.totalCost),
              ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push('/vehicles/$vehicleId/upcoming'),
                icon: const Icon(Icons.schedule, size: 16),
                label: const Text('Próximos mantenimientos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  final Vehicle vehicle;

  const _MetadataCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _InfoRow(
          icon: Icons.date_range_outlined,
          label: 'Creado',
          value: formatDisplayDate(vehicle.createdAt),
        ),
      ),
    );
  }
}
