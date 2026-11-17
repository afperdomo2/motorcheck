import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FinanceSection { summary, fuel, expenses }

/// Sección visible de Gastos. Vive fuera de la pantalla para que Inicio pueda
/// abrir directamente una sección desde una alerta.
final financeSectionProvider = StateProvider<FinanceSection>(
  (ref) => FinanceSection.summary,
);
