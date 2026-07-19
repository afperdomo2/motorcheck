import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/vehicles/screens/vehicles_screen.dart';
import '../features/vehicles/screens/vehicle_form_screen.dart';
import '../features/maintenance/screens/maintenance_list_screen.dart';
import '../features/maintenance/screens/maintenance_form_screen.dart';
import '../features/maintenance/screens/maintenance_detail_screen.dart';
import '../features/maintenance/screens/maintenance_search_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/workshops_screen.dart';
import '../features/settings/screens/workshop_form_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
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
                    final vehicleId = int.tryParse(
                      state.uri.queryParameters['vehicleId'] ?? '',
                    );
                    return MaintenanceFormScreen(vehicleId: vehicleId);
                  },
                ),
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const MaintenanceSearchScreen(),
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
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
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
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    return VehicleFormScreen(vehicleId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'workshops',
                  builder: (context, state) => const WorkshopsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const WorkshopFormScreen(),
                    ),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) {
                        final id = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        return WorkshopFormScreen(workshopId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
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
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}
