import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/quick_add_fab.dart';
import '../../finance/providers.dart';
import '../../maintenance/providers.dart';
import '../../reminders/providers.dart';
import '../../restrictions/providers.dart';
import '../../vehicles/current_vehicle_provider.dart';
import '../../vehicles/providers.dart';
import '../widgets/attention_section.dart';
import '../widgets/fleet_spend_card.dart';
import '../widgets/fleet_status_mosaic.dart';
import '../widgets/vehicle_carousel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_greeting(DateTime.now().hour))),
      floatingActionButton: const QuickAddFab(),
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

          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxxl * 2,
              ),
              children: const [
                VehicleCarousel(),
                FleetStatusMosaic(),
                FleetSpendCard(),
                AttentionSection(),
                SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(currentVehicleProvider);
    ref.invalidate(remindersProvider);
    ref.invalidate(restrictionStatusesProvider);
    ref.invalidate(maintenancesProvider);
    ref.invalidate(budgetStatusesProvider);
    ref.invalidate(fleetMonthBreakdownProvider);
    ref.invalidate(fleetMonthSpendProvider);

    final id = ref.read(currentVehicleProvider).valueOrNull?.id;
    if (id != null) {
      ref.invalidate(vehicleFinanceProvider(id));
      ref.invalidate(vehicleMonthBreakdownProvider(id));
      ref.invalidate(vehicleMonthSpendProvider(id));
      ref.invalidate(budgetForVehicleProvider(id));
      ref.invalidate(vehicleHealthProvider(id));
      ref.invalidate(upcomingMaintenanceProvider(id));
    }

    try {
      await ref.read(currentVehicleProvider.future);
    } catch (_) {
      // Las secciones muestran su propio estado de error.
    }
  }

  static String _greeting(int hour) {
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }
}
