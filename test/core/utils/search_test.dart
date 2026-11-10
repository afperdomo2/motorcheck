import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/utils/search.dart';

void main() {
  group('normalizeForSearch', () {
    test('ignora mayúsculas y espacios extra', () {
      expect(normalizeForSearch('  Cambio   de Aceite '), 'cambio de aceite');
    });

    test('quita acentos y diéresis', () {
      expect(normalizeForSearch('Batería'), 'bateria');
      expect(normalizeForSearch('Suspensión'), 'suspension');
      expect(normalizeForSearch('Ñandú'), 'nandu');
    });
  });
}
