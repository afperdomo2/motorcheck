import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../maintenance/models/workshop.dart';
import 'models/maintenance_category.dart';
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

final maintenanceCategoryRepositoryProvider =
    Provider<MaintenanceCategoryRepository>((ref) {
      return MaintenanceCategoryRepository();
    });

final maintenanceCategoriesProvider = FutureProvider<List<MaintenanceCategory>>(
  (ref) async {
    final repository = ref.watch(maintenanceCategoryRepositoryProvider);
    return repository.getAll();
  },
);

class MaintenanceCategoriesNotifier
    extends Notifier<AsyncValue<List<MaintenanceCategory>>> {
  MaintenanceCategoryRepository get _repo =>
      ref.read(maintenanceCategoryRepositoryProvider);

  @override
  AsyncValue<List<MaintenanceCategory>> build() {
    _load();
    return const AsyncValue.data([]);
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repo.getAll());
  }

  Future<void> loadCategories() => _load();

  Future<void> add(MaintenanceCategory category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(category);
      return _repo.getAll();
    });
  }

  Future<void> update(MaintenanceCategory category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.update(category);
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

final maintenanceCategoriesNotifierProvider =
    NotifierProvider<
      MaintenanceCategoriesNotifier,
      AsyncValue<List<MaintenanceCategory>>
    >(MaintenanceCategoriesNotifier.new);
