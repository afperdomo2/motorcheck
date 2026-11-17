import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/components/models/component_status.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/widgets/item_form_row.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';

void main() {
  final now = DateTime(2026, 11, 13);

  MaintenanceCategory category(String key, String name, String icon) {
    return MaintenanceCategory(
      key: key,
      name: name,
      iconName: icon,
      vehicleType: 'car',
      createdAt: now,
    );
  }

  final categories = [
    category('car_oil', 'Aceite', 'oil_barrel'),
    category('car_tires', 'Llantas', 'circle'),
    category('general', 'General', 'build'),
  ];

  final component = VehicleComponent(
    id: 7,
    vehicleId: 1,
    name: 'Llanta delantera izquierda',
    type: 'tire',
    categoryKey: 'car_tires',
    position: 'Delantera izquierda',
    positionCode: 'front_left',
    installedAt: now,
    installedKm: 60000,
    intervalKm: 50000,
    warningKm: 3000,
    createdAt: now,
    updatedAt: now,
  );
  final status = componentStatusFor(
    component,
    currentMileage: 89000,
    today: now,
  );

  MaintenanceItem item({String category = 'car_tires', int? componentId}) {
    return MaintenanceItem(
      maintenanceId: 1,
      category: category,
      componentId: componentId,
      createdAt: now,
    );
  }

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('abre en Servicios y permite pasar a Piezas', (tester) async {
    MaintenanceItem? changed;
    await tester.pumpWidget(
      wrap(
        ItemFormRow(
          item: item(),
          index: 0,
          canRemove: false,
          categories: categories,
          components: [status],
          onRemove: () {},
          onChanged: (updated) => changed = updated,
        ),
      ),
    );

    await tester.tap(find.byType(InputDecorator).first);
    await tester.pumpAndSettle();

    expect(find.text('SERVICIOS'), findsOneWidget);
    expect(find.text('PIEZAS'), findsNothing);
    expect(find.widgetWithText(ListTile, 'General'), findsOneWidget);

    await tester.tap(find.text('Piezas'));
    await tester.pumpAndSettle();
    expect(find.text('PIEZAS'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ListTile, 'Llanta delantera izquierda'),
    );
    await tester.pumpAndSettle();

    expect(changed?.componentId, 7);
    expect(changed?.category, 'car_tires');
  });

  testWidgets('con una pieza seleccionada abre en Piezas', (tester) async {
    await tester.pumpWidget(
      wrap(
        ItemFormRow(
          item: item(componentId: 7),
          index: 0,
          canRemove: false,
          categories: categories,
          components: [status],
          onRemove: () {},
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(InputDecorator).first);
    await tester.pumpAndSettle();

    expect(find.text('PIEZAS'), findsOneWidget);
    expect(
      find.widgetWithText(ListTile, 'Llanta delantera izquierda'),
      findsOneWidget,
    );
  });

  testWidgets('elegir un servicio quita la pieza', (tester) async {
    MaintenanceItem? changed;
    await tester.pumpWidget(
      wrap(
        ItemFormRow(
          item: item(componentId: 7),
          index: 0,
          canRemove: false,
          categories: categories,
          components: [status],
          onRemove: () {},
          onChanged: (updated) => changed = updated,
        ),
      ),
    );

    await tester.tap(find.byType(InputDecorator).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Servicios'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Aceite'));
    await tester.pumpAndSettle();

    expect(changed?.componentId, isNull);
    expect(changed?.category, 'car_oil');
  });

  testWidgets('sin piezas no muestra el segmentado', (tester) async {
    await tester.pumpWidget(
      wrap(
        ItemFormRow(
          item: item(category: 'car_oil'),
          index: 0,
          canRemove: false,
          categories: categories,
          onRemove: () {},
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(InputDecorator).first);
    await tester.pumpAndSettle();

    expect(find.text('SERVICIOS'), findsOneWidget);
    expect(find.text('PIEZAS'), findsNothing);
    expect(find.text('Piezas'), findsNothing);
  });

  testWidgets('la hoja no desborda a 360 px con texto al 200 %', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      wrap(
        ItemFormRow(
          item: item(),
          index: 0,
          canRemove: false,
          categories: categories,
          components: [status],
          onRemove: () {},
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(InputDecorator).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Piezas'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('PIEZAS'), findsOneWidget);
  });
}
