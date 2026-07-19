# MotorCheck - Instrucciones para Agentes

## Resumen

MotorCheck es una app Flutter para seguimiento de mantenimiento de vehículos.
Usuario único, SQLite local, sin backend ni autenticación.

## Comandos

```bash
flutter pub get                              # Instalar dependencias
dart run build_runner build --delete-conflicting-outputs  # Generar código (freezed/ riverpod)
dart run build_runner watch --delete-conflicting-outputs  # Modo watch (recomendado)
dart format .                                # Formatear
flutter analyze                              # Análisis estático (REQUERIDO antes de commit)
flutter test                                 # Todas las pruebas
flutter test test/features/vehicles/         # Pruebas por feature
flutter test --name "formatea" test/core/utils/formatters_test.dart  # Por nombre (regex)
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
6. **Imports**: relativos para archivos del proyecto, package para dependencias externas
7. **Riverpod**: `ConsumerWidget`/`ConsumerStatefulWidget` para UI, `Notifier` para estado
8. **Modelos**: `@freezed` para inmutabilidad, igualdad, `copyWith`, JSON
9. **Estado asíncrono**: siempre usar `AsyncValue.when()` con loading/error/data
10. **Errores**: `AsyncValue.guard()` en notifiers, nunca `try/catch` vacío

## Seguridad Operativa

- **NUNCA hacer commits**: los commits solo los crea el usuario. No usar `git add`, `git commit`, ni `git push`
- **No ejecutar `flutter test` ni `flutter analyze`** tras cambios exclusivamente en archivos `.md`
- **No ejecutar comandos destructivos** sin confirmación (`git push --force`, `flutter clean` sin preguntar)

## Arquitectura

Orientada a features con core compartido. Ver `docs/architecture.md`, `docs/database.md` y `docs/code-style.md`.

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

### Navegación

| Acción | Método |
|--------|--------|
| Sub-ruta (formulario) | `context.push('/ruta')` |
| Volver atrás | `context.pop()` |
| Cambiar tab | `context.go('/ruta')` |

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
