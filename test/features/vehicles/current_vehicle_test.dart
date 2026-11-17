import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/current_vehicle_provider.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

Vehicle _vehicle(int id, {bool isDefault = false, String name = 'Vehículo'}) {
  return Vehicle(
    id: id,
    name: name,
    type: 'car',
    isDefault: isDefault,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  group('resolveCurrentVehicle', () {
    test('prioriza el vehículo seleccionado', () {
      final vehicles = [_vehicle(1, isDefault: true), _vehicle(2)];

      expect(resolveCurrentVehicle(vehicles, 2)?.id, 2);
    });

    test('cae al principal cuando no hay selección', () {
      final vehicles = [_vehicle(1), _vehicle(2, isDefault: true)];

      expect(resolveCurrentVehicle(vehicles, null)?.id, 2);
    });

    test('cae al primero cuando no hay selección ni principal', () {
      final vehicles = [_vehicle(1), _vehicle(2)];

      expect(resolveCurrentVehicle(vehicles, null)?.id, 1);
    });

    test('ignora una selección que ya no existe', () {
      final vehicles = [_vehicle(1), _vehicle(2, isDefault: true)];

      expect(resolveCurrentVehicle(vehicles, 99)?.id, 2);
    });

    test('devuelve null sin vehículos', () {
      expect(resolveCurrentVehicle(const [], 1), isNull);
    });
  });
}
