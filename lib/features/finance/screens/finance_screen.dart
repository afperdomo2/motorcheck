import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../expenses/screens/expenses_view.dart';
import '../../fuel/screens/fuel_list_view.dart';
import '../../maintenance/widgets/vehicle_ficha.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';
import '../widgets/finance_section_selector.dart';
import 'finance_summary_view.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  FinanceSection _section = FinanceSection.summary;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);

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
      floatingActionButton: _buildFab(selectedId),
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

          final selected =
              _selectedVehicle(vehicles, selectedId) ?? vehicles.first;
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
                  selected: _section,
                  onChanged: (section) => setState(() => _section = section),
                ),
              ),
              Expanded(
                child: switch (_section) {
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

  Widget? _buildFab(int? selectedId) {
    final vehicles = ref.read(vehiclesProvider).valueOrNull ?? [];
    final id = selectedId ?? (vehicles.isNotEmpty ? vehicles.first.id : null);
    if (id == null) return null;
    if (_section == FinanceSection.fuel) {
      return FloatingActionButton.extended(
        onPressed: () => context.push('/finance/fuel/add?vehicleId=$id'),
        icon: const Icon(Icons.local_gas_station),
        label: const Text('Tanqueada'),
      );
    }
    if (_section == FinanceSection.expenses) {
      return FloatingActionButton.extended(
        onPressed: () => context.push('/finance/expenses/add?vehicleId=$id'),
        icon: const Icon(Icons.receipt_long),
        label: const Text('Gasto'),
      );
    }
    return null;
  }

  Future<void> _selectVehicle(BuildContext context) async {
    final selected = await VehicleSelectorSheet.show(context);
    if (selected?.id == null) return;
    await ref
        .read(vehiclesNotifierProvider.notifier)
        .selectVehicle(selected!.id!);
  }

  Vehicle? _selectedVehicle(List<Vehicle> vehicles, int? selectedId) {
    if (selectedId == null) return null;
    for (final vehicle in vehicles) {
      if (vehicle.id == selectedId) return vehicle;
    }
    return null;
  }
}
