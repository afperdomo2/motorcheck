import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_status.dart';
import '../../core/utils/formatters.dart';
import '../settings/providers.dart';
import '../settings/models/maintenance_category.dart';
import '../vehicles/providers.dart';
import '../vehicles/models/vehicle.dart';
import 'models/maintenance.dart';
import 'models/maintenance_item.dart';
import 'models/workshop.dart';
import 'repository.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return MaintenanceRepository();
});

final maintenancesProvider = FutureProvider<List<Maintenance>>((ref) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getAll();
});

final maintenanceItemsProvider =
    FutureProvider.family<List<MaintenanceItem>, int>((
      ref,
      maintenanceId,
    ) async {
      final repository = ref.watch(maintenanceRepositoryProvider);
      return repository.getItems(maintenanceId);
    });

final maintenanceByIdProvider = FutureProvider.family<Maintenance?, int>((
  ref,
  maintenanceId,
) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getById(maintenanceId);
});

final vehicleNamesProvider = FutureProvider<Map<int, Vehicle>>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  return {for (final v in vehicles) v.id!: v};
});

class MaintenancesNotifier extends Notifier<AsyncValue<List<Maintenance>>> {
  MaintenanceRepository get _repo => ref.read(maintenanceRepositoryProvider);

  @override
  AsyncValue<List<Maintenance>> build() {
    _load();
    return const AsyncValue.data([]);
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repo.getAll());
    ref.invalidate(workshopItemsProvider);
  }

  Future<void> loadMaintenances() => _load();

  Future<void> add(Maintenance maintenance, List<MaintenanceItem> items) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(maintenance, items);
      return _repo.getAll();
    });
    _invalidateDependentProviders();
  }

  Future<void> update(
    Maintenance maintenance,
    List<MaintenanceItem> items,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.update(maintenance, items);
      return _repo.getAll();
    });
    _invalidateDependentProviders();
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    state = AsyncValue.data(await _repo.getAll());
    _invalidateDependentProviders();
  }

  void _invalidateDependentProviders() {
    ref.invalidate(maintenancesProvider);
    ref.invalidate(workshopItemsProvider);
    ref.invalidate(maintenanceByIdProvider);
    ref.invalidate(maintenanceItemsProvider);
    ref.invalidate(vehicleMaintenanceSummaryProvider);
    ref.invalidate(upcomingMaintenanceProvider);
    ref.invalidate(maintenanceAttentionCountProvider);
    ref.invalidate(vehicleNamesProvider);

    // El repositorio pudo subir el kilometraje del vehículo.
    ref.invalidate(vehiclesNotifierProvider);
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(selectedVehicleProvider);
  }
}

final vehicleMaintenanceSummaryProvider =
    FutureProvider.family<
      ({int count, double totalCost, DateTime? lastDate}),
      int
    >((ref, vehicleId) async {
      final repository = ref.watch(maintenanceRepositoryProvider);
      return repository.getMaintenanceSummary(vehicleId);
    });

final maintenancesNotifierProvider =
    NotifierProvider<MaintenancesNotifier, AsyncValue<List<Maintenance>>>(
      MaintenancesNotifier.new,
    );

final workshopsProvider = FutureProvider<List<Workshop>>((ref) async {
  final repository = ref.watch(workshopRepositoryProvider);
  return repository.getAll();
});

final workshopItemsProvider =
    FutureProvider.family<Map<int, List<MaintenanceItem>>, String>((
      ref,
      idsKey,
    ) async {
      if (idsKey.isEmpty) return {};
      final maintenanceIds = idsKey.split(',').map(int.parse).toList();
      final repository = ref.watch(maintenanceRepositoryProvider);
      final items = await repository.getItemsByMaintenanceIds(maintenanceIds);
      final result = <int, List<MaintenanceItem>>{};
      for (final item in items) {
        result.putIfAbsent(item.maintenanceId, () => []).add(item);
      }
      return result;
    });

class UpcomingMaintenance {
  final MaintenanceCategory category;
  final int? lastMileage;
  final int? lastDate;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final int? remainingKm;
  final int? remainingDays;
  final bool isOverdue;
  final bool isWarning;
  final bool kmOverdue;
  final bool dateOverdue;
  final bool kmWarning;
  final bool dateWarning;
  final bool needsMileage;

  const UpcomingMaintenance({
    required this.category,
    this.lastMileage,
    this.lastDate,
    this.lastServiceDate,
    this.nextServiceDate,
    this.remainingKm,
    this.remainingDays,
    this.isOverdue = false,
    this.isWarning = false,
    this.kmOverdue = false,
    this.dateOverdue = false,
    this.kmWarning = false,
    this.dateWarning = false,
    this.needsMileage = false,
  });

  bool get hasInterval =>
      category.intervalKm != null || category.intervalMonths != null;

  bool get hasRecord => lastMileage != null || lastServiceDate != null;

  String statusLabel() {
    if (!hasInterval) return 'Sin frecuencia';
    if (!hasRecord) return 'Sin registro previo';
    if (needsMileage) return 'Falta kilometraje';

    if (isOverdue) {
      final parts = <String>[];
      if (kmOverdue && remainingKm != null) {
        parts.add('${-remainingKm!} km');
      }
      if (dateOverdue && remainingDays != null) {
        parts.add('${-remainingDays!} días');
      }
      return parts.isEmpty ? 'Vencido' : 'Vencido hace ${parts.join(' · ')}';
    }

    if (remainingDays == 0 && remainingKm == null) return 'Vence hoy';

    final parts = <String>[];
    if (remainingKm != null) parts.add('$remainingKm km');
    if (remainingDays != null) {
      parts.add(remainingDays == 0 ? 'hoy' : '$remainingDays días');
    }
    if (parts.isEmpty) return 'Al día';
    return 'En ${parts.join(' · ')}';
  }

  String? lastDateFormatted() {
    final date =
        lastServiceDate ??
        (lastDate != null
            ? DateTime.fromMillisecondsSinceEpoch(lastDate!)
            : null);
    return date != null ? formatDate(date) : null;
  }

  String? nextDateFormatted() {
    final date = nextServiceDate;
    return date != null ? formatDisplayDate(date) : null;
  }
}

/// Suma meses conservando el día cuando es posible (31 ene + 1 mes = 28/29 feb).
DateTime addMonths(DateTime date, int months) {
  final total = date.month - 1 + months;
  final year = date.year + total ~/ 12;
  final month = total % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day <= lastDay ? date.day : lastDay;
  return DateTime(year, month, day);
}

final maintenanceCategoryHistoryProvider =
    FutureProvider.family<
      List<CategoryHistoryEntry>,
      ({int vehicleId, String category})
    >((ref, args) async {
      final repository = ref.watch(maintenanceRepositoryProvider);
      return repository.getCategoryHistory(args.vehicleId, args.category);
    });

/// Cantidad de mantenimientos vencidos o próximos a vencer en todos los
/// vehículos. Se usa para el badge de la barra de navegación.
final maintenanceAttentionCountProvider = FutureProvider<int>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  var count = 0;

  for (final vehicle in vehicles) {
    final id = vehicle.id;
    if (id == null) continue;
    final upcoming = await ref.watch(upcomingMaintenanceProvider(id).future);
    count += upcoming.where((item) => item.isOverdue || item.isWarning).length;
  }

  return count;
});

final upcomingMaintenanceProvider =
    FutureProvider.family<List<UpcomingMaintenance>, int>((
      ref,
      vehicleId,
    ) async {
      final vehicle = await ref.watch(
        selectedVehicleProvider(vehicleId).future,
      );
      if (vehicle == null) return [];

      final currentMileage = vehicle.currentMileage;

      final catRepo = ref.read(maintenanceCategoryRepositoryProvider);
      final categories = await catRepo.getByVehicleType(vehicle.type);

      final maintRepo = ref.read(maintenanceRepositoryProvider);
      final stats = await ref
          .read(mileageRepositoryProvider)
          .getStats(vehicleId);
      final result = <UpcomingMaintenance>[];

      for (final cat in categories) {
        final last = await maintRepo.getLastServiceByCategory(
          vehicleId,
          cat.key,
        );

        final hasInterval =
            cat.intervalKm != null || cat.intervalMonths != null;
        if (!hasInterval) {
          result.add(
            UpcomingMaintenance(
              category: cat,
              lastMileage: last.mileage,
              lastDate: last.date?.millisecondsSinceEpoch,
              lastServiceDate: last.date,
            ),
          );
          continue;
        }

        if (last.date == null && last.mileage == null) {
          result.add(UpcomingMaintenance(category: cat));
          continue;
        }

        final needsMileage = cat.intervalKm != null && currentMileage == null;

        int? remainingKm;
        var kmOverdue = false;
        var kmWarning = false;
        if (cat.intervalKm != null &&
            last.mileage != null &&
            currentMileage != null) {
          final nextServiceKm = last.mileage! + cat.intervalKm!;
          remainingKm = nextServiceKm - currentMileage;
          kmOverdue = remainingKm < 0;
          kmWarning = !kmOverdue && remainingKm <= (cat.warningKm ?? 0);
        }

        DateTime? nextServiceDate;
        int? remainingDays;
        var dateOverdue = false;
        var dateWarning = false;
        if (cat.intervalMonths != null && last.date != null) {
          nextServiceDate = addMonths(last.date!, cat.intervalMonths!);
          remainingDays = DateStatus.daysUntil(nextServiceDate);
          dateOverdue = remainingDays < 0;
          dateWarning =
              !dateOverdue && remainingDays <= (cat.warningDays ?? 30);
        }

        // Si solo hay frecuencia por km, se estima la fecha con el ritmo
        // real de uso del vehículo.
        if (nextServiceDate == null && remainingKm != null) {
          nextServiceDate = stats.estimatedDateFor(remainingKm);
          if (nextServiceDate != null) {
            remainingDays = DateStatus.daysUntil(nextServiceDate);
          }
        }

        final isOverdue = kmOverdue || dateOverdue;
        final isWarning = !isOverdue && (kmWarning || dateWarning);

        result.add(
          UpcomingMaintenance(
            category: cat,
            lastMileage: last.mileage,
            lastDate: last.date?.millisecondsSinceEpoch,
            lastServiceDate: last.date,
            nextServiceDate: nextServiceDate,
            remainingKm: remainingKm,
            remainingDays: remainingDays,
            isOverdue: isOverdue,
            isWarning: isWarning,
            kmOverdue: kmOverdue,
            dateOverdue: dateOverdue,
            kmWarning: kmWarning,
            dateWarning: dateWarning,
            needsMileage: needsMileage,
          ),
        );
      }

      result.sort(_compareUpcoming);
      return result;
    });

int _compareUpcoming(UpcomingMaintenance a, UpcomingMaintenance b) {
  int severity(UpcomingMaintenance item) {
    if (item.isOverdue) return 0;
    if (item.isWarning) return 1;
    if (item.hasRecord) return 2;
    return 3;
  }

  final bySeverity = severity(a).compareTo(severity(b));
  if (bySeverity != 0) return bySeverity;

  final daysA = a.remainingDays ?? 1 << 30;
  final daysB = b.remainingDays ?? 1 << 30;
  if (daysA != daysB) return daysA.compareTo(daysB);

  final kmA = a.remainingKm ?? 1 << 30;
  final kmB = b.remainingKm ?? 1 << 30;
  return kmA.compareTo(kmB);
}
