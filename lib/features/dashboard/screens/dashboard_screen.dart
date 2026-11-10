import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';
import '../widgets/expiry_alerts.dart';
import '../widgets/favorite_vehicle_card.dart';
import '../widgets/quick_stats.dart';
import '../widgets/recent_activity.dart';
import '../widgets/upcoming_summary.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(DateTime.now().hour)),
            Text(
              'Tu vehículo al día',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: _buildFab(context, ref),
      body: vehiclesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(vehiclesProvider),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car,
              title: 'Bienvenido a MotorCheck',
              subtitle: 'Agrega tu primer vehículo para comenzar',
              onAction: () => context.push('/vehicles/add'),
              actionLabel: 'Agregar vehículo',
            );
          }

          return summaryAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, _) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(dashboardSummaryProvider),
            ),
            data: (summary) {
              return RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    const FavoriteVehicleCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const UpcomingSummary(),
                    const SizedBox(height: AppSpacing.lg),
                    const ExpiryAlerts(),
                    const SizedBox(height: AppSpacing.lg),
                    QuickStats(summary: summary),
                    const SizedBox(height: AppSpacing.lg),
                    RecentActivity(summary: summary),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(vehiclesProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dashboardUpcomingProvider);
    await ref.read(dashboardSummaryProvider.future);
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    if (vehicles.isEmpty) return null;

    return FloatingActionButton.extended(
      onPressed: () => _addMaintenance(context, ref),
      tooltip: 'Registrar mantenimiento',
      icon: const Icon(Icons.add),
      label: const Text('Registrar'),
    );
  }

  Future<void> _addMaintenance(BuildContext context, WidgetRef ref) async {
    final vehicles = ref.read(vehiclesProvider).valueOrNull ?? [];
    if (vehicles.isEmpty) return;

    if (vehicles.length == 1) {
      if (context.mounted) {
        context.push('/maintenance/add?vehicleId=${vehicles.first.id}');
      }
      return;
    }

    final selected = await VehicleSelectorSheet.show(context);
    if (selected != null && context.mounted) {
      context.push('/maintenance/add?vehicleId=${selected.id}');
    }
  }

  static String _greeting(int hour) {
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }
}
