import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';

class UpcomingSummary extends ConsumerWidget {
  const UpcomingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(dashboardUpcomingProvider).valueOrNull ?? [];
    if (entries.isEmpty) return const SizedBox.shrink();

    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    final defaultVehicle = ref.watch(defaultVehicleProvider).valueOrNull;
    final target =
        defaultVehicle ?? (vehicles.isNotEmpty ? vehicles.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Próximos por kilometraje',
          icon: Icons.speed,
          actionLabel: target?.id != null ? 'Ver todo' : null,
          onAction: target?.id == null
              ? null
              : () => context.push('/vehicles/${target!.id}/upcoming'),
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0) const Divider(),
                _UpcomingRow(entry: entries[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final DashboardUpcomingEntry entry;

  const _UpcomingRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entry.item;
    final status = item.isOverdue
        ? AppStatus.danger
        : item.isWarning
        ? AppStatus.warning
        : AppStatus.neutral;

    return InkWell(
      onTap: () => context.push('/vehicles/${entry.vehicle.id}/upcoming'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.name,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    entry.vehicle.name,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusChip(
              status: status,
              label: item.statusLabel(),
              icon: item.isOverdue ? Icons.priority_high : Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }
}
