import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';

/// Inicializa los datos de locale antes de cualquier test.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await initializeDateFormatting('es_CO');
  await initializeDateFormatting('es');
  await testMain();
}
