class HealthScore {
  const HealthScore({
    required this.value,
    required this.label,
    required this.reasons,
    this.hasData = true,
  });

  final int value;
  final String label;
  final List<String> reasons;
  final bool hasData;
}

HealthScore scoreFrom({
  required int overdueMaintenances,
  required int warningMaintenances,
  required int expiredDocuments,
  required int expiringDocuments,
  required int? daysSinceMileageUpdate,
  int overdueComponents = 0,
  int warningComponents = 0,
}) {
  var score = 100;
  score -= (overdueMaintenances * 12).clamp(0, 36);
  score -= (warningMaintenances * 4).clamp(0, 16);
  score -= (expiredDocuments * 15).clamp(0, 30);
  score -= (expiringDocuments * 5).clamp(0, 15);
  score -= (overdueComponents * 8).clamp(0, 24);
  score -= (warningComponents * 3).clamp(0, 12);
  if (daysSinceMileageUpdate != null && daysSinceMileageUpdate > 60) {
    score -= 10;
  }
  final clamped = score.clamp(0, 100);

  final label = switch (clamped) {
    >= 90 => 'Al día',
    >= 70 => 'Atención',
    >= 40 => 'Riesgo',
    _ => 'Crítico',
  };

  return HealthScore(value: clamped, label: label, reasons: const []);
}
