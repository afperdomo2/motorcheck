import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/database/database_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  initDatabaseFactory();
  await initializeDateFormatting('es_CO');
  await initializeDateFormatting('es');
  runApp(const ProviderScope(child: MotorCheckApp()));
}
