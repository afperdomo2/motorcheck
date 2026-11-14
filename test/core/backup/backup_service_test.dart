import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/backup/backup_service.dart';
import 'package:motorcheck/core/database/database_helper.dart';
import 'package:motorcheck/features/components/models/component_service.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/components/repository.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
import 'package:motorcheck/features/documents/repository.dart';
import 'package:motorcheck/features/expenses/models/expense.dart';
import 'package:motorcheck/features/expenses/repository.dart';
import 'package:motorcheck/features/finance/budget_repository.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/fuel/models/fuel_log.dart';
import 'package:motorcheck/features/fuel/repository.dart';
import 'package:motorcheck/features/maintenance/maintenance_attachment_repository.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_attachment.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
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

    final fuelRepo = FuelRepository();
    await fuelRepo.insert(
      FuelLog(
        vehicleId: vehicleId,
        date: now,
        odometer: 10100,
        quantity: 40,
        unitPrice: 4000,
        totalCost: 160000,
        fuelType: 'gasoline',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final receipt = File(p.join(baseDir.path, 'recibo.png'));
    await receipt.writeAsBytes([5, 6, 7, 8]);
    final expenseRepo = ExpenseRepository();
    await expenseRepo.insert(
      Expense(
        vehicleId: vehicleId,
        categoryKey: 'other',
        date: now,
        amount: 50000,
        receiptPath: receipt.path,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final maintenanceId = await MaintenanceRepository().insert(
      Maintenance(
        vehicleId: vehicleId,
        date: now,
        mileage: 10100,
        createdAt: now,
        updatedAt: now,
      ),
      const [],
    );
    final invoice = File(p.join(baseDir.path, 'factura.pdf'));
    await invoice.writeAsBytes([9, 10, 11, 12]);
    final attachmentRepo = MaintenanceAttachmentRepository();
    await attachmentRepo.insert(
      MaintenanceAttachment(
        maintenanceId: maintenanceId,
        name: 'factura.pdf',
        filePath: invoice.path,
        createdAt: now,
      ),
    );
    final componentsRepo = ComponentsRepository();
    final componentId = await componentsRepo.insert(
      VehicleComponent(
        vehicleId: vehicleId,
        name: 'Llanta delantera',
        type: 'tire',
        installedAt: now,
        installedKm: 10000,
        intervalKm: 10000,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await componentsRepo.registerService(
      ComponentService(
        componentId: componentId,
        date: now,
        odometer: 10000,
        createdAt: now,
      ),
    );
    final budgetRepo = BudgetRepository();
    await budgetRepo.upsert(
      Budget(
        vehicleId: vehicleId,
        period: budgetRepo.currentPeriod,
        amount: 800000,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final result = await service.createBackup();
    expect(await result.file.exists(), isTrue);
    expect(result.counts['vehicles'], 1);
    expect(result.counts['documents'], 1);
    expect(result.counts['fuel_logs'], 1);
    expect(result.counts['expenses'], 1);
    expect(result.counts['maintenance_attachments'], 1);
    expect(result.counts['budgets'], 1);
    expect(result.counts['components'], 1);
    expect(result.counts['component_services'], 1);
    expect(result.counts['expense_categories'], greaterThanOrEqualTo(8));
    expect(result.attachments, 3);

    final preview = await service.inspect(result.file);
    expect(preview.counts['vehicles'], 1);
    expect(preview.counts['fuel_logs'], 1);
    expect(preview.counts['expenses'], 1);
    expect(preview.counts['maintenance_attachments'], 1);
    expect(preview.attachments, 3);

    await vehicleRepo.delete(vehicleId);
    expect(await documentsRepo.getAll(), isEmpty);
    expect(await expenseRepo.getAll(), isEmpty);
    expect(await fuelRepo.getByVehicleId(vehicleId), isEmpty);

    await service.restore(result.file);

    final restoredVehicle = await vehicleRepo.getById(vehicleId);
    expect(restoredVehicle, isNotNull);
    expect(restoredVehicle!.name, 'Respaldo');

    final restoredDocuments = await documentsRepo.getByVehicleId(vehicleId);
    expect(restoredDocuments, hasLength(1));
    expect(restoredDocuments.first.filePath, isNotNull);
    expect(await File(restoredDocuments.first.filePath!).exists(), isTrue);

    final restoredFuel = await fuelRepo.getByVehicleId(vehicleId);
    expect(restoredFuel, hasLength(1));

    final restoredExpenses = await expenseRepo.getForVehicle(
      vehicleId,
      includeGlobal: false,
    );
    expect(restoredExpenses, hasLength(1));
    expect(restoredExpenses.first.receiptPath, isNotNull);
    expect(await File(restoredExpenses.first.receiptPath!).exists(), isTrue);

    final restoredAttachments = await attachmentRepo.getByMaintenanceId(
      maintenanceId,
    );
    expect(restoredAttachments, hasLength(1));
    expect(await File(restoredAttachments.first.filePath).exists(), isTrue);

    final restoredBudget = await budgetRepo.getForVehiclePeriod(
      vehicleId,
      budgetRepo.currentPeriod,
    );
    expect(restoredBudget, isNotNull);
    expect(restoredBudget!.amount, 800000);

    final restoredComponents = await componentsRepo.getByVehicleId(vehicleId);
    expect(restoredComponents, hasLength(1));
    expect(restoredComponents.first.name, 'Llanta delantera');
    final restoredServices = await componentsRepo.getServices(
      restoredComponents.first.id!,
    );
    expect(restoredServices, hasLength(1));
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
