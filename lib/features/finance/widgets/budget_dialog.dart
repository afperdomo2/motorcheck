import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../budget_alert_service.dart';
import '../providers.dart';

/// Abre el diálogo para definir o editar el presupuesto mensual del vehículo.
Future<void> showBudgetDialog(
  BuildContext context,
  WidgetRef ref,
  int vehicleId, {
  double? current,
}) async {
  final controller = TextEditingController(
    text: current != null ? current.toStringAsFixed(0) : '',
  );
  final amount = await showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Presupuesto mensual'),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Límite del mes',
          prefixIcon: Icon(Icons.attach_money),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(
              controller.text.trim().replaceAll(',', '.'),
            );
            Navigator.of(context).pop(value);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (amount == null || amount <= 0) return;

  try {
    await ref.read(budgetNotifierProvider.notifier).save(vehicleId, amount);
    await BudgetAlertService().reset(vehicleId);
    await BudgetAlertService().check(vehicleId);
    if (!context.mounted) return;
    AppSnackBar.success('Presupuesto actualizado');
  } catch (error) {
    logError('guardar presupuesto', error, StackTrace.current);
    if (!context.mounted) return;
    AppSnackBar.error('No se pudo guardar el presupuesto');
  }
}
