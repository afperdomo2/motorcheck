import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/shared/quick_add_navigation.dart';
import 'package:motorcheck/shared/widgets/quick_add_fab.dart';

void main() {
  final toyota = Vehicle(
    id: 1,
    name: 'Toyota Corolla',
    type: 'car',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  Future<ProviderContainer> pumpFab(
    WidgetTester tester, {
    List<Vehicle>? vehicles,
    ValueChanged<QuickAddAction>? onSelected,
  }) async {
    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith((ref) async => vehicles ?? [toyota]),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: const SizedBox.expand(),
            floatingActionButton: QuickAddFab(onSelected: onSelected ?? (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  testWidgets('sin vehículos no muestra el botón', (tester) async {
    await pumpFab(tester, vehicles: const []);

    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('al tocar despliega las tres acciones', (tester) async {
    await pumpFab(tester);
    expect(find.text('Mantenimiento'), findsNothing);

    await openMenu(tester);

    expect(find.text('Mantenimiento'), findsOneWidget);
    expect(find.text('Tanqueada'), findsOneWidget);
    expect(find.text('Gasto'), findsOneWidget);
  });

  testWidgets('al tocar fuera se cierra sin registrar', (tester) async {
    QuickAddAction? selected;
    await pumpFab(tester, onSelected: (action) => selected = action);
    await openMenu(tester);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.text('Mantenimiento'), findsNothing);
    expect(selected, isNull);
  });

  testWidgets('al elegir una acción se cierra y la reporta', (tester) async {
    QuickAddAction? selected;
    await pumpFab(tester, onSelected: (action) => selected = action);
    await openMenu(tester);

    await tester.tap(find.text('Gasto'));
    await tester.pumpAndSettle();

    expect(selected, QuickAddAction.expense);
    expect(find.text('Mantenimiento'), findsNothing);
  });

  testWidgets('la señal de cambio de pestaña cierra el menú', (tester) async {
    final container = await pumpFab(tester);
    await openMenu(tester);

    container.read(quickAddCloseSignalProvider.notifier).state++;
    await tester.pumpAndSettle();

    expect(find.text('Mantenimiento'), findsNothing);
  });

  testWidgets('la tecla Escape cierra el menú', (tester) async {
    await pumpFab(tester);
    await openMenu(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Mantenimiento'), findsNothing);
  });
}
