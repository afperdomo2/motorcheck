import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
import 'package:motorcheck/features/expenses/models/expense.dart';
import 'package:motorcheck/features/expenses/models/expense_category.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/fuel/models/fuel_log.dart';
import 'package:motorcheck/features/fuel/repository.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/models/workshop.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/reminders/health_score.dart';
import 'package:motorcheck/features/reports/pdf_report_service.dart';
import 'package:motorcheck/features/reports/report_data.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
import 'package:motorcheck/features/vehicles/mileage_repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

VehicleFinanceSummary _financeFixture({
  double maintenance = 0,
  double fuel = 0,
  double expenses = 0,
  int maintenanceCount = 0,
  int fuelCount = 0,
  int expenseCount = 0,
  FuelStats fuelStats = const FuelStats(),
}) {
  final total = maintenance + fuel + expenses;
  return VehicleFinanceSummary(
    vehicleId: 1,
    monthLabel: 'Noviembre 2026',
    currentMonthMaintenance: maintenance,
    currentMonthFuel: fuel,
    currentMonthExpenses: expenses,
    currentMonthTotal: total,
    totalMaintenance: maintenance,
    totalFuel: fuel,
    totalExpenses: expenses,
    totalCost: total,
    costPerKm: total > 0 ? 120 : null,
    fuelStats: fuelStats,
    maintenanceCount: maintenanceCount,
    fuelCount: fuelCount,
    expenseCount: expenseCount,
    monthlyPoints: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('genera una hoja de vida PDF válida', () async {
    final createdAt = DateTime(2026, 1, 1);
    final maintenance = Maintenance(
      id: 1,
      vehicleId: 1,
      date: DateTime(2026, 10, 12),
      mileage: 152300,
      maintenanceCost: 120000,
      totalPartsCost: 300000,
      workshopId: 1,
      notes: 'Cambio de aceite y filtros',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    final category = MaintenanceCategory(
      key: 'car_oil',
      name: 'Aceite',
      vehicleType: 'car',
      createdAt: createdAt,
    );
    final fuelLog = FuelLog(
      vehicleId: 1,
      date: DateTime(2026, 11, 10),
      odometer: 152300,
      quantity: 42,
      unitPrice: 4285,
      totalCost: 179970,
      fuelType: 'gasoline',
      station: 'Terpel',
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    final expenseCategory = ExpenseCategory(
      key: 'insurance',
      name: 'Seguro',
      iconName: 'security',
      createdAt: createdAt,
    );
    final expense = Expense(
      vehicleId: 1,
      categoryKey: 'insurance',
      date: DateTime(2026, 11, 5),
      amount: 380000,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final data = VehicleReportData(
      vehicle: Vehicle(
        id: 1,
        name: 'Toyota Corolla',
        brand: 'Toyota',
        model: 'Corolla',
        plate: 'ABC123',
        currentMileage: 152300,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      maintenances: [maintenance],
      itemsByMaintenance: {
        1: [
          MaintenanceItem(
            id: 1,
            maintenanceId: 1,
            category: 'car_oil',
            partsCost: 300000,
            createdAt: createdAt,
          ),
        ],
      },
      workshops: {
        1: Workshop(id: 1, name: 'Taller Central', createdAt: createdAt),
      },
      categories: {'car_oil': category},
      documents: [
        VehicleDocument(
          id: 1,
          vehicleId: 1,
          type: 'soat',
          name: 'SOAT',
          expiresAt: DateTime(2027, 1, 1),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      ],
      upcoming: [
        UpcomingMaintenance(
          category: category.copyWith(intervalKm: 5000),
          lastMileage: 150000,
          remainingKm: 2700,
          isWarning: true,
          kmWarning: true,
        ),
      ],
      health: const HealthScore(
        value: 82,
        label: 'Atención',
        reasons: ['1 documento por vencer'],
      ),
      mileageStats: const MileageStats(
        currentMileage: 152300,
        averageKmPerDay: 40,
      ),
      fuelLogs: [fuelLog],
      expenses: [expense],
      expenseCategories: {'insurance': expenseCategory},
      finance: _financeFixture(
        maintenance: 420000,
        fuel: 179970,
        expenses: 380000,
        maintenanceCount: 1,
        fuelCount: 1,
        expenseCount: 1,
        fuelStats: FuelStats(
          count: 1,
          totalQuantity: 42,
          totalCost: 179970,
          currentMonthSpent: 179970,
          averageConsumption: 12.4,
          litersPer100Km: 8.1,
          costPerKm: 120,
          lastLog: fuelLog,
        ),
      ),
      totalCost: 979970,
      costPerKm: 120,
    );

    final bytes = await PdfReportService().build(data);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('pagina correctamente un historial largo', () async {
    final createdAt = DateTime(2026, 1, 1);
    final category = MaintenanceCategory(
      key: 'car_oil',
      name: 'Aceite',
      vehicleType: 'car',
      createdAt: createdAt,
    );
    final maintenances = List.generate(
      30,
      (index) => Maintenance(
        id: index + 1,
        vehicleId: 1,
        date: DateTime(2024, 1, 1).add(Duration(days: index * 20)),
        mileage: 50000 + index * 2000,
        maintenanceCost: 50000,
        totalPartsCost: 100000,
        workshopId: 1,
        notes: 'Mantenimiento de ejemplo ${index + 1}',
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
    final items = {
      for (final maintenance in maintenances)
        maintenance.id!: [
          MaintenanceItem(
            id: maintenance.id,
            maintenanceId: maintenance.id!,
            category: 'car_oil',
            partsCost: 100000,
            createdAt: createdAt,
          ),
        ],
    };

    final data = VehicleReportData(
      vehicle: Vehicle(
        id: 1,
        name: 'Toyota Corolla',
        currentMileage: 152300,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      maintenances: maintenances,
      itemsByMaintenance: items,
      workshops: {
        1: Workshop(id: 1, name: 'Taller Central', createdAt: createdAt),
      },
      categories: {'car_oil': category},
      documents: const [],
      upcoming: const [],
      health: const HealthScore(
        value: 82,
        label: 'Atención',
        reasons: ['Todo al día'],
      ),
      mileageStats: const MileageStats(
        currentMileage: 152300,
        averageKmPerDay: 40,
      ),
      fuelLogs: const [],
      expenses: const [],
      expenseCategories: const {},
      finance: _financeFixture(maintenance: 4500000, maintenanceCount: 30),
      totalCost: 4500000,
      costPerKm: 120,
    );

    final bytes = await PdfReportService().build(data);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
