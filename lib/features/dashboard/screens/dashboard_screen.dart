import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../providers.dart';
import '../widgets/quick_stats.dart';
import '../widgets/recent_activity.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedVehicleIdProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MotorCheck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: () => context.go('/vehicles'),
            tooltip: 'Cambiar vehículo',
          ),
        ],
      ),
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

          final isValid = selectedId != null &&
              vehicles.any((v) => v.id == selectedId);

          if (!isValid) {
            final defaultVehicle = _findDefault(vehicles);
            final id = defaultVehicle?.id ?? vehicles.first.id;

            Future.microtask(() {
              if (context.mounted) {
                ref
                    .read(selectedVehicleIdProvider.notifier)
                    .state = id;
              }
            });

            return const LoadingIndicator(message: 'Cargando...');
          }

          return const _DashboardContent();
        },
      ),
    );
  }

  Vehicle? _findDefault(List<Vehicle> vehicles) {
    for (final v in vehicles) {
      if (v.isDefault) return v;
    }
    return null;
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return summaryAsync.when(
      loading: () => const LoadingIndicator(),
      error: (err, _) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(dashboardSummaryProvider),
      ),
      data: (summary) {
        if (summary == null) {
          return const EmptyState(icon: Icons.error, title: 'Sin datos');
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            return ref.read(dashboardSummaryProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              QuickStats(summary: summary),
              const SizedBox(height: 16),
              RecentActivity(summary: summary),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/maintenance/add'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo mantenimiento'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
