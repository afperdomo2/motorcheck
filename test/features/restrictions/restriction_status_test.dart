import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/restrictions/models/vehicle_restriction.dart';
import 'package:motorcheck/features/restrictions/restriction_status.dart';

void main() {
  VehicleRestriction restriction({
    bool enabled = true,
    bool exempt = false,
    List<int> days = const [1, 3, 5],
    String start = '06:00',
    String end = '21:00',
  }) {
    return VehicleRestriction(
      vehicleId: 1,
      enabled: enabled,
      days: days,
      startTime: start,
      endTime: end,
      exempt: exempt,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  test('detecta restricción hoy y ahora', () {
    final status = evaluateRestriction(restriction(), DateTime(2026, 11, 9, 7));

    expect(status.configured, isTrue);
    expect(status.restrictedToday, isTrue);
    expect(status.restrictedNow, isTrue);
    expect(status.todayLabel, contains('Hoy no circulas'));
  });

  test('después del horario apunta a la próxima restricción', () {
    final status = evaluateRestriction(
      restriction(),
      DateTime(2026, 11, 9, 22),
    );

    expect(status.restrictedToday, isTrue);
    expect(status.restrictedNow, isFalse);
    expect(status.nextRestrictionDate, DateTime(2026, 11, 11));
  });

  test('un día sin restricción calcula la siguiente', () {
    final status = evaluateRestriction(
      restriction(),
      DateTime(2026, 11, 10, 8),
    );

    expect(status.restrictedToday, isFalse);
    expect(status.nextRestrictionDate, DateTime(2026, 11, 11));
  });

  test('exento y desactivado no restringen', () {
    final exempt = evaluateRestriction(
      restriction(exempt: true),
      DateTime(2026, 11, 9, 7),
    );
    final disabled = evaluateRestriction(
      restriction(enabled: false),
      DateTime(2026, 11, 9, 7),
    );

    expect(exempt.restrictedToday, isFalse);
    expect(exempt.todayLabel, contains('Exento'));
    expect(disabled.configured, isFalse);
  });
}
