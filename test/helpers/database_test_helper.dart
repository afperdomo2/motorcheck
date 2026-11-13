import 'dart:io';

import 'package:motorcheck/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Aísla cada archivo de pruebas en su propia base temporal. Los archivos de
/// test corren en isolates separados, así que el estado estático no se mezcla.
class TestDatabase {
  TestDatabase._();

  static Directory? _directory;

  static Future<void> setUp() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseHelper.instance.close();
    _directory = await Directory.systemTemp.createTemp('motorcheck_test_');
    DatabaseHelper.useDirectoryForTesting(_directory!.path);
  }

  static Future<void> tearDown() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.useDirectoryForTesting(null);
    final directory = _directory;
    if (directory != null && await directory.exists()) {
      await directory.delete(recursive: true);
    }
    _directory = null;
  }
}
