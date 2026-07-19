# MotorCheck - Instrucciones para Agentes

## Resumen

MotorCheck es una app Flutter para seguimiento de mantenimiento de vehículos.
Usuario único, SQLite local, sin backend ni autenticación.

## Comandos

```bash
flutter pub get                              # Instalar dependencias
dart run build_runner build --delete-conflicting-outputs  # Generar código (freezed/riverpod)
dart run build_runner watch --delete-conflicting-outputs  # Modo watch (recomendado)
dart format .                                # Formatear (80 chars, trailing commas)
flutter analyze                              # Análisis estático (REQUERIDO antes de commit)
flutter test                                 # Todas las pruebas
flutter test test/features/vehicles/         # Pruebas por feature
flutter test --name "formatea"               # Por nombre (regex, busca en todos los archivos)
flutter test test/core/utils/formatters_test.dart  # Archivo específico
flutter test --concurrency 1                 # Evitar race conditions en SQLite
flutter test --coverage                      # Con cobertura
flutter run                                  # Ejecutar en dispositivo
flutter clean                                # Limpiar caché
```

## Reglas de Trabajo

1. **Antes de commit**: `flutter analyze` (cero issues), `dart format .`, `flutter test`
2. **Después de modificar modelos/providers**: ejecutar `build_runner` inmediatamente
3. **Constructores const**: siempre en widgets estáticos, EdgeInsets, SizedBox, bordes, etc.
4. **Patrón Smart/Dumb**: pantallas + providers = smart, widgets = dumb (datos + callbacks)
5. **Archivos**: snake_case. **Clases**: PascalCase. **Providers**: sufijo `Provider`
6. **Imports**: relativos para archivos del proyecto, `package:` para dependencias externas
7. **Riverpod**: `ConsumerWidget`/`ConsumerStatefulWidget` para UI, `Notifier` para estado
8. **Modelos**: `@freezed` para inmutabilidad, igualdad, `copyWith`, JSON
9. **Estado asíncrono**: siempre usar `AsyncValue.when()` con loading/error/data
10. **Errores**: `AsyncValue.guard()` en notifiers, nunca `try/catch` vacío
11. **`context.mounted`**: siempre verificar después de `await` antes de usar `context`
12. **UI en español**: todos los strings visibles y descripciones de test en español

## Convenciones de Código

### Orden de Imports (3 bloques, separados por línea vacía)

```dart
// 1. Dependencias externas (package:)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2. Core, shared y cross-feature del proyecto (relativos)
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/error_state.dart';
import '../../vehicles/providers.dart';

// 3. Mismo feature (relativos)
import '../models/maintenance.dart';
import '../widgets/timeline_tile.dart';
```

**Nota**: los tests usan `package:motorcheck/...` para imports del proyecto (nunca relativos en tests).

### Nombrado

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Archivos | `snake_case.dart` | `vehicle_form_screen.dart` |
| Clases | `PascalCase` | `VehicleFormScreen` |
| Variables/Métodos | `camelCase` | `selectedVehicleId` |
| Providers (datos) | `{entity}Provider` | `vehiclesProvider` |
| Providers (familia) | `{entity}ByIdProvider` | `maintenanceByIdProvider` |
| Providers (repositorio) | `{entity}RepositoryProvider` | `vehicleRepositoryProvider` |
| Notifiers (clase) | `{EntityPlural}Notifier` | `VehiclesNotifier` |
| Notifiers (provider) | `{entityPlural}NotifierProvider` | `vehiclesNotifierProvider` |
| Modelos freezed | `@freezed class Vehicle with _$Vehicle` | constructor `factory Vehicle(...)` |

### Modelos Freezed

```dart
@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    int? id,                              // siempre nullable (SQLite autoincrement)
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

### Estado Asíncrono

```dart
// En pantallas: siempre usar .when() para cubrir loading/error/data
vehiclesAsync.when(
  loading: () => const LoadingIndicator(),
  error: (err, _) => ErrorState(
    message: err.toString(),
    onRetry: () => ref.invalidate(vehiclesProvider),
  ),
  data: (vehicles) {
    if (vehicles.isEmpty) return const EmptyState(...);
    return ListView(...);
  },
);

// Acceso síncrono rápido (solo cuando no se necesita loading/error)
final vehicles = vehiclesAsync.valueOrNull ?? [];
```

### Dart 3 Features

- **Switch expressions** para mapeos:
  ```dart
  IconData icon = switch (type) { 'motorcycle' => Icons.motorcycle, _ => Icons.car };
  ```
- **Records** para retorno de diálogos:
  ```dart
  ({String name, String? location})? result = await showDialog(...);
  ```
- **Cascade `..`** para mutaciones: `_items..clear()..addAll(items);`
- **`withValues(alpha: ...)`** en lugar de `withOpacity()`: `color.withValues(alpha: 0.15)`

### Navegación

| Acción | Método |
|--------|--------|
| Sub-ruta (formulario) | `context.push('/ruta')` |
| Volver atrás | `context.pop()` |
| Cambiar tab | `context.go('/ruta')` |

## Seguridad Operativa

- **NUNCA hacer commits**: los commits solo los crea el usuario. No usar `git add`, `git commit`, ni `git push`
- **No ejecutar `flutter test` ni `flutter analyze`** tras cambios exclusivamente en archivos `.md`
- **No ejecutar comandos destructivos** sin confirmación (`git push --force`, `flutter clean` sin preguntar)

## Arquitectura

```
lib/
├── main.dart | app.dart           # Entry point + MaterialApp.router
├── core/
│   ├── theme/                     # Colores, tema, tipografía
│   ├── database/                  # SQLite helper + DDL
│   └── utils/                     # Formateadores, extensiones
├── features/
│   ├── vehicles/                  # CRUD vehículos + selección default
│   ├── maintenance/               # CRUD mantenimientos + items
│   └── dashboard/                 # Resumen del vehículo default
├── shared/widgets/                # Componentes dumb reutilizables
└── routes/                        # GoRouter (StatefulShellRoute)
```

### Feature típica

```
features/vehicles/
├── models/vehicle.dart            # @freezed
├── repository.dart                # Acceso SQLite
├── providers.dart                 # Riverpod providers + Notifiers
├── screens/                       # Pantallas (smart)
└── widgets/                       # Componentes (dumb)
```

## Tests

### Ejecución

```bash
flutter test                                    # Todas las pruebas
flutter test test/features/vehicles/            # Por feature o archivo
flutter test --name "formatea"                  # Por nombre (regex)
flutter test --concurrency 1                    # Evitar race conditions SQLite
```

### Convenciones

- Archivos: `{nombre}_test.dart` bajo `test/`, reflejando la estructura de `lib/`
- Imports del proyecto en tests: siempre `package:motorcheck/...` (absolutos, no relativos)
- Usar `group()` por función/modelo; descripciones en español
- SQLite en tests: `sqflite_common_ffi` + `sqfliteFfiInit()` en `setUpAll`
- Mocks: `mocktail` (sin code-gen); `class MockRepo extends Mock implements Repo {}`

## Skills

| Skill | Ruta | Cuándo usar |
|-------|------|-------------|
| flutter-expert | `.agents/skills/flutter-expert/` | Widgets, estado, navegación, rendimiento |
| flutter-animations | `.agents/skills/flutter-animations/` | Animaciones, transiciones |
| dart-best-practices | `.agents/skills/dart-best-practices/` | Convenciones, features del lenguaje |

## MCPs

### Context7 MCP
Documentación actualizada de Riverpod, GoRouter, sqflite, freezed, etc.
Siempre resolver ID primero (`context7_resolve-library-id`), luego `context7_query-docs`.

### Dart MCP Server
Configurado en `opencode.json`. Funcionalidades:
- `dart-mcp-server_analyze_files` — analizar archivos específicos post-edición
- `dart-mcp-server_pub_dev_search` — buscar paquetes antes de agregar dependencias
- `dart-mcp-server_pub` — `pub add`, `pub get`, `pub upgrade`
- `dart-mcp-server_lsp` — hover, signature help, resolve workspace symbols
- `dart-mcp-server_dtd` — hot reload/restart, widget inspector en apps conectadas
- `dart-mcp-server_flutter_driver_command` — interacción con widgets en ejecución

## Documentación

| Documento | Contenido |
|-----------|-----------|
| `docs/architecture.md` | Stack, estructura, patrón Smart/Dumb, flujo de datos |
| `docs/database.md` | Esquema SQL, tablas, relaciones |
| `docs/code-style.md` | Imports, nombrado, widgets, estado asíncrono, errores |
| `docs/design-system.md` | Colores, tipografía, espaciado, componentes base |
| `docs/testing.md` | Estrategia, ejecución, mocktail, SQLite en memoria |
