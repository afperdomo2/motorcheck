import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../components/models/component_status.dart';
import '../components/providers.dart';
import '../documents/models/vehicle_document.dart';
import '../documents/providers.dart';
import '../expenses/models/expense.dart';
import '../expenses/models/expense_category.dart';
import '../expenses/providers.dart';
import '../finance/providers.dart';
import '../fuel/models/fuel_log.dart';
import '../fuel/providers.dart';
import '../maintenance/models/maintenance.dart';
import '../maintenance/models/maintenance_item.dart';
import '../maintenance/models/workshop.dart';
import '../maintenance/providers.dart';
import '../reminders/health_score.dart';
import '../reminders/providers.dart';
import '../settings/models/maintenance_category.dart';
import '../settings/providers.dart';
import '../vehicles/mileage_repository.dart';
import '../vehicles/models/vehicle.dart';
import '../vehicles/providers.dart';

class VehicleReportData {
  const VehicleReportData({
    required this.vehicle,
    required this.maintenances,
    required this.itemsByMaintenance,
    required this.workshops,
    required this.categories,
    required this.documents,
    required this.components,
    required this.upcoming,
    required this.health,
    required this.mileageStats,
    required this.fuelLogs,
    required this.expenses,
    required this.expenseCategories,
    required this.finance,
    required this.totalCost,
    required this.costPerKm,
  });

  final Vehicle vehicle;
  final List<Maintenance> maintenances;
  final Map<int, List<MaintenanceItem>> itemsByMaintenance;
  final Map<int, Workshop> workshops;
  final Map<String, MaintenanceCategory> categories;
  final List<VehicleDocument> documents;
  final List<ComponentStatus> components;
  final List<UpcomingMaintenance> upcoming;
  final HealthScore health;
  final MileageStats mileageStats;
  final List<FuelLog> fuelLogs;
  final List<Expense> expenses;
  final Map<String, ExpenseCategory> expenseCategories;
  final VehicleFinanceSummary finance;
  final double totalCost;
  final double? costPerKm;

  String get generatedAtLabel => formatDisplayDate(DateTime.now());
}

final vehicleReportDataProvider = FutureProvider.family<VehicleReportData, int>(
  (ref, vehicleId) async {
    final vehicle = await ref.watch(selectedVehicleProvider(vehicleId).future);
    if (vehicle == null) {
      throw StateError('Vehículo no encontrado');
    }

    final maintRepo = ref.read(maintenanceRepositoryProvider);
    final maintenances = await maintRepo.getByVehicleId(vehicleId);
    final items = await maintRepo.getItemsByMaintenanceIds(
      maintenances.map((m) => m.id!).toList(),
    );
    final itemsByMaintenance = <int, List<MaintenanceItem>>{};
    for (final item in items) {
      itemsByMaintenance.putIfAbsent(item.maintenanceId, () => []).add(item);
    }

    final workshops = await ref.read(workshopRepositoryProvider).getAll();
    final categories = await ref
        .read(maintenanceCategoryRepositoryProvider)
        .getAll();
    final vehicleDocuments = await ref.watch(
      vehicleDocumentsProvider(vehicleId).future,
    );
    final globalDocuments = await ref.watch(globalDocumentsProvider.future);
    final upcoming = await ref.watch(
      upcomingMaintenanceProvider(vehicleId).future,
    );
    final components = await ref.watch(
      vehicleComponentStatusesProvider(vehicleId).future,
    );
    final health = await ref.watch(vehicleHealthProvider(vehicleId).future);
    final stats = await ref.watch(mileageStatsProvider(vehicleId).future);
    final fuelLogs = await ref.watch(fuelLogsProvider(vehicleId).future);
    final expenses = await ref.watch(vehicleExpensesProvider(vehicleId).future);
    final expenseCategories = await ref.watch(expenseCategoriesProvider.future);
    final finance = await ref.watch(vehicleFinanceProvider(vehicleId).future);

    return VehicleReportData(
      vehicle: vehicle,
      maintenances: List<Maintenance>.from(maintenances)
        ..sort((a, b) => b.date.compareTo(a.date)),
      itemsByMaintenance: itemsByMaintenance,
      workshops: {
        for (final workshop in workshops)
          if (workshop.id != null) workshop.id!: workshop,
      },
      categories: {for (final category in categories) category.key: category},
      documents: [...vehicleDocuments, ...globalDocuments],
      components: components,
      upcoming: upcoming.where((item) => item.hasInterval).toList(),
      health: health,
      mileageStats: stats,
      fuelLogs: fuelLogs,
      expenses: expenses,
      expenseCategories: {
        for (final category in expenseCategories) category.key: category,
      },
      finance: finance,
      totalCost: finance.totalCost,
      costPerKm: finance.costPerKm,
    );
  },
);
