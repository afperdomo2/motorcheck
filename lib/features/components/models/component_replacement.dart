/// Reemplazo de un componente registrado dentro de un mantenimiento.
///
/// El mantenimiento es la cuenta (mano de obra + repuestos); esta fila solo
/// enlaza el ítem con la pieza y aporta fecha y kilometraje al historial.
class ComponentReplacement {
  const ComponentReplacement({
    required this.componentId,
    required this.maintenanceId,
    required this.date,
    this.mileage,
    this.partsCost = 0,
    this.notes,
  });

  final int componentId;
  final int maintenanceId;
  final DateTime date;
  final int? mileage;
  final double partsCost;
  final String? notes;
}
