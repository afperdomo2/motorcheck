import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/notifications/notification_sync.dart';
import '../features/reminders/providers.dart';
import '../features/vehicles/providers.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/vehicles/screens/vehicles_screen.dart';
import '../features/vehicles/screens/vehicle_detail_screen.dart';
import '../features/vehicles/screens/vehicle_form_screen.dart';
import '../features/vehicles/screens/upcoming_maintenance_screen.dart';
import '../features/maintenance/screens/maintenance_list_screen.dart';
import '../features/maintenance/screens/maintenance_form_screen.dart';
import '../features/maintenance/screens/maintenance_detail_screen.dart';
import '../features/maintenance/screens/maintenance_search_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/workshops_screen.dart';
import '../features/settings/screens/workshop_form_screen.dart';
import '../features/settings/screens/categories_screen.dart';
import '../features/settings/screens/category_form_screen.dart';
import '../features/settings/screens/data_backup_screen.dart';
import '../features/settings/screens/notification_settings_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/documents/screens/document_form_screen.dart';
import '../features/restrictions/screens/pico_y_placa_screen.dart';
import '../features/reminders/screens/reminders_screen.dart';
import '../features/reports/screens/vehicle_report_screen.dart';

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
                  path: ':id',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return VehicleDetailScreen(vehicleId: id);
                  },
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    return VehicleFormScreen(vehicleId: id);
                  },
                ),
                GoRoute(
                  path: ':id/upcoming',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return UpcomingMaintenanceScreen(vehicleId: id);
                  },
                ),
                GoRoute(
                  path: ':id/documents',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return DocumentsScreen(vehicleId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return DocumentFormScreen(vehicleId: id);
                      },
                    ),
                    GoRoute(
                      path: ':documentId/edit',
                      builder: (context, state) {
                        final vehicleId = int.parse(
                          state.pathParameters['id']!,
                        );
                        final documentId = int.tryParse(
                          state.pathParameters['documentId'] ?? '',
                        );
                        return DocumentFormScreen(
                          vehicleId: vehicleId,
                          documentId: documentId,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: ':id/restriction',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return PicoYPlacaScreen(vehicleId: id);
                  },
                ),
                GoRoute(
                  path: ':id/report',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return VehicleReportScreen(vehicleId: id);
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
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const CategoriesScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) {
                        final type = state.uri.queryParameters['type'] ?? 'car';
                        return CategoryFormScreen(vehicleType: type);
                      },
                    ),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) {
                        final id = int.tryParse(
                          state.pathParameters['id'] ?? '',
                        );
                        return CategoryFormScreen(categoryId: id);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'backup',
                  builder: (context, state) => const DataBackupScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) =>
                      const NotificationSettingsScreen(),
                ),
                GoRoute(
                  path: 'documents',
                  builder: (context, state) => const DocumentsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const DocumentFormScreen(),
                    ),
                    GoRoute(
                      path: ':documentId/edit',
                      builder: (context, state) {
                        final documentId = int.tryParse(
                          state.pathParameters['documentId'] ?? '',
                        );
                        return DocumentFormScreen(documentId: documentId);
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
    GoRoute(
      path: '/reminders',
      builder: (context, state) => const RemindersScreen(),
    ),
  ],
);

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Inicializa la selección de vehículo al arrancar, sin depender de que el
    // usuario visite la pestaña de vehículos.
    ref.watch(vehiclesNotifierProvider);
    final attentionCount =
        ref.watch(remindersAttentionCountProvider).valueOrNull ?? 0;

    return NotificationSync(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 720) return navigationShell;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 720,
                  minHeight: constraints.maxHeight,
                ),
                child: navigationShell,
              ),
            );
          },
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: _NavBadge(
                  icon: Icons.build_outlined,
                  count: attentionCount,
                ),
                selectedIcon: _NavBadge(
                  icon: Icons.build,
                  count: attentionCount,
                ),
                label: 'Mantenimientos',
              ),
              const NavigationDestination(
                icon: Icon(Icons.directions_car_outlined),
                selectedIcon: Icon(Icons.directions_car),
                label: 'Vehículos',
              ),
              const NavigationDestination(
                icon: Icon(Icons.tune),
                selectedIcon: Icon(Icons.tune),
                label: 'Ajustes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  final IconData icon;
  final int count;

  const _NavBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return Icon(icon);

    return Badge(label: Text(count > 9 ? '9+' : '$count'), child: Icon(icon));
  }
}
