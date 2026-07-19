import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../maintenance/models/workshop.dart';
import 'repository.dart';

final workshopRepositoryProvider = Provider<WorkshopRepository>((ref) {
  return WorkshopRepository();
});

final workshopsListProvider = FutureProvider<List<Workshop>>((ref) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getAll();
});

class WorkshopsNotifier extends Notifier<AsyncValue<List<Workshop>>> {
  WorkshopRepository get _repo => ref.read(workshopRepositoryProvider);

  @override
  AsyncValue<List<Workshop>> build() {
    _load();
    return const AsyncValue.data([]);
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repo.getAll());
  }

  Future<void> loadWorkshops() => _load();

  Future<void> add(String name, {String? location}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(name, location: location);
      return _repo.getAll();
    });
  }

  Future<void> update(Workshop workshop) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.update(workshop);
      return _repo.getAll();
    });
  }

  Future<void> remove(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.delete(id);
      return _repo.getAll();
    });
  }
}

final workshopsNotifierProvider =
    NotifierProvider<WorkshopsNotifier, AsyncValue<List<Workshop>>>(
      WorkshopsNotifier.new,
    );
