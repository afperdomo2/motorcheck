import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';

void main() {
  group('Maintenance model', () {
    test('fromJson crea Maintenance correctamente', () {
      final json = {
        'id': 1,
        'vehicleId': 1,
        'date': '2024-03-15',
        'mileage': 15000,
        'maintenanceCost': 200.0,
        'totalPartsCost': 100.0,
        'workshopId': 1,
        'notes': 'Aceite sintético',
        'createdAt': '2024-03-15T10:00:00',
        'updatedAt': '2024-03-15T10:00:00',
      };

      final maintenance = Maintenance.fromJson(json);

      expect(maintenance.id, 1);
      expect(maintenance.vehicleId, 1);
      expect(maintenance.mileage, 15000);
      expect(maintenance.maintenanceCost, 200.0);
      expect(maintenance.totalPartsCost, 100.0);
      expect(maintenance.workshopId, 1);
    });

    test('valores por defecto se asignan correctamente', () {
      final maintenance = Maintenance(
        vehicleId: 1,
        date: DateTime(2024),
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      expect(maintenance.id, isNull);
      expect(maintenance.maintenanceCost, 0);
      expect(maintenance.totalPartsCost, 0);
      expect(maintenance.mileage, isNull);
      expect(maintenance.workshopId, isNull);
    });
  });

  group('MaintenanceItem model', () {
    test('fromJson crea MaintenanceItem correctamente', () {
      final json = {
        'id': 1,
        'maintenanceId': 1,
        'category': 'oil',
        'partsCost': 25.0,
        'notes': 'Marca Castrol',
        'createdAt': '2024-03-15T10:00:00',
      };

      final item = MaintenanceItem.fromJson(json);

      expect(item.id, 1);
      expect(item.maintenanceId, 1);
      expect(item.category, 'oil');
      expect(item.partsCost, 25.0);
      expect(item.notes, 'Marca Castrol');
    });

    test('valores por defecto se asignan correctamente', () {
      final item = MaintenanceItem(maintenanceId: 1, createdAt: DateTime(2024));

      expect(item.id, isNull);
      expect(item.category, 'general');
      expect(item.partsCost, 0);
    });
  });
}
