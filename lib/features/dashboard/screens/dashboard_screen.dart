import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';
import '../widgets/favorite_vehicle_card.dart';
import '../widgets/finance_summary_card.dart';
import '../widgets/pico_y_placa_banner.dart';
import '../widgets/quick_stats.dart';
import '../widgets/recent_activity.dart';
import '../widgets/reminders_summary.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final targetAsync = ref.watch(dashboardVehicleProvider);
    final target = targetAsync.valueOrNull;
    final subtitle = targetAsync.isLoading
        ? 'Cargando…'
        : target == null
        ? 'Agrega tu primer vehículo'
        : [
            target.name,
            if (target.currentMileage != null)
              formatMileage(target.currentMileage),
          ].join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting(DateTime.now().hour)),
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
          message: 'No se pudieron cargar los vehículos',
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
              message: 'No se pudo cargar el resumen',
              onRetry: () => ref.invalidate(dashboardSummaryProvider),
            ),
            data: (summary) {
              return RefreshIndicator(
                onRefresh: () => _refresh(ref),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const PicoYPlacaBanner(),
                    const SizedBox(height: AppSpacing.md),
                    const FavoriteVehicleCard(),
                    const SizedBox(height: AppSpacing.md),
                    const FinanceSummaryCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const RemindersSummary(),
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
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(dashboardVehicleProvider);
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
