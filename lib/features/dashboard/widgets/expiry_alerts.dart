import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';

class ExpiryAlerts extends ConsumerWidget {
  const ExpiryAlerts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    final alerts = _buildAlerts(vehicles);

    if (alerts.isEmpty) return const SizedBox.shrink();

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
                  Icons.shield_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Documentos', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...alerts,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAlerts(List<Vehicle> vehicles) {
    final alertData = <_AlertData>[];

    for (final vehicle in vehicles) {
      if (vehicle.soatExpiresAt != null) {
        final days = _daysUntil(vehicle.soatExpiresAt!);
        if (days < 0 || days <= 30) {
          alertData.add(
            _AlertData(
              icon: Icons.health_and_safety_outlined,
              label: 'SOAT',
              vehicleName: vehicle.name,
              date: vehicle.soatExpiresAt!,
              vehicleId: vehicle.id!,
            ),
          );
        }
      }

      if (vehicle.rtmExpiresAt != null) {
        final days = _daysUntil(vehicle.rtmExpiresAt!);
        if (days < 0 || days <= 30) {
          alertData.add(
            _AlertData(
              icon: Icons.engineering_outlined,
              label: 'Tecnomecánica',
              vehicleName: vehicle.name,
              date: vehicle.rtmExpiresAt!,
              vehicleId: vehicle.id!,
            ),
          );
        }
      }
    }

    alertData.sort((a, b) => _daysUntil(a.date).compareTo(_daysUntil(b.date)));

    return alertData
        .map(
          (data) => _AlertItem(
            icon: data.icon,
            label: data.label,
            vehicleName: data.vehicleName,
            date: data.date,
            vehicleId: data.vehicleId,
          ),
        )
        .toList();
  }

  static int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  static String _daysShort(int days) {
    if (days < 0) return 'Vencido ${-days} d';
    if (days == 0) return 'Vence hoy';
    return 'En $days d';
  }
}

class _AlertData {
  final IconData icon;
  final String label;
  final String vehicleName;
  final DateTime date;
  final int vehicleId;

  const _AlertData({
    required this.icon,
    required this.label,
    required this.vehicleName,
    required this.date,
    required this.vehicleId,
  });
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String vehicleName;
  final DateTime date;
  final int vehicleId;

  const _AlertItem({
    required this.icon,
    required this.label,
    required this.vehicleName,
    required this.date,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = ExpiryAlerts._daysUntil(date);
    final status = days < 0 ? AppStatus.danger : AppStatus.warning;

    return InkWell(
      onTap: () => context.push('/vehicles/$vehicleId'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label · $vehicleName',
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formatDisplayDate(date),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              label: formatDaysRemaining(date),
              excludeSemantics: true,
              child: StatusChip(
                status: status,
                label: ExpiryAlerts._daysShort(days),
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
