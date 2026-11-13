import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/fuel_log.dart';
import '../providers.dart';
import '../repository.dart';
import '../widgets/fuel_card.dart';

class FuelListView extends ConsumerWidget {
  const FuelListView({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(fuelLogsProvider(vehicleId));
    final statsAsync = ref.watch(fuelStatsProvider(vehicleId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(fuelLogsProvider(vehicleId));
        ref.invalidate(fuelStatsProvider(vehicleId));
        await ref.read(fuelLogsProvider(vehicleId).future);
      },
      child: logsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudo cargar el combustible',
          onRetry: () => ref.invalidate(fuelLogsProvider(vehicleId)),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return EmptyState(
              icon: Icons.local_gas_station_outlined,
              title: 'Sin tanqueadas',
              subtitle: 'Registra la primera para calcular el consumo real',
              onAction: () => _openForm(context),
              actionLabel: 'Registrar tanqueada',
            );
          }

          final stats = statsAsync.valueOrNull;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              if (stats != null && stats.hasData) ...[
                _FuelStatsCard(stats: stats),
                const SizedBox(height: AppSpacing.md),
              ],
              for (final log in logs)
                FuelCard(
                  log: log,
                  onTap: () => _openForm(context, log: log),
                  onDelete: () => _delete(context, ref, log),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {FuelLog? log}) {
    if (log == null) {
      context.push('/finance/fuel/add?vehicleId=$vehicleId');
    } else {
      context.push('/finance/fuel/${log.id}/edit');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, FuelLog log) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar tanqueada',
      message: '¿Eliminar el registro del ${formatDisplayDate(log.date)}?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(fuelLogsNotifierProvider.notifier)
          .remove(log.id!, log.vehicleId);
      AppSnackBar.success('Tanqueada eliminada');
    } catch (error) {
      logError('eliminar tanqueada', error, StackTrace.current);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo eliminar la tanqueada',
        ),
      );
    }
  }
}

class _FuelStatsCard extends StatelessWidget {
  final FuelStats stats;

  const _FuelStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_gas_station_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Resumen de combustible',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.md,
              children: [
                _Stat(label: 'Consumo', value: stats.consumptionLabel()),
                _Stat(
                  label: 'Este mes',
                  value: formatCurrency(stats.currentMonthSpent),
                ),
                _Stat(
                  label: 'Costo por km',
                  value: stats.costPerKm != null
                      ? formatCurrency(stats.costPerKm!)
                      : 'Sin datos',
                ),
                _Stat(label: 'Tanqueadas', value: '${stats.count}'),
              ],
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
