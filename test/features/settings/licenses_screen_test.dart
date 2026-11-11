import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/app_info.dart';
import 'package:motorcheck/features/settings/screens/licenses_screen.dart';

void main() {
  testWidgets('muestra titular, licencia y resumen no comercial', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LicensesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('${AppInfo.name} · v${AppInfo.version}'), findsOneWidget);
    expect(
      find.text('© ${AppInfo.copyrightYear} ${AppInfo.copyrightHolder}'),
      findsOneWidget,
    );
    expect(find.text(AppInfo.licenseName), findsOneWidget);
    expect(find.textContaining('prohibidos'), findsOneWidget);
    expect(find.text('Licencias de paquetes'), findsOneWidget);
  });

  testWidgets('expande la licencia SIL OFL de las fuentes', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LicensesScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('SIL OPEN FONT LICENSE'), findsNothing);

    await tester.tap(find.text('Fuentes Barlow'));
    await tester.pumpAndSettle();

    expect(find.textContaining('SIL OPEN FONT LICENSE'), findsOneWidget);
  });
}
