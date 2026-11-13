import 'package:flutter_test/flutter_test.dart';
import '../../helpers/database_test_helper.dart';
import 'package:motorcheck/features/checklists/models/inspection_answer.dart';
import 'package:motorcheck/features/checklists/models/inspection_run.dart';
import 'package:motorcheck/features/checklists/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

void main() {
  setUpAll(TestDatabase.setUp);

  tearDownAll(TestDatabase.tearDown);

  test('seed, inspección e historial', () async {
    final vehicleId = await VehicleRepository().insert(
      Vehicle(
        name: 'Checklist',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final repo = ChecklistRepository();
    final checklists = await repo.getForVehicle(vehicleId, 'car');

    expect(checklists, isNotEmpty);
    expect(checklists.first.name, 'Inspección pre-viaje');

    final items = await repo.getItems(checklists.first.id!);
    expect(items, hasLength(8));

    final now = DateTime(2026, 11, 13);
    final runId = await repo.saveRun(
      InspectionRun(
        vehicleId: vehicleId,
        checklistId: checklists.first.id!,
        date: now,
        odometer: 1000,
        notes: 'Todo bien',
        createdAt: now,
      ),
      [
        for (final item in items)
          InspectionAnswer(runId: 0, itemId: item.id!, status: 'ok'),
      ],
    );

    final runs = await repo.getRunsForVehicle(vehicleId);
    expect(runs, hasLength(1));
    expect(runs.first.notes, 'Todo bien');
    expect(await repo.getAnswers(runId), hasLength(8));

    await repo.deleteRun(runId);
    expect(await repo.getRunsForVehicle(vehicleId), isEmpty);
    expect(await repo.getAnswers(runId), isEmpty);
  });
}
