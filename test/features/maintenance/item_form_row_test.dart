import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/widgets/item_form_row.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';

void main() {
  final now = DateTime(2026, 11, 13);
  final aceite = MaintenanceCategory(
    key: 'car_oil',
    name: 'Aceite',
    iconName: 'oil_barrel',
    vehicleType: 'car',
    createdAt: now,
  );
  final component = VehicleComponent(
    id: 7,
    vehicleId: 1,
    name: 'Llanta delantera izquierda',
    type: 'tire',
    categoryKey: 'car_tires',
    position: 'Delantera izquierda',
    installedAt: now,
    installedKm: 60000,
    intervalKm: 50000,
    warningKm: 3000,
    createdAt: now,
    updatedAt: now,
  );

  testWidgets('muestra el selector de componente reemplazado', (tester) async {
    MaintenanceItem? changed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ItemFormRow(
              item: MaintenanceItem(
                maintenanceId: 1,
                category: 'car_tires',
                createdAt: now,
              ),
              index: 0,
              canRemove: false,
              categories: const [],
              components: [component],
              onRemove: () {},
              onChanged: (item) => changed = item,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Componente reemplazado (opcional)'), findsOneWidget);
    expect(find.text('Sin reemplazo de componente'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Llanta delantera izquierda · Delantera izquierda').last,
    );
    await tester.pumpAndSettle();

    expect(changed?.componentId, 7);
  });

  testWidgets('sin componentes no muestra el selector', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemFormRow(
            item: MaintenanceItem(
              maintenanceId: 1,
              category: 'general',
              createdAt: now,
            ),
            index: 0,
            canRemove: false,
            categories: const [],
            onRemove: () {},
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Componente reemplazado (opcional)'), findsNothing);
  });

  testWidgets('colapsado muestra el resumen y oculta los campos', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemFormRow(
            item: MaintenanceItem(
              maintenanceId: 1,
              category: 'car_oil',
              partsCost: 85000,
              createdAt: now,
            ),
            index: 0,
            canRemove: true,
            categories: [aceite],
            expanded: false,
            onToggle: () {},
            onRemove: () {},
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Ítem 1'), findsOneWidget);
    expect(find.textContaining('Aceite'), findsOneWidget);
    expect(find.textContaining('85.000'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    // Los campos siguen montados (no se pierde lo escrito) pero no se ven.
    expect(find.text('Categoría *'), findsNothing);
    expect(find.text('Repuestos'), findsNothing);
  });

  testWidgets('expandido muestra los campos y el chevron hacia arriba', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemFormRow(
            item: MaintenanceItem(
              maintenanceId: 1,
              category: 'car_oil',
              createdAt: now,
            ),
            index: 2,
            canRemove: true,
            categories: [aceite],
            onToggle: () {},
            onRemove: () {},
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Ítem 3'), findsOneWidget);
    expect(find.text('Categoría *'), findsOneWidget);
    expect(find.text('Repuestos'), findsOneWidget);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
  });

  testWidgets('tocar el resumen alterna la fila', (tester) async {
    var toggles = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemFormRow(
            item: MaintenanceItem(
              maintenanceId: 1,
              category: 'car_oil',
              createdAt: now,
            ),
            index: 0,
            canRemove: false,
            categories: [aceite],
            expanded: false,
            onToggle: () => toggles++,
            onRemove: () {},
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ítem 1'));
    await tester.pumpAndSettle();

    expect(toggles, 1);
  });

  testWidgets('sin categoría válida avisa en el resumen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemFormRow(
            item: MaintenanceItem(
              maintenanceId: 1,
              category: 'general',
              createdAt: now,
            ),
            index: 0,
            canRemove: false,
            categories: [aceite],
            expanded: false,
            onToggle: () {},
            onRemove: () {},
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Sin categoría'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsWidgets);
  });

  testWidgets('exige categoría cuando el catálogo tiene opciones', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: ItemFormRow(
              item: MaintenanceItem(
                maintenanceId: 1,
                category: 'general',
                createdAt: now,
              ),
              index: 0,
              canRemove: false,
              categories: [aceite],
              onRemove: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Elige una categoría'), findsOneWidget);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    Future<void> pumpRow({required bool expanded}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ItemFormRow(
                  item: MaintenanceItem(
                    maintenanceId: 1,
                    category: 'car_oil',
                    partsCost: 1240000,
                    notes: 'Cambio de aceite sintético',
                    createdAt: now,
                  ),
                  index: 2,
                  canRemove: true,
                  categories: [aceite],
                  components: [component],
                  expanded: expanded,
                  onToggle: () {},
                  onRemove: () {},
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await pumpRow(expanded: true);
    expect(find.text('Categoría *'), findsOneWidget);

    await pumpRow(expanded: false);
    expect(find.text('Ítem 3'), findsOneWidget);
    expect(find.textContaining('Sin categoría'), findsNothing);
  });
}
