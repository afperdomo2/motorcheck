import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../maintenance/providers.dart';
import '../models/vehicle.dart';
import '../providers.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  static IconData _typeIcon(String type) => switch (type) {
    'car' => Icons.directions_car,
    'motorcycle' => Icons.motorcycle,
    'bike' => Icons.pedal_bike,
    'truck' => Icons.local_shipping,
    _ => Icons.help_outline,
  };

  static String _typeLabel(String type) => switch (type) {
    'car' => 'Carro',
    'motorcycle' => 'Moto',
    'bike' => 'Bicicleta',
    'truck' => 'Camión',
    _ => 'Otro',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(selectedVehicleProvider(vehicleId));
    final summaryAsync = ref.watch(
      vehicleMaintenanceSummaryProvider(vehicleId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.pushReplacement('/vehicles/$vehicleId/edit'),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteVehicle(context, ref),
            tooltip: 'Eliminar',
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

          final typeColor = AppColors.forVehicleType(vehicle.type);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _VehicleHeader(vehicle: vehicle, typeColor: typeColor),
              const SizedBox(height: 16),
              _InfoCard(vehicle: vehicle),
              const SizedBox(height: 16),
              summaryAsync.when(
                loading: () => const LoadingIndicator(),
                error: (err, _) => const SizedBox.shrink(),
                data: (summary) => _MaintenanceSummaryCard(summary: summary),
              ),
              const SizedBox(height: 16),
              _MetadataCard(vehicle: vehicle),
            ],
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
      context.pop();
    }
  }
}

class _VehicleHeader extends StatelessWidget {
  final Vehicle vehicle;
  final Color typeColor;

  const _VehicleHeader({required this.vehicle, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: typeColor.withValues(alpha: 0.15),
          child: Icon(
            VehicleDetailScreen._typeIcon(vehicle.type),
            size: 40,
            color: typeColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                vehicle.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            if (vehicle.isDefault) ...[
              const SizedBox(width: 6),
              Icon(Icons.star, color: Colors.amber[600], size: 22),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            VehicleDetailScreen._typeLabel(vehicle.type),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: typeColor),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).disabledColor),
          const SizedBox(width: 8),
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
          Flexible(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
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
    final color = expiryColor(date);
    final daysText = formatDaysRemaining(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).disabledColor),
              const SizedBox(width: 8),
              Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
              Flexible(
                child: Text(
                  formatDisplayDate(date),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                daysText,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceSummaryCard extends StatelessWidget {
  final ({int count, double totalCost, DateTime? lastDate}) summary;

  const _MaintenanceSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.count == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.build_outlined,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 12),
              const Text('Sin mantenimientos registrados'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mantenimientos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
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
        padding: const EdgeInsets.all(16),
        child: _InfoRow(
          icon: Icons.date_range_outlined,
          label: 'Creado',
          value: formatDisplayDate(vehicle.createdAt),
        ),
      ),
    );
  }
}
