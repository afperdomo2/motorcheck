import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/files/attachment_preview_screen.dart';

void main() {
  testWidgets('avisa cuando el archivo no existe', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AttachmentPreviewScreen(
          filePath: '/tmp/motorcheck-no-existe.png',
          name: 'no-existe.png',
        ),
      ),
    );

    expect(
      find.text('El archivo ya no existe en este dispositivo.'),
      findsOneWidget,
    );
  });
}
