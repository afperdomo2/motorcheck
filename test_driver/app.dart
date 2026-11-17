/// Punto de entrada para capturar pantallas de MotorCheck.
///
/// Se lanza con:
///   flutter run -t test_driver/app.dart -d linux
///
/// - Habilita la extensión de flutter_driver (tap, waitFor, scroll).
/// - Registra `ext.motorcheck.capture`, que guarda la pantalla actual
///   como PNG en disco y devuelve la ruta (sin base64 gigantes).
/// - Usa una base de datos temporal con datos de demostración
///   (`demo_seed.dart`); la base real del usuario nunca se toca.
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:motorcheck/app.dart';
import 'package:motorcheck/core/database/database_factory.dart';
import 'package:motorcheck/core/database/database_helper.dart';

import 'demo_seed.dart';

const _defaultOutDir = '/tmp/opencode/screenshots';
const _demoDbDir = '/tmp/opencode/motorcheck_demo_db';

Future<void> main() async {
  enableFlutterDriverExtension();
  _registerCaptureExtension();

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  initDatabaseFactory();
  await _prepareDemoDatabase();
  await seedDemoData();

  await initializeDateFormatting('es_CO');
  runApp(const ProviderScope(child: MotorCheckApp()));
}

/// Base temporal limpia en cada ejecución para que la semilla no duplique.
Future<void> _prepareDemoDatabase() async {
  final dir = Directory(_demoDbDir);
  await dir.create(recursive: true);
  final dbFile = File('$_demoDbDir/motorcheck.db');
  if (await dbFile.exists()) {
    await dbFile.delete();
  }
  DatabaseHelper.useDirectoryForTesting(_demoDbDir);
}

/// Guarda la pantalla actual como PNG.
///
/// Uso: `ext.motorcheck.capture` con parámetros `name` y `out` (opcional).
/// La captura usa la misma técnica que flutter_driver: rasteriza la capa
/// de la vista en un `ui.Image` y lo codifica como PNG.
void _registerCaptureExtension() {
  developer.registerExtension('ext.motorcheck.capture', (method, params) async {
    final name = params['name'] ?? 'capture';
    final outDir = params['out'] ?? _defaultOutDir;

    final binding = WidgetsBinding.instance;
    binding.scheduleFrame();
    await binding.endOfFrame;

    final renderView = RendererBinding.instance.renderViews.first;
    // ignore: invalid_use_of_protected_member
    final layer = renderView.layer! as OffsetLayer;
    final ui.Image image = await layer.toImage(renderView.paintBounds);
    final byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;

    final dir = Directory(outDir);
    await dir.create(recursive: true);
    final file = File('$outDir/$name.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    return developer.ServiceExtensionResponse.result(
      jsonEncode({'path': file.path}),
    );
  });
}
