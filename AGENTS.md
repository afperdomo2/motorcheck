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
8. **Modelos**: `@freezed` 4 (`abstract class` + factory; inmutabilidad, `copyWith`, JSON). `int? id` nullable, timestamps `required`
9. **AsyncValue y caché**: usar `.when(loading:, error:, data:)` siempre. `AsyncValue.guard()` en notifiers. `valueOrNull` solo para acceso síncrono. Tras una mutación, invalida los providers derivados (detalle, próximos, dashboard, resumen del vehículo)
10. **Errores**: nunca `try/catch` vacío; usar `friendlyErrorMessage()` y `logError()`, nunca `err.toString()` en UI; borrados con `await` + snackbar
11. **`context.mounted`**: verificar tras `await` antes de usar `context`
12. **UI**: todo en español (strings, labels, descripciones de test)
13. **Sincronización AGENTS.md ↔ docs/**: si modificas un archivo en `docs/`, revisa si la sección correspondiente en AGENTS.md necesita actualizarse. Tras cualquier cambio en modelos, providers, features o arquitectura, verifica que ambos reflejen el estado real del código.
14. **Kilometraje**: `vehicles.current_mileage` solo sube automáticamente; un mantenimiento con km menor se permite pero no baja el vehículo; la corrección manual se hace desde Editar vehículo
15. **Responsive**: en escritorio el contenido se centra con máximo 720 px y las hojas con 640 px; probar text scale 1.3 y 2.0 sin overflow

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

### Tema, formato y localización

- Los widgets **no usan colores literales**: consumen `Theme.of(context)` o
  `AppSemanticColors.of(context)`. La paleta cruda vive solo en
  `lib/core/theme/`.
- Identidad visual: grafito + ámbar industrial. El azul está reservado para el
  tipo de vehículo “carro”; no se usa como color de marca.
- Tipografía: Barlow y Barlow Semi Condensed empaquetadas en `assets/fonts/`.
- Estados siempre con icono + texto + color (`StatusChip`), nunca solo color.
- Formatos `es_CO`: moneda `$ 1.250` y kilometraje `15.000 km`.
- `MaterialApp.router` usa `locale: es_CO` y `flutter_localizations`.
- Formularios: `FormSection`, `StickyBottomBar`, validación inline y guardia de
  cambios sin guardar.

## Arquitectura

```
lib/
├── main.dart / app.dart         # Entry + MaterialApp.router
├── core/
│   ├── app_info.dart            # Identidad, versión y licencia
│   ├── theme/                   # Tokens, Barlow, temas light+dark, ThemeExtension
│   ├── database/                # SQLite helper + DDL (v21) + factory FFI
│   ├── backup/                  # Copia ZIP (JSON + adjuntos) y exportación CSV
│   ├── files/                   # Almacenamiento local de adjuntos
│   ├── notifications/           # Notificaciones locales y sincronización
│   ├── settings/                # Preferencias de notificaciones y respaldo
│   └── utils/                   # Formateadores es_CO, dateStatus, búsqueda y errores
├── features/
│   ├── vehicles/                # CRUD vehículos, kilometraje e historial
│   ├── maintenance/             # CRUD mantenimientos + adjuntos + categorías
│   ├── dashboard/               # Inicio, finanzas, recordatorios y pico y placa
│   ├── documents/               # SOAT, RTM, impuesto, seguro y licencia
│   ├── fuel/                    # Tanqueadas y consumo real
│   ├── expenses/                # Gastos y categorías de gasto
│   ├── finance/                 # Resumen, costo por km, presupuesto y gráfica
│   ├── checklists/              # Checklists e inspecciones pre-viaje
│   ├── components/              # Llantas, batería, cadena, frenos y suspensión
│   ├── restrictions/            # Regla semanal de pico y placa
│   ├── reminders/               # Bandeja única, salud del vehículo y alertas
│   ├── reports/                 # Hoja de vida en PDF
│   └── settings/                # Tema, talleres, categorías, respaldo, avisos y licencias
├── shared/widgets/              # Dumb widgets reutilizables
└── routes/                      # GoRouter (StatefulShellRoute, 5 tabs)
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
| `Vehicle` | `vehicles` | name, type (car/motorcycle/bike/scooter/truck/other), brand, plate, vin, currentMileage, soatExpiresAt/rtmExpiresAt (legado), isDefault |
| `Maintenance` | `maintenances` | vehicleId, date, mileage, maintenanceCost, workshopId, notes |
| `MaintenanceItem` | `maintenance_items` | maintenanceId, category, partsCost, notes |
| `Workshop` | `workshops` | name, location |
| `MileageReading` | `mileage_readings` | vehicleId, date, mileage, source |
| `VehicleDocument` | `documents` | vehicleId (nullable), type, number, issuedAt, expiresAt, filePath |
| `VehicleRestriction` | `vehicle_restrictions` | vehicleId, enabled, city, days, startTime, endTime, exempt |
| `FuelLog` | `fuel_logs` | vehicleId, date, odometer, quantity, unitPrice, totalCost, fuelType |
| `ExpenseCategory` | `expense_categories` | key, name, iconName, sortOrder |
| `Expense` | `expenses` | vehicleId (nullable), categoryKey, date, amount, receiptPath |
| `MaintenanceAttachment` | `maintenance_attachments` | maintenanceId, itemId (nullable), name, filePath |
| `Checklist` / `ChecklistItem` | `checklists` / `checklist_items` | vehicleId, vehicleType, name, label, sortOrder |
| `InspectionRun` / `InspectionAnswer` | `inspection_runs` / `inspection_answers` | vehicleId, checklistId, date, odometer, itemId, status |
| `Budget` | `budgets` | vehicleId, period (YYYY-MM), amount |
| `VehicleComponent` | `components` | vehicleId, name, type, position, installedAt, installedKm, intervalKm/Months, warningKm/Days, active, isSystem, categoryKey |

Categorías de mantenimiento por tipo: car/truck (11), motorcycle (9), bike (7),
scooter (6), other (1).
Definidas en `lib/features/maintenance/categories.dart`. Cada categoría puede tener
`interval_km`/`warning_km` y `interval_months`/`warning_days`; el próximo servicio
se calcula con **lo que ocurra primero** entre kilometraje y fecha.

Los **componentes** son piezas con vida útil (llantas, batería, cadena, frenos,
suspensión). Cada llanta es un componente individual y `position` es texto
libre, así que el camión se maneja con el mismo formulario
(`Eje 2 izquierda exterior`). El reemplazo **no** es una cuenta aparte: se
registra como ítem del mantenimiento con `maintenance_items.component_id` y el
costo vive en el mantenimiento. El historial del componente se deriva de esos
ítems. Las plantillas por tipo crean componentes `is_system` (no se eliminan,
sí se desactivan) y asignan `category_key`; cuando hay un componente activo de
llantas, frenos, batería o cadena, esa categoría de mantenimiento deja de
generar su propio aviso para no duplicar alertas. El estado se calcula con lo
que ocurra primero entre km y meses.

La fuente de verdad de SOAT, RTM, impuesto, seguro y licencia es `documents`.
Las columnas `vehicles.soat_expires_at` y `rtm_expires_at` se conservan solo por
compatibilidad y se migraron a `documents` en la v14. El formulario de vehículo
sincroniza sus fechas con `documents`; el selector de Mantenimientos no muestra
esos documentos, solo identidad, placa y kilometraje.

El **documento vigente** es el de mayor `expires_at` por vehículo y tipo (o por
tipo en documentos globales). Los anteriores se conservan como historial y no
generan recordatorios ni avisos. Los backfills de documentos y kilometraje se
ejecutan solo en `_onUpgrade`, nunca en cada apertura.

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
- **Licencia**: PolyForm Noncommercial 1.0.0 (`LICENSE`). Uso personal permitido; venta y uso comercial prohibidos. Solo el titular la cambia: no migrar a MIT/GPL/Apache sin autorización explícita. La pantalla `Ajustes → Licencias y términos` muestra la licencia y el OFL de Barlow.

## Planes y resúmenes de cambios

### Cuánto detalle
- **Cambio pequeño** (1-2 archivos, sin UI, datos ni flujo nuevo): resumen de 3 líneas, sin diagramas.
- **Cambio mediano o grande** (UI nueva, flujo nuevo, cambios en datos o API, 3+ archivos): presenta un plan antes de escribir código y espera mi aprobación.

### Formato del plan
Incluye solo las secciones que apliquen al cambio:
1. **Objetivo**: qué se logra, en 2 líneas.
2. **Interfaz** (si hay UI web, móvil o de escritorio): wireframe ASCII del antes y del después, y los estados relevantes (cargando, vacío, error).
3. **Flujo**: diagrama ASCII del recorrido de punta a punta, según la arquitectura del proyecto (por ejemplo: pantalla → estado → servicio → API → lógica → base de datos; o evento → proceso → resultado).
4. **Datos y contratos**: esquema de datos antes/después; endpoints o interfaces nuevas con entrada y salida.
5. **Archivos**: tabla `archivo | qué cambia | por qué`. Explica el efecto del cambio, no solo el nombre del archivo.
6. **Decisiones y riesgos**: si hay dos o más formas razonables, preséntalas con pros y contras y espera mi decisión. Señala qué podría romperse.
7. **Verificación**: cómo comprobar que funciona (pruebas, pasos manuales).

### Reglas para los diagramas
- Usa ASCII (máximo 80 columnas). No uses Mermaid en la terminal.
- Marca `[NUEVO]` lo que se agrega y `[CAMBIA]` lo que se modifica; lo demás es existente.
- Un diagrama por idea; no dibujes lo que no cambia ni lo que es obvio.
- Si el plan es grande, guárdalo también en `docs/plans/<nombre>.md` con diagramas Mermaid y dime la ruta.

### Al terminar
Resume lo hecho con un diagrama del flujo resultante, qué cambió en la UI o en los datos, las diferencias respecto al plan y lo que falta por verificar.

## Skills y MCPs

| Skill | Cuándo usar |
|-------|-------------|
| `flutter-expert` | Widgets, estado, navegación, rendimiento |
| `flutter-apply-architecture-best-practices` | Estructurar/refactorizar features (UI · Lógica · Datos) |
| `flutter-build-responsive-layout` | Layout adaptable a móvil, tablet y ventana Linux |
| `flutter-fix-layout-issues` | Overflows y constraints (`RenderFlex overflowed`) |
| `flutter-animations` | Animaciones y transiciones |
| `flutter-add-widget-test` | Pruebas de widget (`WidgetTester`) |
| `flutter-add-integration-test` | Flujos end-to-end con `integration_test` |
| `dart-best-practices` | Convenciones y features del lenguaje |
| `dart-add-unit-test` | Pruebas unitarias de lógica |
| `dart-run-static-analysis` | `dart analyze` y `dart fix --apply` |
| `find-skills` | Descubrir/instalar nuevos skills desde skills.sh |

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
