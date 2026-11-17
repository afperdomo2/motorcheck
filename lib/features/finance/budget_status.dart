enum BudgetStatus { ok, warning, exceeded }

BudgetStatus budgetStatusFor({required double spent, required double amount}) {
  if (amount <= 0) return BudgetStatus.ok;
  if (spent >= amount) return BudgetStatus.exceeded;
  if (spent >= amount * 0.8) return BudgetStatus.warning;
  return BudgetStatus.ok;
}
