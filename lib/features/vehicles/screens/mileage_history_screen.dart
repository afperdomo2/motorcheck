import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../maintenance/providers.dart';
import '../../reminders/providers.dart';
import '../models/mileage_reading.dart';
import '../providers.dart';
import '../widgets/mileage_chart.dart';
import '../widgets/mileage_reading_form_sheet.dart';

class MileageHistoryScreen extends ConsumerWidget {
  const MileageHistoryScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(selectedVehicleProvider(vehicleId));
    final readingsAsync = ref.watch(vehicleMileageReadingsProvider(vehicleId));
    final statsAsync = ref.watch(mileageStatsProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Kilometraje')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MileageReadingFormSheet.show(context, vehicleId),
        icon: const Icon(Icons.add),
        label: const Text('Lectura'),
      ),
      body: vehicleAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudo cargar el vehículo',
          onRetry: () => ref.invalidate(selectedVehicleProvider(vehicleId)),
        ),
        data: (vehicle) {
          if (vehicle == null) {
            return const ErrorState(message: 'Vehículo no encontrado');
          }

          return readingsAsync.when(
            loading: () => const LoadingIndicator(),
            error: (error, _) => ErrorState(
              message: 'No se pudo cargar el historial de kilometraje',
              onRetry: () =>
                  ref.invalidate(vehicleMileageReadingsProvider(vehicleId)),
            ),
            data: (readings) {
              if (readings.isEmpty) {
                return EmptyState(
                  icon: Icons.speed,
                  title: 'Sin lecturas de kilometraje',
                  subtitle: 'Agrega la primera lectura para ver la evolución',
                  onAction: () =>
                      MileageReadingFormSheet.show(context, vehicleId),
                  actionLabel: 'Agregar lectura',
                );
              }

              final stats = statsAsync.valueOrNull;
              final sorted = List<MileageReading>.from(readings)
                ..sort((a, b) => b.date.compareTo(a.date));

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(vehicleMileageReadingsProvider(vehicleId));
                  ref.invalidate(mileageStatsProvider(vehicleId));
                  await ref.read(
                    vehicleMileageReadingsProvider(vehicleId).future,
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl * 2,
                  ),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Wrap(
                          spacing: AppSpacing.xl,
                          runSpacing: AppSpacing.md,
                          children: [
                            _Stat(
                              label: 'Actual',
                              value: formatMileage(vehicle.currentMileage),
                            ),
                            _Stat(
                              label: 'Promedio',
                              value: stats?.averageKmPerDay != null
                                  ? '${stats!.averageKmPerDay!.toStringAsFixed(0)} km/día'
                                  : 'Sin datos',
                            ),
                            _Stat(
                              label: 'Lecturas',
                              value: '${readings.length}',
                            ),
                            _Stat(
                              label: 'Última',
                              value: stats?.lastReadingDate != null
                                  ? formatShortDate(stats!.lastReadingDate!)
                                  : 'Sin datos',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MileageChart(readings: readings),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Lecturas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final reading in sorted)
                      _ReadingTile(
                        reading: reading,
                        onDelete: () => _delete(context, ref, reading),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MileageReading reading,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar lectura',
      message:
          '¿Eliminar la lectura de ${formatMileage(reading.mileage)} del '
          '${formatDisplayDate(reading.date)}?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref.read(mileageRepositoryProvider).delete(reading.id!);
      ref.invalidate(vehicleMileageReadingsProvider(vehicleId));
      ref.invalidate(mileageStatsProvider(vehicleId));
      ref.invalidate(vehiclesProvider);
      ref.invalidate(selectedVehicleProvider(vehicleId));
      ref.invalidate(upcomingMaintenanceProvider);
      ref.invalidate(maintenanceAttentionCountProvider);
      ref.invalidate(vehicleHealthProvider(vehicleId));
      ref.invalidate(remindersProvider);
      if (!context.mounted) return;
      AppSnackBar.success('Lectura eliminada');
    } catch (error) {
      logError('eliminar lectura de km', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo eliminar la lectura'),
      );
    }
  }
}

class _ReadingTile extends StatelessWidget {
  final MileageReading reading;
  final VoidCallback onDelete;

  const _ReadingTile({required this.reading, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final source = switch (reading.source) {
      'fuel' => ('Combustible', Icons.local_gas_station_outlined),
      'maintenance' => ('Mantenimiento', Icons.build_outlined),
      'backfill' => ('Histórico', Icons.history),
      _ => ('Manual', Icons.edit_outlined),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            source.$2,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(formatMileage(reading.mileage)),
        subtitle: Text('${formatDisplayDate(reading.date)} · ${source.$1}'),
        trailing: PopupMenuButton<_ReadingAction>(
          tooltip: 'Opciones',
          onSelected: (action) {
            if (action == _ReadingAction.delete) onDelete();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _ReadingAction.delete,
              child: Text(
                'Eliminar',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum _ReadingAction { delete }
