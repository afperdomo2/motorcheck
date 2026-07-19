import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/utils/formatters.dart';

void main() {
  group('formatCurrency', () {
    test('formatea cero correctamente', () {
      expect(formatCurrency(0), '\$0');
    });

    test('formatea miles correctamente', () {
      expect(formatCurrency(1500), '\$1,500');
    });

    test('formatea decimales correctamente', () {
      expect(formatCurrency(1500.50), '\$1,501');
    });
  });

  group('formatDate', () {
    test('formatea fecha correctamente', () {
      final date = DateTime(2024, 3, 15);
      expect(formatDate(date), '2024-03-15');
    });
  });

  group('formatMileage', () {
    test('devuelve - para null', () {
      expect(formatMileage(null), '-');
    });

    test('formatea kilometraje sin comas si es menor a 1000', () {
      expect(formatMileage(500), '500 km');
    });

    test('formatea kilometraje con comas si es mayor a 1000', () {
      expect(formatMileage(15000), '15,000 km');
    });
  });

  group('formatDateTime', () {
    test('formatea fecha y hora correctamente', () {
      final dateTime = DateTime(2024, 3, 15, 14, 30, 0);
      final formatted = formatDateTime(dateTime);
      expect(formatted, contains('2024-03-15'));
    });
  });

  group('parseDateTime', () {
    test('parsea fecha y hora correctamente', () {
      final dateTime = parseDateTime('2024-03-15T14:30:00');
      expect(dateTime.year, 2024);
      expect(dateTime.month, 3);
      expect(dateTime.day, 15);
      expect(dateTime.hour, 14);
      expect(dateTime.minute, 30);
    });
  });

  group('parseDate', () {
    test('parsea fecha correctamente', () {
      final date = parseDate('2024-03-15');
      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 15);
    });
  });
}
