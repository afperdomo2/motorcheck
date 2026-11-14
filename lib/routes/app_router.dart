import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/notifications/notification_sync.dart';
import '../features/vehicles/providers.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/vehicles/screens/vehicles_screen.dart';
import '../features/vehicles/screens/vehicle_detail_screen.dart';
import '../features/vehicles/screens/vehicle_form_screen.dart';
import '../features/vehicles/screens/upcoming_maintenance_screen.dart';
import '../features/vehicles/screens/mileage_history_screen.dart';
import '../features/components/screens/components_screen.dart';
import '../features/components/screens/component_form_screen.dart';
import '../features/components/screens/component_detail_screen.dart';
import '../features/checklists/screens/checklists_screen.dart';
import '../features/checklists/screens/inspection_form_screen.dart';
import '../features/checklists/screens/inspection_detail_screen.dart';
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
import '../features/settings/screens/licenses_screen.dart';
import '../features/settings/screens/notification_settings_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/documents/screens/document_form_screen.dart';
import '../features/restrictions/screens/pico_y_placa_screen.dart';
import '../features/reminders/screens/reminders_screen.dart';
import '../features/reports/screens/vehicle_report_screen.dart';
import '../features/finance/screens/finance_screen.dart';
import '../features/fuel/screens/fuel_form_screen.dart';
import '../features/expenses/screens/expense_form_screen.dart';
import '../features/expenses/screens/expense_categories_screen.dart';

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
                    final componentId = int.tryParse(
                      state.uri.queryParameters['componentId'] ?? '',
                    );
                    return MaintenanceFormScreen(
                      vehicleId: vehicleId,
                      componentId: componentId,
                    );
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
                  path: ':id/mileage',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return MileageHistoryScreen(vehicleId: id);
                  },
                ),
                GoRoute(
                  path: ':id/checklists',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return ChecklistsScreen(vehicleId: id);
                  },
                  routes: [
                    GoRoute(
                      path: ':checklistId/start',
                      builder: (context, state) {
                        final vehicleId = int.parse(
                          state.pathParameters['id']!,
                        );
                        final checklistId = int.parse(
                          state.pathParameters['checklistId']!,
                        );
                        return InspectionFormScreen(
                          vehicleId: vehicleId,
                          checklistId: checklistId,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'runs/:runId',
                      builder: (context, state) {
                        final vehicleId = int.parse(
                          state.pathParameters['id']!,
                        );
                        final runId = int.parse(state.pathParameters['runId']!);
                        return InspectionDetailScreen(
                          vehicleId: vehicleId,
                          runId: runId,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: ':id/components',
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return ComponentsScreen(vehicleId: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        final spare = state.uri.queryParameters['spare'] == '1';
                        return ComponentFormScreen(vehicleId: id, spare: spare);
                      },
                    ),
                    GoRoute(
                      path: ':componentId',
                      builder: (context, state) {
                        final vehicleId = int.parse(
                          state.pathParameters['id']!,
                        );
                        final componentId = int.parse(
                          state.pathParameters['componentId']!,
                        );
                        return ComponentDetailScreen(
                          vehicleId: vehicleId,
                          componentId: componentId,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) {
                            final vehicleId = int.parse(
                              state.pathParameters['id']!,
                            );
                            final componentId = int.parse(
                              state.pathParameters['componentId']!,
                            );
                            return ComponentFormScreen(
                              vehicleId: vehicleId,
                              componentId: componentId,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
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
                        final renewId = int.tryParse(
                          state.uri.queryParameters['renew'] ?? '',
                        );
                        return DocumentFormScreen(
                          vehicleId: id,
                          renewFromId: renewId,
                        );
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
              path: '/finance',
              builder: (context, state) => const FinanceScreen(),
              routes: [
                GoRoute(
                  path: 'fuel/add',
                  builder: (context, state) {
                    final vehicleId = int.tryParse(
                      state.uri.queryParameters['vehicleId'] ?? '',
                    );
                    return FuelFormScreen(vehicleId: vehicleId);
                  },
                ),
                GoRoute(
                  path: 'fuel/:id/edit',
                  builder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    return FuelFormScreen(fuelLogId: id);
                  },
                ),
                GoRoute(
                  path: 'expenses/add',
                  builder: (context, state) {
                    final vehicleId = int.tryParse(
                      state.uri.queryParameters['vehicleId'] ?? '',
                    );
                    return ExpenseFormScreen(vehicleId: vehicleId);
                  },
                ),
                GoRoute(
                  path: 'expenses/:id/edit',
                  builder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    return ExpenseFormScreen(expenseId: id);
                  },
                ),
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const ExpenseCategoriesScreen(),
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
                  path: 'licenses',
                  builder: (context, state) => const LicensesScreen(),
                ),
                GoRoute(
                  path: 'documents',
                  builder: (context, state) => const DocumentsScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) {
                        final renewId = int.tryParse(
                          state.uri.queryParameters['renew'] ?? '',
                        );
                        return DocumentFormScreen(renewFromId: renewId);
                      },
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
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: 'Gastos',
              ),
              NavigationDestination(
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
