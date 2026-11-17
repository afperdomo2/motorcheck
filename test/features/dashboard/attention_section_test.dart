import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/widgets/attention_section.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/reminders/models/reminder.dart';
import 'package:motorcheck/features/reminders/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

Vehicle _vehicle(int id, String name, String type) {
  return Vehicle(
    id: id,
    name: name,
    type: type,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

BudgetStatusEntry _budgetEntry({
  required Vehicle vehicle,
  required double amount,
  required double spent,
}) {
  return BudgetStatusEntry(
    vehicle: vehicle,
    budget: Budget(
      vehicleId: vehicle.id,
      period: '2026-11',
      amount: amount,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
    spent: spent,
  );
}

Reminder _documentReminder() {
  return const Reminder(
    id: 'document-1',
    kind: ReminderKind.document,
    vehicleId: 2,
    vehicleName: 'Moto',
    title: 'SOAT',
    subtitle: 'SOAT',
    severity: ReminderSeverity.warning,
    route: '/vehicles/2/documents',
    remainingDays: 12,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required List<Reminder> reminders,
  required List<BudgetStatusEntry> budgets,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        remindersProvider.overrideWith((ref) async => reminders),
        budgetStatusesProvider.overrideWith((ref) async => budgets),
      ],
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
  testWidgets('muestra vencimientos y presupuestos de todos los vehículos', (
    tester,
  ) async {
    final bici = _vehicle(1, 'Bici', 'bike');
    final carro = _vehicle(3, 'Carro', 'car');

    await _pump(
      tester,
      reminders: [_documentReminder()],
      budgets: [
        _budgetEntry(vehicle: bici, amount: 700000, spent: 784000),
        _budgetEntry(vehicle: carro, amount: 600000, spent: 270000),
      ],
    );

    expect(find.text('Atención · 2'), findsOneWidget);
    expect(find.text('Vencimientos'), findsOneWidget);
    expect(find.text('SOAT'), findsOneWidget);
    expect(find.text('Presupuestos'), findsOneWidget);
    expect(find.text('Bici'), findsOneWidget);
    expect(find.text('Carro'), findsOneWidget);
    expect(find.text('112 %'), findsOneWidget);
    expect(find.text('45 %'), findsOneWidget);
  });

  testWidgets(
    'se oculta cuando no hay vencimientos ni presupuestos en riesgo',
    (tester) async {
      final carro = _vehicle(3, 'Carro', 'car');

      await _pump(
        tester,
        reminders: const [],
        budgets: [_budgetEntry(vehicle: carro, amount: 600000, spent: 270000)],
      );

      expect(find.text('Atención'), findsNothing);
      expect(find.byType(Card), findsNothing);
    },
  );

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    final bici = _vehicle(1, 'Bicicleta Trek eléctrica', 'bike');

    await _pump(
      tester,
      reminders: [_documentReminder()],
      budgets: [_budgetEntry(vehicle: bici, amount: 700000, spent: 784000)],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
