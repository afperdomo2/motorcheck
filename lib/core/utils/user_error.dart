import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Convierte errores técnicos en un mensaje presentable para el usuario.
///
/// Las pantallas deben pasar un [fallback] contextual, por ejemplo
/// "No se pudo guardar el taller".
String friendlyErrorMessage(Object error, {required String fallback}) {
  if (error is DatabaseException) {
    return 'No se pudo completar la operación. Intenta de nuevo.';
  }
  return fallback;
}

/// Registra el detalle técnico solo en modo debug.
void logError(String context, Object error, [StackTrace? stackTrace]) {
  assert(() {
    debugPrint('[$context] $error');
    if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
    return true;
  }());
}
