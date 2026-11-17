import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/reminders/models/reminder.dart';
import 'package:motorcheck/features/reminders/providers.dart';
import 'package:motorcheck/features/reminders/screens/reminders_screen.dart';

const _document = Reminder(
  id: 'document-1',
  kind: ReminderKind.document,
  vehicleId: 1,
  vehicleName: 'Mazda 33',
  title: 'SOAT',
  subtitle: 'Documento',
  severity: ReminderSeverity.warning,
  route: '/vehicles/1/documents',
  remainingDays: 12,
);

const _budget = Reminder(
  id: 'budget-1',
  kind: ReminderKind.budget,
  vehicleId: 1,
  vehicleName: 'Mazda 33',
  title: 'Presupuesto',
  subtitle: 'Excedido por \$ 84.000',
  severity: ReminderSeverity.overdue,
  route: '/finance?vehicleId=1',
  badgeLabel: '112 %',
);

const _restriction = Reminder(
  id: 'restriction-1',
  kind: ReminderKind.restriction,
  vehicleId: 1,
  vehicleName: 'Mazda 33',
  title: 'Pico y placa',
  subtitle: 'Hoy no circulas',
  severity: ReminderSeverity.info,
  route: '/vehicles/1/restriction',
);

Future<void> _pump(
  WidgetTester tester, {
  required List<Reminder> reminders,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [remindersProvider.overrideWith((ref) async => reminders)],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(360, 640),
            textScaler: TextScaler.linear(textScale),
          ),
          child: const RemindersScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra y filtra recordatorios', (tester) async {
    await _pump(tester, reminders: [_document, _restriction, _budget]);

    expect(find.text('Recordatorios'), findsOneWidget);
    expect(find.text('SOAT'), findsOneWidget);
    expect(find.text('Pico y placa'), findsWidgets);
    expect(find.text('112 %'), findsOneWidget);

    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Pico y placa'),
    );
    chip.onSelected!(true);
    await tester.pumpAndSettle();

    expect(find.text('SOAT'), findsNothing);
    expect(find.text('112 %'), findsNothing);

    final budgetChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Presupuesto'),
    );
    budgetChip.onSelected!(true);
    await tester.pumpAndSettle();

    expect(find.text('112 %'), findsOneWidget);
    expect(find.text('SOAT'), findsNothing);
  });

  testWidgets('muestra “Todo al día” sin recordatorios', (tester) async {
    await _pump(tester, reminders: const []);

    expect(find.text('Todo al día'), findsOneWidget);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    await _pump(
      tester,
      reminders: [_document, _restriction, _budget],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
