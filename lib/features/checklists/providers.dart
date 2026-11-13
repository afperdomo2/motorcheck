import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../vehicles/providers.dart';
import 'models/checklist.dart';
import 'models/checklist_item.dart';
import 'models/inspection_answer.dart';
import 'models/inspection_run.dart';
import 'repository.dart';

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return ChecklistRepository();
});

final checklistsForVehicleProvider =
    FutureProvider.family<List<Checklist>, int>((ref, vehicleId) async {
      final vehicle = await ref.watch(
        selectedVehicleProvider(vehicleId).future,
      );
      if (vehicle == null) return [];
      return ref
          .watch(checklistRepositoryProvider)
          .getForVehicle(vehicleId, vehicle.type);
    });

final checklistByIdProvider = FutureProvider.family<Checklist?, int>((
  ref,
  checklistId,
) async {
  return ref.watch(checklistRepositoryProvider).getChecklistById(checklistId);
});

final checklistItemsProvider = FutureProvider.family<List<ChecklistItem>, int>((
  ref,
  checklistId,
) async {
  return ref.watch(checklistRepositoryProvider).getItems(checklistId);
});

final inspectionRunsProvider = FutureProvider.family<List<InspectionRun>, int>((
  ref,
  vehicleId,
) async {
  return ref.watch(checklistRepositoryProvider).getRunsForVehicle(vehicleId);
});

final inspectionRunByIdProvider = FutureProvider.family<InspectionRun?, int>((
  ref,
  runId,
) async {
  return ref.watch(checklistRepositoryProvider).getRunById(runId);
});

final inspectionAnswersProvider =
    FutureProvider.family<List<InspectionAnswer>, int>((ref, runId) async {
      return ref.watch(checklistRepositoryProvider).getAnswers(runId);
    });

class InspectionDetail {
  const InspectionDetail({
    required this.run,
    required this.answers,
    required this.items,
  });

  final InspectionRun run;
  final List<InspectionAnswer> answers;
  final List<ChecklistItem> items;
}

final inspectionDetailProvider = FutureProvider.family<InspectionDetail?, int>((
  ref,
  runId,
) async {
  final repo = ref.watch(checklistRepositoryProvider);
  final run = await repo.getRunById(runId);
  if (run == null) return null;
  final answers = await repo.getAnswers(runId);
  final items = await repo.getItems(run.checklistId);
  return InspectionDetail(run: run, answers: answers, items: items);
});

class InspectionsNotifier extends Notifier<AsyncValue<void>> {
  ChecklistRepository get _repo => ref.read(checklistRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(
    int vehicleId,
    InspectionRun run,
    List<InspectionAnswer> answers,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repo.saveRun(run, answers);
      ref.invalidate(inspectionRunsProvider(vehicleId));
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(int runId, int vehicleId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteRun(runId);
      ref.invalidate(inspectionRunsProvider(vehicleId));
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final inspectionsNotifierProvider =
    NotifierProvider<InspectionsNotifier, AsyncValue<void>>(
      InspectionsNotifier.new,
    );
