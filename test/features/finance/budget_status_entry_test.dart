import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/finance/budget_status.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

BudgetStatusEntry _entry({Budget? budget, double spent = 0}) {
  return BudgetStatusEntry(
    vehicle: Vehicle(
      id: 1,
      name: 'Bici',
      type: 'bike',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
    budget: budget,
    spent: spent,
  );
}

Budget _budget(double amount) {
  return Budget(
    vehicleId: 1,
    period: '2026-11',
    amount: amount,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  group('BudgetStatusEntry', () {
    test('calcula porcentaje y estado excedido', () {
      final entry = _entry(budget: _budget(700000), spent: 784000);

      expect(entry.hasBudget, isTrue);
      expect(entry.percent, 112);
      expect(entry.status, BudgetStatus.exceeded);
      expect(entry.remainingLabel, contains('Excedido por'));
    });

    test('marca advertencia desde el 80 %', () {
      final entry = _entry(budget: _budget(700000), spent: 616000);

      expect(entry.percent, 88);
      expect(entry.status, BudgetStatus.warning);
      expect(entry.remainingLabel, contains('Quedan'));
    });

    test('queda al día por debajo del 80 %', () {
      final entry = _entry(budget: _budget(600000), spent: 270000);

      expect(entry.percent, 45);
      expect(entry.status, BudgetStatus.ok);
    });

    test('sin presupuesto no tiene porcentaje ni estado de riesgo', () {
      final entry = _entry(spent: 100000);

      expect(entry.hasBudget, isFalse);
      expect(entry.percent, 0);
      expect(entry.status, BudgetStatus.ok);
      expect(entry.remainingLabel, 'Sin presupuesto mensual');
    });
  });
}
