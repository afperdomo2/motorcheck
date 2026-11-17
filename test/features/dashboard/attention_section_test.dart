import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/widgets/attention_section.dart';
import 'package:motorcheck/features/reminders/models/reminder.dart';
import 'package:motorcheck/features/reminders/providers.dart';

const _document = Reminder(
  id: 'document-1',
  kind: ReminderKind.document,
  vehicleId: 1,
  vehicleName: 'Mazda 33',
  title: 'SOAT',
  subtitle: 'SOAT',
  severity: ReminderSeverity.warning,
  route: '/vehicles/1/documents',
  remainingDays: 12,
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
          child: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AttentionSection(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra vencimientos y excluye el pico y placa', (tester) async {
    await _pump(tester, reminders: [_document, _restriction]);

    expect(find.text('Vencimientos'), findsOneWidget);
    expect(find.text('SOAT'), findsOneWidget);
    expect(find.text('Pico y placa'), findsNothing);
  });

  testWidgets('se oculta cuando no hay vencimientos', (tester) async {
    await _pump(tester, reminders: [_restriction]);

    expect(find.text('Vencimientos'), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    await _pump(tester, reminders: [_document, _restriction], textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
