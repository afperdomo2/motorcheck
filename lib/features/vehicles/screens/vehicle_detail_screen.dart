import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_status.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../checklists/providers.dart';
import '../../documents/models/vehicle_document.dart';
import '../../documents/providers.dart';
import '../../maintenance/providers.dart';
import '../../reminders/health_score.dart';
import '../../reminders/providers.dart';
import '../../restrictions/providers.dart';
import '../../restrictions/restriction_status.dart';
import '../models/vehicle.dart';
import '../providers.dart';
import '../widgets/mileage_update_sheet.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final int vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(selectedVehicleProvider(vehicleId));
    final summaryAsync = ref.watch(
      vehicleMaintenanceSummaryProvider(vehicleId),
    );
    final documentsAsync = ref.watch(
      vehicleCurrentDocumentsProvider(vehicleId),
    );
    final restrictionAsync = ref.watch(
      vehicleRestrictionStatusProvider(vehicleId),
    );
    final healthAsync = ref.watch(vehicleHealthProvider(vehicleId));

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
          message: 'No se pudo cargar el vehículo',
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
              ref.invalidate(vehicleDocumentsProvider(vehicleId));
              ref.invalidate(vehicleCurrentDocumentsProvider(vehicleId));
              ref.invalidate(vehicleRestrictionStatusProvider(vehicleId));
              ref.invalidate(vehicleHealthProvider(vehicleId));
              await Future.wait([
                ref.read(selectedVehicleProvider(vehicleId).future),
                ref.read(vehicleMaintenanceSummaryProvider(vehicleId).future),
                ref.read(upcomingMaintenanceProvider(vehicleId).future),
                ref.read(vehicleDocumentsProvider(vehicleId).future),
                ref.read(vehicleCurrentDocumentsProvider(vehicleId).future),
                ref.read(vehicleRestrictionStatusProvider(vehicleId).future),
                ref.read(vehicleHealthProvider(vehicleId).future),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _VehicleHeader(
                  vehicle: vehicle,
                  onUpdateMileage: () =>
                      MileageUpdateSheet.show(context, vehicle),
                ),
                const SizedBox(height: AppSpacing.lg),
                _HealthCard(healthAsync: healthAsync),
                const SizedBox(height: AppSpacing.sm),
                _InfoCard(vehicle: vehicle),
                const SizedBox(height: AppSpacing.lg),
                _DocumentsCard(
                  documentsAsync: documentsAsync,
                  vehicleId: vehicleId,
                ),
                const SizedBox(height: AppSpacing.lg),
                _RestrictionCard(
                  restrictionAsync: restrictionAsync,
                  vehicleId: vehicleId,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChecklistsCard(vehicleId: vehicleId),
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
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(vehiclesNotifierProvider.notifier).remove(vehicleId);
      if (context.mounted) {
        AppSnackBar.success('Vehículo eliminado');
        context.pop();
      }
    } catch (error) {
      logError('eliminar vehículo', error, StackTrace.current);
      if (context.mounted) {
        AppSnackBar.error(
          friendlyErrorMessage(
            error,
            fallback: 'No se pudo eliminar el vehículo',
          ),
        );
      }
    }
  }
}

enum _VehicleAction { edit, delete }

class _VehicleHeader extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onUpdateMileage;

  const _VehicleHeader({required this.vehicle, required this.onUpdateMileage});

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
        if (vehicle.currentMileage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatMileage(vehicle.currentMileage),
            style: theme.textTheme.titleSmall,
          ),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            TextButton.icon(
              onPressed: onUpdateMileage,
              icon: const Icon(Icons.speed, size: 18),
              label: const Text('Actualizar km'),
            ),
            TextButton.icon(
              onPressed: () => context.push('/vehicles/${vehicle.id}/mileage'),
              icon: const Icon(Icons.show_chart, size: 18),
              label: const Text('Historial'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  final AsyncValue<HealthScore> healthAsync;

  const _HealthCard({required this.healthAsync});

  @override
  Widget build(BuildContext context) {
    final health = healthAsync.valueOrNull;
    if (health == null) return const SizedBox.shrink();

    final status = health.value >= 90
        ? AppStatus.ok
        : health.value >= 70
        ? AppStatus.warning
        : AppStatus.danger;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.favorite_border,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salud del vehículo',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    health.reasons.join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            StatusChip(
              status: status,
              label: '${health.value}/100',
              icon: Icons.speed,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  final AsyncValue<List<VehicleDocument>> documentsAsync;
  final int vehicleId;

  const _DocumentsCard({required this.documentsAsync, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final documents = documentsAsync.valueOrNull ?? [];
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Documentos', style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () =>
                      context.push('/vehicles/$vehicleId/documents'),
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            if (documents.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Sin documentos registrados',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push('/vehicles/$vehicleId/documents/add'),
                      child: const Text('Agregar'),
                    ),
                  ],
                ),
              )
            else
              ...documents.map((document) => _DocumentRow(document: document)),
          ],
        ),
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final VehicleDocument document;

  const _DocumentRow({required this.document});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = documentTypeFor(document.type);
    final status = dateStatus(document.expiresAt);
    final appStatus = switch (status.level) {
      ExpiryLevel.danger => AppStatus.danger,
      ExpiryLevel.warning => AppStatus.warning,
      ExpiryLevel.ok => AppStatus.ok,
    };

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(type.icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name ?? type.label,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  formatDisplayDate(document.expiresAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          StatusChip(
            status: appStatus,
            label: status.shortLabel,
            icon: Icons.schedule,
          ),
        ],
      ),
    );
  }
}

class _RestrictionCard extends StatelessWidget {
  final AsyncValue<RestrictionStatus> restrictionAsync;
  final int vehicleId;

  const _RestrictionCard({
    required this.restrictionAsync,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    final status = restrictionAsync.valueOrNull;
    if (status == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              status.restrictedToday
                  ? Icons.do_not_disturb_on_outlined
                  : Icons.directions_car_outlined,
              color: status.restrictedToday
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pico y placa', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    status.configured
                        ? '${status.todayLabel}\n${status.nextLabel}'
                        : 'Sin configurar',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/vehicles/$vehicleId/restriction'),
              child: Text(status.configured ? 'Editar' : 'Configurar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistsCard extends ConsumerWidget {
  final int vehicleId;

  const _ChecklistsCard({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(inspectionRunsProvider(vehicleId));
    final theme = Theme.of(context);
    final lastRun = runsAsync.valueOrNull?.isNotEmpty == true
        ? runsAsync.valueOrNull!.first
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.fact_check_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspecciones', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    lastRun == null
                        ? 'Sin inspecciones registradas'
                        : 'Última: ${formatDisplayDate(lastRun.date)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/vehicles/$vehicleId/checklists'),
              child: const Text('Abrir'),
            ),
          ],
        ),
      ),
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
            if (vehicle.brand == null &&
                vehicle.model == null &&
                vehicle.year == null &&
                vehicle.plate == null &&
                vehicle.color == null &&
                vehicle.vin == null &&
                vehicle.currentMileage == null)
              const EmptyState(
                compact: true,
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
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/vehicles/$vehicleId/report'),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: const Text('Hoja de vida'),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/vehicles/$vehicleId/upcoming'),
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('Próximos'),
                    ),
                  ],
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
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.sm,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/vehicles/$vehicleId/report'),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text('Hoja de vida'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/vehicles/$vehicleId/upcoming'),
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Próximos'),
                  ),
                ],
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
