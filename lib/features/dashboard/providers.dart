import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../maintenance/models/maintenance.dart';
import '../maintenance/providers.dart';
import '../vehicles/current_vehicle_provider.dart';

/// Últimos mantenimientos del vehículo actual para el resumen de Inicio.
final dashboardRecentMaintenancesProvider = FutureProvider<List<Maintenance>>((
  ref,
) async {
  final vehicle = await ref.watch(currentVehicleProvider.future);
  if (vehicle?.id == null) return const [];

  final maintenances = await ref.watch(maintenancesProvider.future);
  final filtered =
      maintenances
          .where((maintenance) => maintenance.vehicleId == vehicle!.id)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  return filtered.take(3).toList();
});
