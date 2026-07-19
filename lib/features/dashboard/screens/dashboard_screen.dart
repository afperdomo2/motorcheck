import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';
import '../widgets/quick_stats.dart';
import '../widgets/recent_activity.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MotorCheck'),
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
