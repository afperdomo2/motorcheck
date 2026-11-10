import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';

void main() {
  test('addMonths conserva el día y ajusta meses cortos', () {
    expect(addMonths(DateTime(2026, 1, 15), 6), DateTime(2026, 7, 15));
    expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(addMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
  });

  test('etiqueta vencimiento por fecha', () {
    final item = UpcomingMaintenance(
      category: MaintenanceCategory(
        key: 'car_oil',
        name: 'Aceite',
        vehicleType: 'car',
        intervalMonths: 6,
        createdAt: DateTime(2026, 1, 1),
      ),
      lastServiceDate: DateTime(2026, 1, 1),
      nextServiceDate: DateTime(2026, 7, 1),
      remainingDays: -3,
      isOverdue: true,
      dateOverdue: true,
    );

    expect(item.statusLabel(), 'Vencido hace 3 días');
  });

  test('avisa cuando falta kilometraje para calcular', () {
    final item = UpcomingMaintenance(
      category: MaintenanceCategory(
        key: 'car_oil',
        name: 'Aceite',
        vehicleType: 'car',
        intervalKm: 5000,
        createdAt: DateTime(2026, 1, 1),
      ),
      lastMileage: 10000,
      needsMileage: true,
    );

    expect(item.statusLabel(), 'Falta kilometraje');
  });

  test('vence hoy es aviso, no vencido', () {
    final item = UpcomingMaintenance(
      category: MaintenanceCategory(
        key: 'car_oil',
        name: 'Aceite',
        vehicleType: 'car',
        intervalMonths: 6,
        createdAt: DateTime(2026, 1, 1),
      ),
      lastServiceDate: DateTime(2026, 5, 10),
      nextServiceDate: DateTime(2026, 11, 10),
      remainingDays: 0,
      isWarning: true,
      dateWarning: true,
    );

    expect(item.statusLabel(), 'Vence hoy');
  });

  test('etiqueta próximo por km y fecha', () {
    final item = UpcomingMaintenance(
      category: MaintenanceCategory(
        key: 'car_oil',
        name: 'Aceite',
        vehicleType: 'car',
        intervalKm: 5000,
        intervalMonths: 6,
        createdAt: DateTime(2026, 1, 1),
      ),
      lastMileage: 10000,
      lastServiceDate: DateTime(2026, 1, 1),
      nextServiceDate: DateTime(2026, 7, 1),
      remainingKm: 1200,
      remainingDays: 12,
      isWarning: true,
      kmWarning: true,
      dateWarning: true,
    );

    expect(item.statusLabel(), 'En 1200 km · 12 días');
  });
}
