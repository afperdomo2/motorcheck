import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// `true` en plataformas de escritorio (Linux, Windows, macOS).
///
/// En móvil se usa el plugin nativo de `sqflite`; en escritorio hay que usar
/// `sqflite_common_ffi` y guardar la base de datos en el directorio de
/// soporte de la aplicación.
bool get isDesktopDatabasePlatform =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;

/// Configura el backend de SQLite según la plataforma.
///
/// Debe llamarse una sola vez antes de abrir la base de datos (en `main`).
/// En Android/iOS no hace nada: `sqflite` usa su implementación nativa.
void initDatabaseFactory() {
  if (!isDesktopDatabasePlatform) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
