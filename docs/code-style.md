# Estilo de Código

## Imports

```dart
// EXTERNOS: imports de paquete
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// INTERNOS: imports relativos (no usar package:motorcheck/...)
import '../../../core/theme/app_colors.dart';
import '../widgets/vehicle_card.dart';
import '../providers.dart';
```

## Formateo

- Usar `dart format .` (80 chars por línea)
- Coma final siempre (`require_trailing_commas`)

## Nombrado

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Archivos | `snake_case.dart` | `vehicle_form_screen.dart` |
| Clases | `PascalCase` | `VehicleFormScreen` |
| Variables/Métodos | `camelCase` | `selectedVehicleId`, `loadVehicles()` |
| Constantes | `camelCase` estáticas | `AppColors.primary` |
| Providers | sufijo `Provider` | `vehiclesProvider` |
| Notifiers | sufijo `Notifier` | `VehiclesNotifier` |

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

  const VehicleCard({super.key, required this.vehicle, required this.onTap});
  // ...
}
```

## Manejo de Estado Asíncrono

Siempre usar `.when()` para `AsyncValue`:

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

## Manejo de Errores

- Usar `AsyncValue.guard()` en notifiers para capturar excepciones automáticamente
- Mostrar `ErrorState` widget con botón de reintentar en la UI
- Nunca usar `try/catch` vacío; siempre mostrar feedback al usuario

## Navegación

- `context.push('/ruta')` para navegar a sub-rutas dentro del mismo branch
- `context.pop()` para volver atrás
- `context.go('/ruta')` solo para cambiar de tab en la barra inferior
