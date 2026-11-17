import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/widgets/fleet_spend_card.dart';
import 'package:motorcheck/features/finance/providers.dart';

Future<void> _pump(
  WidgetTester tester, {
  required MonthSpendBreakdown breakdown,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fleetMonthBreakdownProvider.overrideWith((ref) async => breakdown),
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
              child: FleetSpendCard(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const breakdown = MonthSpendBreakdown(
    maintenance: 2100000,
    fuel: 350000,
    expenses: 290000,
  );

  testWidgets('muestra el total y el desglose de todos los vehículos', (
    tester,
  ) async {
    await _pump(tester, breakdown: breakdown);

    expect(find.textContaining('Gasto de'), findsOneWidget);
    expect(find.text('Todos los vehículos'), findsOneWidget);
    expect(find.text('Mantenimiento'), findsOneWidget);
    expect(find.text('Combustible'), findsOneWidget);
    expect(find.text('Otros'), findsOneWidget);
    expect(find.textContaining('2.740.000'), findsOneWidget);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    await _pump(tester, breakdown: breakdown, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
