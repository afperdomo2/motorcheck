# Estilo de Código

## Imports

```dart
// EXTERNOS: imports de paquete (1er bloque)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// INTERNOS: core, shared y cross-feature — imports relativos (2do bloque)
import '../../../core/theme/app_colors.dart';
import '../../vehicles/providers.dart';
import '../../../shared/widgets/error_state.dart';

// INTERNOS: mismo feature — imports relativos (3er bloque)
import '../widgets/vehicle_card.dart';
import '../providers.dart';
```

**Excepción**: en **tests** se usa `package:motorcheck/...` para imports del proyecto (nunca relativos).

## Formateo

- Usar `dart format .` (80 chars por línea)
- Coma final siempre (`require_trailing_commas`)
- Comillas simples (`prefer_single_quotes`)
- `withValues(alpha: ...)` en vez de `withOpacity()`
- `SizedBox(width/height:)` en vez de `Container` (`sized_box_for_whitespace`)
- Propiedades de widget al final (`sort_child_properties_last`)
- Archivos generados excluidos: `*.g.dart`, `*.freezed.dart`

## Nombrado

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Archivos | `snake_case.dart` | `vehicle_form_screen.dart` |
| Clases | `PascalCase` | `VehicleFormScreen` |
| Variables/Métodos | `camelCase` | `selectedVehicleId`, `loadVehicles()` |
| Providers (datos) | `{entity}Provider` | `vehiclesProvider` |
| Providers (familia) | `{entity}ByIdProvider` | `maintenanceByIdProvider` |
| Providers (repositorio) | `{entity}RepositoryProvider` | `vehicleRepositoryProvider` |
| Notifiers (clase) | `{EntityPlural}Notifier` | `VehiclesNotifier` |
| Notifiers (provider) | `{entityPlural}NotifierProvider` | `vehiclesNotifierProvider` |

## Widgets

### Smart: pantallas con ConsumerWidget/ConsumerStatefulWidget

```dart
class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(someProvider); // watch para lectura reactiva
    // ...
  }
}
```

### Dumb: widgets que reciben datos + callbacks, nunca providers

```dart
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback? onSetDefault;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.onSetDefault,
  });
  // ...
}
```

## Modelos Freezed

```dart
@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    int? id,                              // nullable (SQLite autoincrement)
    required String name,                 // required para campos obligatorios
    @Default('car') String type,          // @Default para valores por defecto
    @Default(false) bool isDefault,
    @Default(0) double maintenanceCost,
    required DateTime createdAt,          // timestamps siempre required
    required DateTime updatedAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
```

## Manejo de Estado Asíncrono

Siempre usar `AsyncValue.when()` con los 3 estados:

```dart
vehiclesAsync.when(
  loading: () => const LoadingIndicator(),
  error: (err, _) => ErrorState(
    message: err.toString(),
    onRetry: () => ref.invalidate(provider),
  ),
  data: (vehicles) {
    if (vehicles.isEmpty) return EmptyState(...);
    return ListView(...);
  },
);
```

- `valueOrNull` solo para acceso síncrono rápido sin necesidad de loading/error.
- `AsyncValue.guard()` en notifiers para capturar excepciones.

## Manejo de Errores

- Usar `AsyncValue.guard()` en notifiers para capturar excepciones automáticamente
- Mostrar `ErrorState` widget con botón de reintentar en la UI
- **Nunca** usar `try/catch` vacío; siempre mostrar feedback al usuario
- Verificar `context.mounted` después de `await` antes de usar `context`

## Navegación

| Acción | Método |
|--------|--------|
| Sub-ruta (formulario) | `context.push('/ruta')` |
| Volver atrás | `context.pop()` |
| Cambiar tab | `context.go('/ruta')` |

## Dart 3 Features

- **Switch expressions** para mapeos tipo→ícono o tipo→color
- **Records** para retorno de diálogos tipados
- **Cascade `..`** para mutaciones de colecciones

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
