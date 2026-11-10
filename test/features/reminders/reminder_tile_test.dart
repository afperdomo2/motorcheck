import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/reminders/models/reminder.dart';
import 'package:motorcheck/features/reminders/widgets/reminder_tile.dart';

void main() {
  testWidgets('muestra título, vehículo y estado vencido', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReminderTile(
            reminder: const Reminder(
              id: 'soat-1',
              kind: ReminderKind.document,
              vehicleId: 1,
              vehicleName: 'Toyota Corolla',
              title: 'SOAT',
              subtitle: 'SOAT',
              severity: ReminderSeverity.overdue,
              route: '/vehicles/1/documents',
              remainingDays: -3,
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('SOAT'), findsWidgets);
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('Vencido hace 3 días'), findsOneWidget);
  });

  testWidgets('muestra un mantenimiento próximo por km', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReminderTile(
            reminder: const Reminder(
              id: 'aceite-1',
              kind: ReminderKind.maintenance,
              vehicleId: 1,
              vehicleName: 'Moto',
              title: 'Aceite',
              subtitle: 'Mantenimiento',
              severity: ReminderSeverity.warning,
              route: '/vehicles/1/upcoming',
              remainingKm: 1200,
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Aceite'), findsOneWidget);
    expect(find.text('En 1200 km'), findsOneWidget);
  });
}
