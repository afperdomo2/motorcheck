import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/reminders/health_score.dart';

void main() {
  test('sin problemas da 100 y Al día', () {
    final score = scoreFrom(
      overdueMaintenances: 0,
      warningMaintenances: 0,
      expiredDocuments: 0,
      expiringDocuments: 0,
      daysSinceMileageUpdate: 10,
    );

    expect(score.value, 100);
    expect(score.label, 'Al día');
  });

  test('descuenta vencidos y documentos', () {
    final score = scoreFrom(
      overdueMaintenances: 1,
      warningMaintenances: 2,
      expiredDocuments: 1,
      expiringDocuments: 1,
      daysSinceMileageUpdate: 90,
    );

    expect(score.value, lessThan(70));
    expect(score.label, 'Riesgo');
  });

  test('descuenta componentes vencidos y próximos', () {
    final withoutComponents = scoreFrom(
      overdueMaintenances: 0,
      warningMaintenances: 0,
      expiredDocuments: 0,
      expiringDocuments: 0,
      daysSinceMileageUpdate: 10,
    );
    final withComponents = scoreFrom(
      overdueMaintenances: 0,
      warningMaintenances: 0,
      expiredDocuments: 0,
      expiringDocuments: 0,
      daysSinceMileageUpdate: 10,
      overdueComponents: 2,
      warningComponents: 1,
    );

    expect(withoutComponents.value, 100);
    expect(withComponents.value, 100 - 16 - 3);
  });

  test('nunca baja de cero', () {
    final score = scoreFrom(
      overdueMaintenances: 10,
      warningMaintenances: 10,
      expiredDocuments: 10,
      expiringDocuments: 10,
      daysSinceMileageUpdate: 100,
    );

    expect(score.value, 0);
    expect(score.label, 'Crítico');
  });
}
