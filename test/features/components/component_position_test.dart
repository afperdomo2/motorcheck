import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/database/component_defaults.dart';
import 'package:motorcheck/features/components/models/component_position.dart';

void main() {
  group('posiciones disponibles', () {
    test('llantas de carro incluyen lados y repuesto', () {
      expect(positionCodesFor('car', 'tire'), [
        'front_left',
        'front_right',
        'rear_left',
        'rear_right',
        'spare',
      ]);
    });

    test('llantas de moto, bici y patineta solo adelante y atrás', () {
      for (final type in ['motorcycle', 'bike', 'scooter']) {
        expect(positionCodesFor(type, 'tire'), ['front', 'rear']);
      }
    });

    test('frenos de carro y dos ruedas son por eje', () {
      expect(positionCodesFor('car', 'brakes'), ['front', 'rear']);
      expect(positionCodesFor('motorcycle', 'brakes'), ['front', 'rear']);
    });

    test('batería, cadena y camión no tienen códigos', () {
      expect(positionCodesFor('car', 'battery'), isEmpty);
      expect(positionCodesFor('car', 'chain'), isEmpty);
      expect(positionCodesFor('truck', 'tire'), isEmpty);
      expect(positionCodesFor('other', 'tire'), isEmpty);
    });
  });

  group('etiquetas y nombres', () {
    test('frenos usan plural', () {
      expect(positionLabelFor('front', componentType: 'brakes'), 'Delanteros');
      expect(positionLabelFor('rear', componentType: 'brakes'), 'Traseros');
      expect(positionLabelFor('front', componentType: 'tire'), 'Delantera');
    });

    test('sugiere nombre desde tipo y posición', () {
      expect(
        componentNameForPosition('tire', 'front_left'),
        'Llanta delantera izquierda',
      );
      expect(componentNameForPosition('brakes', 'front'), 'Frenos delanteros');
      expect(componentNameForPosition('tire', 'spare'), 'Llanta de repuesto');
      expect(componentNameForPosition('battery', 'front'), isNull);
    });
  });

  group('inferencia desde texto', () {
    test('reconoce los textos actuales', () {
      expect(positionCodeFromText('Delantera izquierda'), 'front_left');
      expect(positionCodeFromText('Delantera derecha'), 'front_right');
      expect(positionCodeFromText('Trasera izquierda'), 'rear_left');
      expect(positionCodeFromText('Trasera derecha'), 'rear_right');
      expect(positionCodeFromText('Delanteros'), 'front');
      expect(positionCodeFromText('Traseros'), 'rear');
      expect(positionCodeFromText('Delantera'), 'front');
      expect(positionCodeFromText('Trasera'), 'rear');
      expect(positionCodeFromText('Repuesto'), 'spare');
    });

    test('tolera mayúsculas y tildes', () {
      expect(positionCodeFromText('DELANTERA IZQUIERDA'), 'front_left');
      expect(positionCodeFromText('delantera izquierda'), 'front_left');
    });

    test('no inventa posición para camión o piezas sin eje', () {
      expect(positionCodeFromText('Cadena y piñones'), isNull);
      expect(positionCodeFromText('Eje 2 izquierda exterior'), isNull);
      expect(positionCodeFromText(null), isNull);
      expect(positionCodeFromText(''), isNull);
    });
  });
}
