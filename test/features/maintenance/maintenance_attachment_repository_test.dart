import 'package:flutter_test/flutter_test.dart';
import '../../helpers/database_test_helper.dart';
import 'package:motorcheck/features/maintenance/maintenance_attachment_repository.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_attachment.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

void main() {
  setUpAll(TestDatabase.setUp);

  tearDownAll(TestDatabase.tearDown);

  test('inserta, lista y elimina adjuntos', () async {
    final vehicleId = await VehicleRepository().insert(
      Vehicle(
        name: 'Adjuntos',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final now = DateTime(2026, 11, 13);
    final maintenanceId = await MaintenanceRepository().insert(
      Maintenance(
        vehicleId: vehicleId,
        date: now,
        mileage: 1000,
        createdAt: now,
        updatedAt: now,
      ),
      const [],
    );

    final repo = MaintenanceAttachmentRepository();
    final id = await repo.insert(
      MaintenanceAttachment(
        maintenanceId: maintenanceId,
        name: 'factura.pdf',
        filePath: '/tmp/factura.pdf',
        createdAt: now,
      ),
    );

    final attachments = await repo.getByMaintenanceId(maintenanceId);
    expect(attachments, hasLength(1));
    expect(attachments.first.name, 'factura.pdf');

    await repo.delete(id);
    expect(await repo.getByMaintenanceId(maintenanceId), isEmpty);
  });
}
