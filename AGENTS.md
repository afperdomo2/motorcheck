# MotorCheck — Instrucciones para Agentes

App Flutter para seguimiento de mantenimiento de vehículos. Usuario único, SQLite local, sin backend.

## Comandos

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
dart format .                                 # 80 chars, trailing commas
flutter analyze                               # CERO issues antes de commit
flutter test                                  # suite completa
flutter test test/features/vehicles/          # por feature
flutter test --name "formatea"                # por nombre (regex)
flutter test test/core/utils/formatters_test.dart  # archivo específico
flutter test --concurrency 1                  # SQLite sin race conditions
flutter test --coverage
flutter run                                   # dispositivo seleccionado
flutter run -d linux                          # escritorio Ubuntu (hot reload)
flutter build linux --release --no-tree-shake-icons
./scripts/install-linux.sh                    # instalar/actualizar en ~/.local
```

> El SDK está instalado en `/home/felipe/Documentos/flutter` y **no** está en el
> `PATH` del sistema. Si `flutter`/`dart` fallan, usa la ruta absoluta:
> `/home/felipe/Documentos/flutter/bin/flutter`.

## Pre-commit (lefthook)

```yaml
pre-commit:
  parallel: true
  format:  dart format {staged_files} --set-exit-if-changed  (solo *.dart)
  analyze: flutter analyze                                  (solo *.dart)
  test:    flutter test                                     (suite completa)
```

## Plataformas y Build

| Plataforma | Run | Build | Salida |
|-----------|-----|-------|--------|
| Android | `flutter run -d <device>` | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| Linux (Ubuntu) | `flutter run -d linux` | `flutter build linux --release --no-tree-shake-icons` | `build/linux/x64/release/bundle/` |

- **Linux/Ubuntu**: carpeta `linux/` habilitada con `flutter create --platforms=linux .`. Toolchain: `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev`.
- Ventana 420×880 centrada, mínimo 360×600 (`linux/runner/my_application.cc`). `APPLICATION_ID=com.example.motorcheck`.
- Ícono de ventana `linux/motorcheck.png` (256×256), copiado al bundle por `linux/CMakeLists.txt`.
- `--no-tree-shake-icons` es obligatorio en release: el tree-shaker descarta glyphs y los íconos quedan en blanco.
- Para distribuir hay que copiar **toda** la carpeta `build/linux/x64/release/bundle/` (binario + `data/` + `lib/`). El binario enlaza contra la glibc del sistema donde se compiló.
- Instalación local (sin sudo): `./scripts/install-linux.sh` → `~/.local/opt/motorcheck`, symlink `~/.local/bin/motorcheck`, `.desktop` en `~/.local/share/applications` e ícono en `~/.local/share/icons`. `--uninstall` revierte.
- En VS Code basta con "Select Device" → **Linux (desktop)** y F5/`flutter run`.

## Reglas de Trabajo

1. **Pre-commit**: `flutter analyze` (cero issues) + `dart format .` + `flutter test`
2. **Post-cambios en modelos/providers**: ejecutar `build_runner` inmediatamente
3. **Constructores `const`**: siempre en widgets, EdgeInsets, SizedBox, decoraciones
4. **Patrón Smart/Dumb**: pantallas=smart (`ConsumerWidget/StatefulWidget`), widgets=dumb (datos+callbacks)
5. **Archivos**: snake_case. **Clases**: PascalCase. **Providers**: sufijo `Provider`
6. **Imports**: relativos para código propio; `package:` solo para dependencias externas. **Tests**: `package:motorcheck/...`
7. **Riverpod**: `ConsumerWidget`/`ConsumerStatefulWidget` para UI; `Notifier`/`AsyncNotifier` para estado
8. **Modelos**: `@freezed` (inmutabilidad, `copyWith`, JSON). `int? id` nullable, timestamps `required`
9. **AsyncValue**: usar `.when(loading:, error:, data:)` siempre. `AsyncValue.guard()` en notifiers. `valueOrNull` solo para acceso síncrono
10. **Errores**: nunca `try/catch` vacío; siempre feedback al usuario
11. **`context.mounted`**: verificar tras `await` antes de usar `context`
12. **UI**: todo en español (strings, labels, descripciones de test)
13. **Sincronización AGENTS.md ↔ docs/**: si modificas un archivo en `docs/`, revisa si la sección correspondiente en AGENTS.md necesita actualizarse. Tras cualquier cambio en modelos, providers, features o arquitectura, verifica que ambos reflejen el estado real del código.

## Convenciones de Código

### Formato y Linting
80 chars, trailing commas, comillas simples. `withValues(alpha:)` > `withOpacity()`. `SizedBox(width/height:)` > `Container`. `sort_child_properties_last`. Archivos generados excluidos: `*.g.dart`, `*.freezed.dart`.

### Orden de Imports (3 bloques separados por línea vacía)
1. `package:` (dependencias externas)
2. Relativos a core/shared/cross-feature (`../../vehicles/providers.dart`)
3. Relativos al mismo feature (`../models/...`, `../widgets/...`)

### Nombrado

| Elemento | Convención |
|----------|-----------|
| Archivos / Clases | `snake_case.dart` / `PascalCase` |
| Providers | `{entity}Provider` / `{entity}ByIdProvider` / `{entity}RepositoryProvider` |
| Notifiers | `{EntityPlural}Notifier` + `{entityPlural}NotifierProvider` |

Ver `docs/code-style.md` para ejemplos de modelos freezed y estado asíncrono.

### Navegación

| Acción | Método |
|--------|--------|
| Sub-ruta (formulario) | `context.push('/ruta')` |
| Volver atrás | `context.pop()` |
| Cambiar tab | `context.go('/ruta')` |

## Arquitectura

```
lib/
├── main.dart / app.dart         # Entry + MaterialApp.router
├── core/
│   ├── theme/                   # Colores, tipografía, temas light+dark
│   ├── database/                # SQLite helper + DDL (v12) + factory FFI
│   └── utils/                   # Formateadores, extensiones
├── features/
│   ├── vehicles/                # CRUD vehículos + selección default
│   ├── maintenance/             # CRUD mantenimientos + items (categorías por tipo)
│   ├── dashboard/               # Resumen + alertas SOAT/RTM
│   └── settings/                # Tema (system/light/dark) + CRUD talleres
├── shared/widgets/              # Dumb widgets reutilizables
└── routes/                      # GoRouter (StatefulShellRoute, 4 tabs)
```

**Feature típica**: `models/` (@freezed), `repository.dart`, `providers.dart`, `screens/` (smart), `widgets/` (dumb).

### Base de datos por plataforma

- **Android/iOS**: plugin `sqflite` (nativo).
- **Linux/Windows/macOS**: `sqflite_common_ffi`; `initDatabaseFactory()` en
  `lib/core/database/database_factory.dart` se llama desde `main()`.
- Ruta del archivo: `getDatabasesPath()` en móvil; en escritorio
  `getApplicationSupportDirectory()` → Linux:
  `~/.local/share/com.example.motorcheck/motorcheck.db`.
- Los tests mantienen `sqfliteFfiInit()` + `databaseFactory = databaseFactoryFfi`
  y caen a `getDatabasesPath()` porque no hay plugins registrados.

### Modelos y Categorías

| Modelo | Tabla | Campos clave |
|--------|-------|-------------|
| `Vehicle` | `vehicles` | name, type, brand, plate, vin, currentMileage, soatExpiresAt, rtmExpiresAt, isDefault |
| `Maintenance` | `maintenances` | vehicleId, date, mileage, maintenanceCost, workshopId, notes |
| `MaintenanceItem` | `maintenance_items` | maintenanceId, category, partsCost, notes |
| `Workshop` | `workshops` | name, location |

Categorías de mantenimiento por tipo: car/truck (11), motorcycle (9), bike (6), other (1).
Definidas en `lib/features/maintenance/categories.dart`.

## Tests

```bash
flutter test                              # todas
flutter test test/features/vehicles/      # por feature
flutter test --name "formatea"            # por nombre (regex)
flutter test --concurrency 1              # SQLite sin race conditions
```

**Convenciones**: archivos en `test/` reflejando `lib/`, imports `package:motorcheck/...` en tests, `group()` + descripciones en español, `sqflite_common_ffi` + `sqfliteFfiInit()` en `setUpAll`, mocktail sin code-gen, `MaterialApp` + `Scaffold` en widget tests.

## Seguridad

- **NUNCA commits**: solo el usuario crea commits
- No ejecutar `flutter test` ni `flutter analyze` tras cambios solo en `.md`
- No comandos destructivos sin confirmación explícita
- **Consistencia docs**: tras cambios estructurales (modelos, providers, features), verifica que AGENTS.md y `docs/` estén sincronizados con el código real

## Skills y MCPs

| Skill | Cuándo usar |
|-------|-------------|
| `flutter-expert` | Widgets, estado, navegación, rendimiento |
| `flutter-animations` | Animaciones, transiciones |
| `dart-best-practices` | Convenciones, features del lenguaje |

**Context7 MCP**: documentación actualizada de librerías (resolver ID → `query-docs`).
**Dart MCP Server**: `analyze_files`, `pub_dev_search`, `pub`, `lsp`, `dtd`, `flutter_driver_command`.

Los skills se declaran en `skills-lock.json` (versionado) y sus archivos viven en `.agents/` (gitignored). Para restaurarlos tras clonar:

```bash
npx skills experimental_install --no-frozen-lockfile
```

## Documentación

| Documento | Contenido |
|-----------|-----------|
| `docs/architecture.md` | Stack, estructura, Smart/Dumb, flujo de datos |
| `docs/database.md` | Esquema SQL, tablas, relaciones, migraciones |
| `docs/code-style.md` | Imports, nombrado, widgets, estado asíncrono, errores |
| `docs/DESIGN_SYSTEM.md` | Colores, tipografía, espaciado, componentes |
| `docs/testing.md` | Estrategia, ejecución, mocktail, SQLite |
