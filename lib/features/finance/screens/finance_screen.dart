import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
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
import '../widgets/budgets_view.dart';
import '../widgets/finance_section_selector.dart';
import 'finance_summary_view.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    onTap: () => _selectVehicle(context, ref),
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
                  FinanceSection.budgets => const BudgetsView(),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _selectVehicle(BuildContext context, WidgetRef ref) async {
    final selected = await VehicleSelectorSheet.show(context);
    if (selected?.id == null) return;
    await ref
        .read(vehiclesNotifierProvider.notifier)
        .selectVehicle(selected!.id!);
  }
}
