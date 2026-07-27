import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

void main() {
  group('Vehicle model', () {
    test('fromJson crea Vehicle correctamente', () {
      final json = {
        'id': 1,
        'name': 'Mi Carro',
        'type': 'car',
        'brand': 'Toyota',
        'model': 'Corolla',
        'year': 2020,
        'plate': 'ABC123',
        'color': 'Rojo',
        'imagePath': null,
        'currentMileage': null,
        'mileageUpdatedAt': null,
        'isDefault': true,
        'createdAt': '2024-01-01T00:00:00',
        'updatedAt': '2024-01-01T00:00:00',
      };

      final vehicle = Vehicle.fromJson(json);

      expect(vehicle.id, 1);
      expect(vehicle.name, 'Mi Carro');
      expect(vehicle.type, 'car');
      expect(vehicle.brand, 'Toyota');
      expect(vehicle.model, 'Corolla');
      expect(vehicle.year, 2020);
      expect(vehicle.plate, 'ABC123');
      expect(vehicle.color, 'Rojo');
      expect(vehicle.currentMileage, isNull);
      expect(vehicle.mileageUpdatedAt, isNull);
      expect(vehicle.vin, isNull);
      expect(vehicle.soatExpiresAt, isNull);
      expect(vehicle.rtmExpiresAt, isNull);
    });

    test('fromJson con nuevos campos', () {
      final json = {
        'id': 2,
        'name': 'Mi Moto',
        'type': 'motorcycle',
        'brand': 'Honda',
        'model': 'CB125',
        'year': 2023,
        'plate': 'XYZ789',
        'vin': '9BWZZZ377VT004251',
        'soatExpiresAt': '2025-06-15T00:00:00',
        'rtmExpiresAt': '2025-12-01T00:00:00',
        'createdAt': '2024-01-01T00:00:00',
        'updatedAt': '2024-06-01T00:00:00',
      };

      final vehicle = Vehicle.fromJson(json);

      expect(vehicle.vin, '9BWZZZ377VT004251');
      expect(vehicle.soatExpiresAt, DateTime(2025, 6, 15));
      expect(vehicle.rtmExpiresAt, DateTime(2025, 12, 1));
    });

    test('copyWith modifica campos correctamente', () {
      final vehicle = Vehicle(
        id: 1,
        name: 'Mi Carro',
        type: 'car',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      final updated = vehicle.copyWith(name: 'Otro Carro');

      expect(updated.name, 'Otro Carro');
      expect(updated.type, 'car');
    });

    test('valores por defecto se asignan correctamente', () {
      final vehicle = Vehicle(
        name: 'Bici',
        type: 'bike',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      expect(vehicle.id, isNull);
      expect(vehicle.brand, isNull);
      expect(vehicle.isDefault, false);
    });
  });
}
