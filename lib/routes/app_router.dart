import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/vehicles/screens/vehicles_screen.dart';
import '../features/vehicles/screens/vehicle_form_screen.dart';
import '../features/vehicles/providers.dart';
import '../features/maintenance/screens/maintenance_list_screen.dart';
import '../features/maintenance/screens/maintenance_form_screen.dart';
import '../features/maintenance/screens/maintenance_detail_screen.dart';
import '../shared/widgets/vehicle_selector_sheet.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/maintenance',
              builder: (context, state) => const MaintenanceListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) {
                    final vehicleId =
                        int.tryParse(state.uri.queryParameters['vehicleId'] ?? '');
                    return MaintenanceFormScreen(vehicleId: vehicleId);
                  },
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return MaintenanceDetailScreen(maintenanceId: id);
                  },
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) {
                    final id = int.tryParse(
                      state.pathParameters['id'] ?? '',
                    );
                    return MaintenanceFormScreen(maintenanceId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vehicles',
              builder: (context, state) => const VehiclesScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const VehicleFormScreen(),
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) {
                    final id = int.tryParse(
                      state.pathParameters['id'] ?? '',
                    );
                    return VehicleFormScreen(vehicleId: id);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMaintenance(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Mantenimiento'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Mantenimientos',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Vehículos',
          ),
        ],
      ),
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
