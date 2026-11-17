import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/battery_gauge.dart';
import '../../../shared/widgets/budget_status_style.dart';
import '../../../shared/widgets/plate_badge.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../finance/budget_status.dart';
import '../../finance/finance_section.dart';
import '../../finance/providers.dart';
import '../../restrictions/providers.dart';
import '../../restrictions/restriction_status.dart';
import '../../vehicles/providers.dart';

/// Mosaico de baldosas: pico y placa activo y presupuestos en alerta.
/// Mezcla ambos tipos de tile en un mismo `Wrap` y prioriza lo urgente.
class FleetStatusMosaic extends ConsumerWidget {
  const FleetStatusMosaic({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restrictionsAsync = ref.watch(restrictionStatusesProvider);
    final budgetsAsync = ref.watch(budgetStatusesProvider);
    final restrictions = (restrictionsAsync.valueOrNull ?? [])
        .where((entry) => _isActive(entry.status))
        .toList();
    final budgets = (budgetsAsync.valueOrNull ?? [])
        .where((entry) => entry.hasBudget && entry.status != BudgetStatus.ok)
        .toList();

    final tiles =
        <_MosaicTile>[
          for (final entry in restrictions)
            _MosaicTile(
              rank: entry.status.restrictedToday ? 0 : 1,
              name: entry.vehicle.name,
              builder: () => _PlateTile(
                entry: entry,
                onTap: () =>
                    context.push('/vehicles/${entry.vehicle.id}/restriction'),
              ),
            ),
          for (final entry in budgets)
            _MosaicTile(
              rank: entry.status == BudgetStatus.exceeded ? 0 : 1,
              name: entry.vehicle.name,
              builder: () => _BudgetTile(
                entry: entry,
                onTap: () => _openBudget(context, ref, entry),
              ),
            ),
        ]..sort((a, b) {
          final byRank = a.rank.compareTo(b.rank);
          return byRank != 0 ? byRank : a.name.compareTo(b.name);
        });

    if (tiles.isEmpty) {
      if (restrictionsAsync.hasError || budgetsAsync.hasError) {
        return _ErrorCard(
          onRetry: () {
            ref.invalidate(restrictionStatusesProvider);
            ref.invalidate(budgetStatusesProvider);
          },
        );
      }
      return const SizedBox.shrink();
    }

    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    final width = 160 * scale;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final tile in tiles)
            SizedBox(width: width, child: tile.builder()),
        ],
      ),
    );
  }

  Future<void> _openBudget(
    BuildContext context,
    WidgetRef ref,
    BudgetStatusEntry entry,
  ) async {
    final id = entry.vehicle.id;
    if (id != null) {
      try {
        await ref.read(vehiclesNotifierProvider.notifier).selectVehicle(id);
      } catch (error, stackTrace) {
        logError('seleccionar vehículo desde presupuesto', error, stackTrace);
      }
    }
    if (!context.mounted) return;
    ref.read(financeSectionProvider.notifier).state = FinanceSection.summary;
    context.go('/finance');
  }

  bool _isActive(RestrictionStatus status) {
    return status.restrictedToday || status.nextRestrictionDate != null;
  }
}

class _MosaicTile {
  const _MosaicTile({
    required this.rank,
    required this.name,
    required this.builder,
  });

  final int rank;
  final String name;
  final Widget Function() builder;
}

class _PlateTile extends StatelessWidget {
  const _PlateTile({required this.entry, required this.onTap});

  final VehicleRestrictionEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = entry.status;
    final vehicle = entry.vehicle;
    final today = status.restrictedToday;
    final hasNext = status.nextRestrictionDate != null;

    final chipLabel = today
        ? 'No circula hoy'
        : hasNext
        ? 'Hoy circulas'
        : 'Sin restricción';
    final detail = today
        ? _timeRange(status)
        : hasNext
        ? 'Próx. ${status.nextLabel}'
        : status.todayLabel;

    return Semantics(
      button: true,
      label: 'Pico y placa de ${vehicle.name}: $chipLabel',
      child: _TileSurface(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlateBadge(plate: vehicle.plate),
            const SizedBox(height: AppSpacing.sm),
            Text(
              vehicle.name,
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            StatusChip(
              status: AppStatus.info,
              label: chipLabel,
              icon: today
                  ? Icons.do_not_disturb_on_outlined
                  : Icons.directions_car_outlined,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _timeRange(RestrictionStatus status) {
    final parts = status.todayLabel.split(' · ');
    return parts.length > 1 ? parts.last : status.todayLabel;
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.entry, required this.onTap});

  final BudgetStatusEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = budgetColor(context, entry.status);

    return Semantics(
      button: true,
      label:
          'Presupuesto de ${entry.vehicle.name}: ${entry.percent} por ciento',
      child: _TileSurface(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                VehicleAvatar(type: entry.vehicle.type, size: 28),
                const SizedBox(width: AppSpacing.xs + 2),
                Expanded(
                  child: Text(
                    entry.vehicle.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            StatusChip(
              status: budgetAppStatus(entry.status),
              label: '${entry.percent} %',
              icon: Icons.savings_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            BatteryGauge(ratio: entry.ratio.clamp(0.0, 1.0), color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${formatCompactCurrency(entry.spent)} / '
              '${formatCompactCurrency(entry.amount)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TileSurface extends StatelessWidget {
  const _TileSurface({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'No se pudo cargar el estado de la flota',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}
