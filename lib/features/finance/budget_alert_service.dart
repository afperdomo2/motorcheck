import 'package:shared_preferences/shared_preferences.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/user_error.dart';
import '../expenses/repository.dart';
import '../fuel/repository.dart';
import '../maintenance/repository.dart';
import '../vehicles/repository.dart';
import 'budget_repository.dart';
import 'budget_status.dart';

/// Revisa el presupuesto del mes y muestra una notificación al cruzar el
/// 80 % o el 100 %. Guarda el último umbral avisado para no repetir.
class BudgetAlertService {
  final BudgetRepository _budgetRepo = BudgetRepository();
  final MaintenanceRepository _maintenanceRepo = MaintenanceRepository();
  final FuelRepository _fuelRepo = FuelRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();

  Future<void> check(int vehicleId) async {
    try {
      final period = _budgetRepo.currentPeriod;
      final budget = await _budgetRepo.getForVehiclePeriod(vehicleId, period);
      if (budget == null || budget.amount <= 0) return;

      final now = DateTime.now();
      final maintenances = await _maintenanceRepo.getByVehicleId(vehicleId);
      final fuelLogs = await _fuelRepo.getByVehicleId(vehicleId);
      final expenses = await _expenseRepo.getForVehicle(
        vehicleId,
        includeGlobal: false,
      );

      final maintenanceSpent = maintenances
          .where(
            (item) =>
                item.date.year == now.year && item.date.month == now.month,
          )
          .fold<double>(
            0,
            (sum, item) => sum + item.maintenanceCost + item.totalPartsCost,
          );
      final fuelSpent = fuelLogs
          .where(
            (log) => log.date.year == now.year && log.date.month == now.month,
          )
          .fold<double>(0, (sum, log) => sum + log.totalCost);
      final expenseSpent = expenses
          .where(
            (expense) =>
                expense.date.year == now.year &&
                expense.date.month == now.month,
          )
          .fold<double>(0, (sum, expense) => sum + expense.amount);

      final spent = maintenanceSpent + fuelSpent + expenseSpent;
      final status = budgetStatusFor(spent: spent, amount: budget.amount);
      if (status == BudgetStatus.ok) return;

      final threshold = status == BudgetStatus.exceeded ? 100 : 80;
      final prefs = await SharedPreferences.getInstance();
      final key = 'budget_alert_${vehicleId}_$period';
      final last = prefs.getInt(key) ?? 0;
      if (last >= threshold) return;

      final enabled = await NotificationService.instance
          .areNotificationsEnabled();
      if (!enabled) return;

      final vehicle = await _vehicleRepo.getById(vehicleId);
      final vehicleName = vehicle?.name ?? 'Vehículo';
      final percent = ((spent / budget.amount) * 100).round();
      final title = status == BudgetStatus.exceeded
          ? 'Presupuesto excedido'
          : 'Presupuesto cerca del límite';
      final body = status == BudgetStatus.exceeded
          ? '$vehicleName: $percent % del presupuesto. '
                'Superado por ${formatCurrency(spent - budget.amount)}.'
          : '$vehicleName: $percent % del presupuesto de '
                '${formatMonthYearLong(now)}.';

      await NotificationService.instance.showNow(
        id: 9000 + vehicleId,
        title: title,
        body: body,
        payload: '/finance',
      );
      await prefs.setInt(key, threshold);
    } catch (error) {
      logError('alerta de presupuesto', error, StackTrace.current);
    }
  }

  Future<void> reset(int vehicleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final period = _budgetRepo.currentPeriod;
      await prefs.remove('budget_alert_${vehicleId}_$period');
    } catch (error) {
      logError('reset alerta presupuesto', error, StackTrace.current);
    }
  }
}
