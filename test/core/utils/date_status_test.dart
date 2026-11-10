import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/utils/date_status.dart';

void main() {
  group('dateStatus', () {
    test('marca como vencida una fecha pasada', () {
      final status = dateStatus(
        DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(status.days, -5);
      expect(status.level, ExpiryLevel.danger);
      expect(status.isExpired, isTrue);
      expect(status.shortLabel, 'Vencido hace 5 d');
      expect(status.longLabel, 'Vencido hace 5 días');
    });

    test('marca como aviso una fecha dentro de 30 días', () {
      final status = dateStatus(DateTime.now().add(const Duration(days: 30)));

      expect(status.days, 30);
      expect(status.level, ExpiryLevel.warning);
      expect(status.isExpired, isFalse);
      expect(status.shortLabel, 'Vence en 30 d');
    });

    test('marca como ok una fecha a más de 30 días', () {
      final status = dateStatus(DateTime.now().add(const Duration(days: 31)));

      expect(status.days, 31);
      expect(status.level, ExpiryLevel.ok);
    });

    test('reconoce el vencimiento de hoy', () {
      final status = dateStatus(DateTime.now());

      expect(status.days, 0);
      expect(status.level, ExpiryLevel.warning);
      expect(status.shortLabel, 'Vence hoy');
      expect(status.longLabel, 'Vence hoy');
    });

    test('permite una ventana de aviso personalizada', () {
      final status = dateStatus(
        DateTime.now().add(const Duration(days: 45)),
        warningDays: 60,
      );

      expect(status.level, ExpiryLevel.warning);
    });
  });
}
