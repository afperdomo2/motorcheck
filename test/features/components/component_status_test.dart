import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/components/models/component_status.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';

void main() {
  VehicleComponent component({
    int? intervalKm,
    int? intervalMonths,
    int? installedKm,
    int? warningKm,
    int? warningDays,
    bool active = true,
  }) {
    return VehicleComponent(
      id: 1,
      vehicleId: 1,
      name: 'Llanta delantera',
      type: 'tire',
      installedAt: DateTime(2026, 1, 10),
      installedKm: installedKm,
      intervalKm: intervalKm,
      intervalMonths: intervalMonths,
      warningKm: warningKm,
      warningDays: warningDays,
      active: active,
      createdAt: DateTime(2026, 1, 10),
      updatedAt: DateTime(2026, 1, 10),
    );
  }

  final today = DateTime(2026, 11, 13);

  test('calcula el próximo cambio por kilometraje', () {
    final status = componentStatusFor(
      component(intervalKm: 10000, installedKm: 150000, warningKm: 500),
      currentMileage: 154700,
      today: today,
    );

    expect(status.nextKm, 160000);
    expect(status.remainingKm, 5300);
    expect(status.isOverdue, isFalse);
    expect(status.isWarning, isFalse);
    expect(status.isOk, isTrue);
    expect(status.primaryLabel, 'En 5.300 km');
  });

  test('marca próximo cuando entra en la ventana de aviso por km', () {
    final status = componentStatusFor(
      component(intervalKm: 10000, installedKm: 150000, warningKm: 1000),
      currentMileage: 159500,
      today: today,
    );

    expect(status.remainingKm, 500);
    expect(status.isWarning, isTrue);
    expect(status.isOverdue, isFalse);
    expect(status.statusWord, 'Próximo');
    expect(status.primaryLabel, 'En 500 km');
  });

  test('marca vencido por kilometraje', () {
    final status = componentStatusFor(
      component(intervalKm: 10000, installedKm: 150000, warningKm: 1000),
      currentMileage: 161200,
      today: today,
    );

    expect(status.remainingKm, -1200);
    expect(status.isOverdue, isTrue);
    expect(status.kmOverdue, isTrue);
    expect(status.statusWord, 'Vencido');
    expect(status.primaryLabel, 'Vencido hace 1.200 km');
  });

  test('calcula por meses cuando no hay kilometraje', () {
    final status = componentStatusFor(
      component(intervalMonths: 12, warningDays: 30),
      today: DateTime(2026, 12, 20),
    );

    expect(status.nextDate, DateTime(2027, 1, 10));
    expect(status.remainingDays, 21);
    expect(status.isWarning, isTrue);
    expect(status.primaryLabel, 'En 21 días');
  });

  test('con ambos intervalos manda lo que ocurra primero', () {
    final status = componentStatusFor(
      component(
        intervalKm: 10000,
        installedKm: 150000,
        intervalMonths: 24,
        warningKm: 1000,
      ),
      currentMileage: 159500,
      today: DateTime(2026, 11, 13),
    );

    expect(status.remainingKm, 500);
    expect(status.remainingDays, greaterThan(300));
    expect(status.isWarning, isTrue);
    expect(status.primaryLabel, 'En 500 km');
  });

  test('un reemplazo mueve la base del ciclo', () {
    final status = componentStatusFor(
      component(intervalKm: 10000, installedKm: 150000, warningKm: 1000),
      currentMileage: 158000,
      today: today,
      replacementDate: DateTime(2026, 11, 1),
      replacementKm: 155000,
    );

    expect(status.isReplaced, isTrue);
    expect(status.baselineDate, DateTime(2026, 11, 1));
    expect(status.baselineKm, 155000);
    expect(status.nextKm, 165000);
    expect(status.remainingKm, 7000);
    expect(status.isOk, isTrue);
  });

  test('sin intervalos es solo informativo', () {
    final status = componentStatusFor(component(), today: today);

    expect(status.isInformational, isTrue);
    expect(status.hasInterval, isFalse);
    expect(status.statusWord, 'Sin frecuencia');
    expect(status.isWarning, isFalse);
    expect(status.isOverdue, isFalse);
  });

  test('un componente inactivo no cuenta como vencido', () {
    final status = componentStatusFor(
      component(intervalKm: 1000, installedKm: 150000, active: false),
      currentMileage: 200000,
      today: today,
    );

    expect(status.isInactive, isTrue);
    expect(status.statusWord, 'Inactivo');
    expect(status.primaryLabel, 'Inactivo');
  });

  test('ordena vencidos, próximos, al día e informativos', () {
    final statuses = [
      componentStatusFor(component(), today: today),
      componentStatusFor(
        component(intervalKm: 10000, installedKm: 150000),
        currentMileage: 155000,
        today: today,
      ),
      componentStatusFor(
        component(intervalKm: 10000, installedKm: 150000, warningKm: 1000),
        currentMileage: 159500,
        today: today,
      ),
      componentStatusFor(
        component(intervalKm: 10000, installedKm: 150000),
        currentMileage: 161000,
        today: today,
      ),
    ]..sort(compareComponentStatus);

    expect(statuses.map((s) => s.statusWord).toList(), [
      'Vencido',
      'Próximo',
      'Al día',
      'Sin frecuencia',
    ]);
  });
}
