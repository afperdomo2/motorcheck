import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/quick_add_fab.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../expenses/screens/expenses_view.dart';
import '../../fuel/screens/fuel_list_view.dart';
import '../../maintenance/widgets/vehicle_ficha.dart';
import '../../vehicles/current_vehicle_provider.dart';
import '../../vehicles/providers.dart';
import '../finance_section.dart';
import '../widgets/finance_section_selector.dart';
import 'finance_summary_view.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  Uri? _appliedUri;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (GoRouter.maybeOf(context) == null) return;
    final uri = GoRouterState.of(context).uri;
    if (_appliedUri == uri) return;
    _appliedUri = uri;
    _applyRouteQuery(uri);
  }

  /// Aplica `?vehicleId=…` que llega desde una notificación o un deep link,
  /// sin mutar estado durante el build. Un `?section=` desconocido (por
  /// ejemplo `budgets` de notificaciones antiguas) se ignora y se queda en
  /// la sección actual.
  void _applyRouteQuery(Uri uri) {
    final vehicleId = int.tryParse(uri.queryParameters['vehicleId'] ?? '');
    if (vehicleId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await ref
            .read(vehiclesNotifierProvider.notifier)
            .selectVehicle(vehicleId);
      } catch (error, stackTrace) {
        logError('seleccionar vehículo desde notificación', error, stackTrace);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final current = ref.watch(currentVehicleProvider).valueOrNull;
    final section = ref.watch(financeSectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          IconButton(
            tooltip: 'Categorías de gasto',
            onPressed: () => context.push('/finance/categories'),
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButton: const QuickAddFab(),
      body: vehiclesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudieron cargar los vehículos',
          onRetry: () => ref.invalidate(vehiclesProvider),
        ),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car,
              title: 'No hay vehículos',
              subtitle: 'Agrega un vehículo para registrar gastos',
              onAction: () => context.push('/vehicles/add'),
              actionLabel: 'Agregar vehículo',
            );
          }

          final selected = current ?? vehicles.first;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: Card(
                  child: VehicleFicha(
                    vehicle: selected,
                    onTap: () => _selectVehicle(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xs,
                ),
                child: FinanceSectionSelector(
                  selected: section,
                  onChanged: (value) =>
                      ref.read(financeSectionProvider.notifier).state = value,
                ),
              ),
              Expanded(
                child: switch (section) {
                  FinanceSection.summary => FinanceSummaryView(
                    vehicleId: selected.id!,
                  ),
                  FinanceSection.fuel => FuelListView(vehicleId: selected.id!),
                  FinanceSection.expenses => ExpensesView(
                    vehicleId: selected.id!,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectVehicle(BuildContext context) async {
    final selected = await VehicleSelectorSheet.show(context);
    if (selected?.id == null) return;
    await ref
        .read(vehiclesNotifierProvider.notifier)
        .selectVehicle(selected!.id!);
  }
}
