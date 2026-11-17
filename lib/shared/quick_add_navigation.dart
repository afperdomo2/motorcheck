import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/vehicles/vehicle_selection.dart';

/// Registro rápido disponible desde el FAB unificado.
///
/// El orden es el que se muestra de arriba hacia abajo: la acción más cercana
/// al pulgar es [expense].
enum QuickAddAction {
  maintenance(
    label: 'Mantenimiento',
    semanticLabel: 'Registrar mantenimiento',
    icon: Icons.build_outlined,
  ),
  fuel(
    label: 'Tanqueada',
    semanticLabel: 'Registrar tanqueada',
    icon: Icons.local_gas_station_outlined,
  ),
  expense(
    label: 'Gasto',
    semanticLabel: 'Registrar gasto',
    icon: Icons.receipt_long_outlined,
  );

  const QuickAddAction({
    required this.label,
    required this.semanticLabel,
    required this.icon,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
}

/// Abre el formulario del registro rápido con el vehículo ya resuelto.
///
/// Con un solo vehículo entra directo; con dos o más muestra el selector.
Future<void> startQuickAdd(
  BuildContext context,
  WidgetRef ref,
  QuickAddAction action,
) async {
  final vehicle = await pickVehicleOrUseSingle(context, ref);
  if (vehicle == null || !context.mounted) return;

  final path = switch (action) {
    QuickAddAction.maintenance => '/maintenance/add',
    QuickAddAction.fuel => '/finance/fuel/add',
    QuickAddAction.expense => '/finance/expenses/add',
  };
  context.push('$path?vehicleId=${vehicle.id}');
}
