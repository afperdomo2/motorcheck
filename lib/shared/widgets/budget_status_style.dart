import 'package:flutter/material.dart';

import '../../core/theme/app_semantic_colors.dart';
import '../../features/finance/budget_status.dart';
import 'status_chip.dart';

/// Estado de UI asociado al nivel de un presupuesto.
AppStatus budgetAppStatus(BudgetStatus status) => switch (status) {
  BudgetStatus.exceeded => AppStatus.danger,
  BudgetStatus.warning => AppStatus.warning,
  BudgetStatus.ok => AppStatus.ok,
};

/// Color semántico del nivel de un presupuesto.
Color budgetColor(BuildContext context, BudgetStatus status) {
  final semantic = AppSemanticColors.of(context);
  return switch (status) {
    BudgetStatus.ok => semantic.success,
    BudgetStatus.warning => semantic.warning,
    BudgetStatus.exceeded => semantic.danger,
  };
}
