import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';
import '../widgets/favorite_vehicle_card.dart';
import '../widgets/quick_stats.dart';
import '../widgets/expiry_alerts.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MotorCheck')),
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
                onRefresh: () async {
                  ref.invalidate(dashboardSummaryProvider);
                  return ref.read(dashboardSummaryProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const FavoriteVehicleCard(),
                    QuickStats(summary: summary),
                    const ExpiryAlerts(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    if (vehicles.isEmpty) return null;

    return FloatingActionButton(
      onPressed: () => _addMaintenance(context, ref),
      tooltip: 'Agregar mantenimiento',
      child: const Icon(Icons.build),
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
}
