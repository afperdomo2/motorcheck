import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/finance/budget_status.dart';

void main() {
  test('clasifica el presupuesto por porcentaje', () {
    expect(budgetStatusFor(spent: 500000, amount: 1000000), BudgetStatus.ok);
    expect(
      budgetStatusFor(spent: 800000, amount: 1000000),
      BudgetStatus.warning,
    );
    expect(
      budgetStatusFor(spent: 1000000, amount: 1000000),
      BudgetStatus.exceeded,
    );
    expect(
      budgetStatusFor(spent: 1200000, amount: 1000000),
      BudgetStatus.exceeded,
    );
  });
}
