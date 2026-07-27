import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';

class ExpiryAlerts extends ConsumerWidget {
  const ExpiryAlerts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    final alerts = _buildAlerts(vehicles);

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Documentos por vencer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts,
          ],
        ),
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
    final color = expiryColor(date);
    final daysText = formatDaysRemaining(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context.push('/vehicles/$vehicleId'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label - $vehicleName',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      formatDisplayDate(date),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
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
            ],
          ),
        ),
      ),
    );
  }
}
