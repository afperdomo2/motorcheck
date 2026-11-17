import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/vehicle.dart';
import 'providers.dart';

/// Resuelve el vehículo que la app está mostrando: el último seleccionado,
/// el principal o el primero, en ese orden.
Vehicle? resolveCurrentVehicle(List<Vehicle> vehicles, int? selectedId) {
  if (vehicles.isEmpty) return null;

  for (final vehicle in vehicles) {
    if (vehicle.id == selectedId) return vehicle;
  }
  for (final vehicle in vehicles) {
    if (vehicle.isDefault) return vehicle;
  }
  return vehicles.first;
}

/// Vehículo actual compartido por Inicio, Gastos y Mantenimientos.
final currentVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  final selectedId = ref.watch(selectedVehicleIdProvider);
  return resolveCurrentVehicle(vehicles, selectedId);
});
