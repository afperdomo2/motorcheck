import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/shared/widgets/empty_state.dart';
import 'package:motorcheck/shared/widgets/error_state.dart';
import 'package:motorcheck/shared/widgets/loading_indicator.dart';

void main() {
  group('EmptyState', () {
    testWidgets('muestra título e ícono', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(icon: Icons.car_repair, title: 'Sin vehículos'),
          ),
        ),
      );

      expect(find.text('Sin vehículos'), findsOneWidget);
      expect(find.byIcon(Icons.car_repair), findsOneWidget);
    });

    testWidgets('muestra subtítulo cuando se provee', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.car_repair,
              title: 'Sin vehículos',
              subtitle: 'Agrega tu primer vehículo',
            ),
          ),
        ),
      );

      expect(find.text('Agrega tu primer vehículo'), findsOneWidget);
    });

    testWidgets('muestra botón de acción cuando se provee', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.car_repair,
              title: 'Sin vehículos',
              onAction: () {},
              actionLabel: 'Agregar',
            ),
          ),
        ),
      );

      expect(find.text('Agregar'), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('muestra mensaje de error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorState(message: 'Error de conexión')),
        ),
      );

      expect(find.text('Error de conexión'), findsOneWidget);
      expect(find.text('Algo salió mal'), findsOneWidget);
    });

    testWidgets('muestra botón de reintentar cuando se provee', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(message: 'Error', onRetry: () {}),
          ),
        ),
      );

      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('LoadingIndicator', () {
    testWidgets('muestra CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra mensaje cuando se provee', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(message: 'Cargando...')),
        ),
      );

      expect(find.text('Cargando...'), findsOneWidget);
    });
  });
}
