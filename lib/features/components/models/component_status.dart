import '../../../core/utils/formatters.dart';
import 'vehicle_component.dart';

/// Estado calculado de un componente frente al kilometraje y la fecha actuales.
///
/// Se calcula por kilometraje, por meses o por ambos. Cuando hay dos
/// intervalos, manda el que ocurra primero.
class ComponentStatus {
  const ComponentStatus({
    required this.component,
    this.currentMileage,
    this.nextKm,
    this.nextDate,
    this.remainingKm,
    this.remainingDays,
  });

  final VehicleComponent component;
  final int? currentMileage;
  final int? nextKm;
  final DateTime? nextDate;
  final int? remainingKm;
  final int? remainingDays;

  bool get hasMileageInterval =>
      component.intervalKm != null && component.installedKm != null;

  bool get hasDateInterval => component.intervalMonths != null;

  bool get hasInterval => hasMileageInterval || hasDateInterval;

  bool get isInactive => !component.active;

  bool get kmOverdue => remainingKm != null && remainingKm! < 0;

  bool get dateOverdue => remainingDays != null && remainingDays! < 0;

  bool get isOverdue =>
      component.active && hasInterval && (kmOverdue || dateOverdue);

  bool get kmWarning {
    final threshold = component.warningKm;
    if (threshold == null || remainingKm == null || kmOverdue) return false;
    return remainingKm! <= threshold;
  }

  bool get dateWarning {
    final threshold = component.warningDays;
    if (threshold == null || remainingDays == null || dateOverdue) return false;
    return remainingDays! <= threshold;
  }

  bool get isWarning =>
      component.active &&
      hasInterval &&
      !isOverdue &&
      (kmWarning || dateWarning);

  bool get isOk => component.active && hasInterval && !isOverdue && !isWarning;

  /// `true` cuando el componente no genera avisos por falta de configuración.
  bool get isInformational => !hasInterval;

  /// Palabra corta para chips: Vencido, Próximo, Al día.
  String get statusWord {
    if (isInactive) return 'Inactivo';
    if (isInformational) return 'Sin frecuencia';
    if (isOverdue) return 'Vencido';
    if (isWarning) return 'Próximo';
    return 'Al día';
  }

  /// Etiqueta compacta con lo que ocurre primero: "En 300 km", "En 12 días".
  String get primaryLabel {
    if (isInactive) return 'Inactivo';
    if (isInformational) return 'Sin frecuencia';

    if (isOverdue) {
      final parts = <String>[];
      if (kmOverdue) parts.add(formatMileage(-remainingKm!));
      if (dateOverdue) parts.add('${-remainingDays!} días');
      return 'Vencido hace ${parts.join(' · ')}';
    }

    final kmRatio = _kmRatio;
    final dateRatio = _dateRatio;
    if (kmRatio == null && dateRatio == null) return 'Al día';
    final preferKm =
        kmRatio != null && (dateRatio == null || kmRatio <= dateRatio);
    if (preferKm) return 'En ${formatMileage(remainingKm)}';
    return remainingDays == 0 ? 'Vence hoy' : 'En $remainingDays días';
  }

  String? get remainingKmLabel {
    if (remainingKm == null) return null;
    if (remainingKm! < 0) {
      return 'Vencido hace ${formatMileage(-remainingKm!)}';
    }
    return 'En ${formatMileage(remainingKm)}';
  }

  String? get remainingDaysLabel {
    if (remainingDays == null) return null;
    if (remainingDays! < 0) return 'Vencido hace ${-remainingDays!} días';
    if (remainingDays == 0) return 'Vence hoy';
    return 'En $remainingDays días';
  }

  String? get nextKmLabel {
    if (nextKm == null) return null;
    return formatMileage(nextKm);
  }

  String? get nextDateLabel {
    if (nextDate == null) return null;
    return formatDisplayDate(nextDate!);
  }

  double? get _kmRatio {
    if (!hasMileageInterval || remainingKm == null) return null;
    final interval = component.intervalKm!;
    if (interval <= 0) return null;
    return remainingKm! / interval;
  }

  double? get _dateRatio {
    if (!hasDateInterval || remainingDays == null) return null;
    final intervalDays = component.intervalMonths! * 30.4375;
    if (intervalDays <= 0) return null;
    return remainingDays! / intervalDays;
  }
}

/// Construye el estado de [component] con el kilometraje y la fecha actuales.
ComponentStatus componentStatusFor(
  VehicleComponent component, {
  int? currentMileage,
  DateTime? today,
}) {
  final base = today ?? DateTime.now();

  int? nextKm;
  int? remainingKm;
  if (component.intervalKm != null && component.installedKm != null) {
    nextKm = component.installedKm! + component.intervalKm!;
    if (currentMileage != null) {
      remainingKm = nextKm - currentMileage;
    }
  }

  DateTime? nextDate;
  int? remainingDays;
  if (component.intervalMonths != null) {
    final installed = component.installedAt;
    nextDate = DateTime(
      installed.year,
      installed.month + component.intervalMonths!,
      installed.day,
    );
    final baseDay = DateTime(base.year, base.month, base.day);
    final targetDay = DateTime(nextDate.year, nextDate.month, nextDate.day);
    remainingDays = targetDay.difference(baseDay).inDays;
  }

  return ComponentStatus(
    component: component,
    currentMileage: currentMileage,
    nextKm: nextKm,
    nextDate: nextDate,
    remainingKm: remainingKm,
    remainingDays: remainingDays,
  );
}

/// Ordena primero los vencidos, luego los próximos y al final los informativos.
int compareComponentStatus(ComponentStatus a, ComponentStatus b) {
  int rank(ComponentStatus status) {
    if (status.isInactive) return 3;
    if (status.isOverdue) return 0;
    if (status.isWarning) return 1;
    if (status.isInformational) return 3;
    return 2;
  }

  final byRank = rank(a).compareTo(rank(b));
  if (byRank != 0) return byRank;
  final kmA = a.remainingKm ?? 1 << 30;
  final kmB = b.remainingKm ?? 1 << 30;
  if (kmA != kmB) return kmA.compareTo(kmB);
  final daysA = a.remainingDays ?? 1 << 30;
  final daysB = b.remainingDays ?? 1 << 30;
  return daysA.compareTo(daysB);
}
