import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/user_error.dart';
import '../../shared/widgets/vehicle_selector_sheet.dart';
import 'models/vehicle.dart';
import 'providers.dart';

/// Devuelve el vehículo con el que se va a registrar un mantenimiento.
///
/// Con un solo vehículo lo usa sin abrir el selector; con dos o más muestra la
/// hoja para que el usuario elija. Devuelve `null` cuando no hay vehículos.
Future<Vehicle?> pickVehicleOrUseSingle(
  BuildContext context,
  WidgetRef ref,
) async {
  final vehicles = await _loadVehicles(ref);
  if (vehicles.isEmpty) return null;
  if (vehicles.length == 1) return vehicles.first;
  if (!context.mounted) return null;
  return VehicleSelectorSheet.show(context);
}

/// Resuelve el vehículo con el que abre un registro nuevo: el indicado, el
/// seleccionado o, cuando solo hay uno, ese.
Future<Vehicle?> resolveVehicleForNewRecord(
  WidgetRef ref, {
  int? preferredVehicleId,
}) async {
  final vehicles = await _loadVehicles(ref);
  if (vehicles.isEmpty) return null;

  final vehicleId = preferredVehicleId ?? ref.read(selectedVehicleIdProvider);
  if (vehicleId == null) return vehicles.length == 1 ? vehicles.first : null;

  final vehicle = await ref.read(vehicleRepositoryProvider).getById(vehicleId);
  if (vehicle != null) return vehicle;
  return vehicles.length == 1 ? vehicles.first : null;
}

Future<List<Vehicle>> _loadVehicles(WidgetRef ref) async {
  final cached = ref.read(vehiclesProvider);
  if (cached.hasValue) return cached.requireValue;
  try {
    return await ref.read(vehiclesProvider.future);
  } catch (error, stackTrace) {
    logError('No se pudieron cargar los vehículos', error, stackTrace);
    return const [];
  }
}
