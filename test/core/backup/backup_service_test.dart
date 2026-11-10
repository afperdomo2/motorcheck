import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/backup/backup_service.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
import 'package:motorcheck/features/documents/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory dbDir;
  late Directory baseDir;
  late Directory tempDir;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseHelper.instance.close();
    dbDir = await Directory.systemTemp.createTemp('motorcheck_db_');
    baseDir = await Directory.systemTemp.createTemp('motorcheck_base_');
    tempDir = await Directory.systemTemp.createTemp('motorcheck_tmp_');
    DatabaseHelper.useDirectoryForTesting(dbDir.path);
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.useDirectoryForTesting(null);
    for (final dir in [dbDir, baseDir, tempDir]) {
      if (await dir.exists()) await dir.delete(recursive: true);
    }
  });

  test('exporta, inspecciona y restaura datos con adjuntos', () async {
    final vehicleRepo = VehicleRepository();
    final documentsRepo = DocumentsRepository();
    final service = BackupService(
      baseDirectory: baseDir,
      temporaryDirectory: tempDir,
    );

    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Respaldo',
        plate: 'ABC123',
        currentMileage: 10000,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    final attachment = File(p.join(baseDir.path, 'soat.pdf'));
    await attachment.writeAsBytes([1, 2, 3, 4]);
    final now = DateTime(2026, 1, 1);
    await documentsRepo.insert(
      VehicleDocument(
        vehicleId: vehicleId,
        type: 'soat',
        name: 'SOAT',
        expiresAt: DateTime(2026, 12, 31),
        filePath: attachment.path,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final result = await service.createBackup();
    expect(await result.file.exists(), isTrue);
    expect(result.counts['vehicles'], 1);
    expect(result.counts['documents'], 1);
    expect(result.attachments, 1);

    final preview = await service.inspect(result.file);
    expect(preview.counts['vehicles'], 1);
    expect(preview.attachments, 1);

    await vehicleRepo.delete(vehicleId);
    expect(await documentsRepo.getAll(), isEmpty);

    await service.restore(result.file);

    final restoredVehicle = await vehicleRepo.getById(vehicleId);
    expect(restoredVehicle, isNotNull);
    expect(restoredVehicle!.name, 'Respaldo');

    final restoredDocuments = await documentsRepo.getByVehicleId(vehicleId);
    expect(restoredDocuments, hasLength(1));
    expect(restoredDocuments.first.filePath, isNotNull);
    expect(await File(restoredDocuments.first.filePath!).exists(), isTrue);
  });

  test('rechaza un archivo que no es de MotorCheck', () async {
    final service = BackupService(
      baseDirectory: baseDir,
      temporaryDirectory: tempDir,
    );
    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          'data.json',
          '{"format":"otro","schemaVersion":1,"tables":{}}',
        ),
      );
    final file = File(p.join(baseDir.path, 'invalido.zip'));
    await file.writeAsBytes(ZipEncoder().encode(archive));

    await expectLater(service.inspect(file), throwsA(isA<FormatException>()));
  });
}
