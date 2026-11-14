import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/widgets/item_form_row.dart';

void main() {
  final now = DateTime(2026, 11, 13);
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
}
