# MotorCheck

Aplicación Flutter para el seguimiento del mantenimiento personal de vehículos.

## Características

- Registro de múltiples vehículos (carros, motos, bicicletas, camiones)
- Vehículo seleccionado por defecto
- Registro de mantenimientos con múltiples items (cambio de aceite, llantas, filtros, frenos, etc.)
- Costos de mano de obra y repuestos por item
- Próximos mantenimientos por kilometraje **o por tiempo** (lo que ocurra primero)
- Historial de kilometraje y fecha estimada del próximo servicio
- Bitácora de combustible con consumo real y costo por km
- Gastos por vehículo o globales, con categorías y recibos
- Resumen financiero mensual y gráfica de los últimos 6 meses
- Recordatorios de mantenimiento, SOAT, RTM, impuesto, seguro y licencia
- Documentos con adjuntos (PDF o imagen)
- Pico y placa semanal con aviso en el inicio
- Hoja de vida del vehículo en PDF
- Copia de seguridad ZIP (datos + adjuntos) y exportación CSV
- Almacenamiento local con SQLite (sin conexión a internet)
- Tema claro/oscuro con sistema de diseño consistente
- Disponible en **Android** y **Linux (escritorio Ubuntu)**

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| UI | Flutter 3.x / Dart 3.12 |
| Estado | Riverpod 2.x |
| Navegación | GoRouter 14.x |
| Base de datos | sqflite (Android/iOS) · sqflite_common_ffi (Linux/escritorio) |
| Generación de código | freezed + json_serializable |
| Pruebas | flutter_test + mocktail |

## Comandos

```bash
# Instalar dependencias
flutter pub get

# Generar código (requerido después de modificar modelos)
dart run build_runner build --delete-conflicting-outputs

# Ejecutar análisis estático
flutter analyze

# Ejecutar pruebas
flutter test

# Ejecutar la app (dispositivo seleccionado)
flutter run

# Ejecutar en Linux / Ubuntu (hot reload)
flutter run -d linux

# Build de release para Linux
flutter build linux --release --no-tree-shake-icons

# Instalar/actualizar la app en el perfil del usuario (sin sudo)
./scripts/install-linux.sh

# Formatear código
dart format .
```

> El SDK Flutter de este equipo está en `/home/felipe/Documentos/flutter`. Si
> `flutter`/`dart` no están en el `PATH`, usa la ruta absoluta
> (`/home/felipe/Documentos/flutter/bin/flutter`).

## Arquitectura

Estructura orientada a features con patrón Smart/Dumb components.

```
lib/
├── main.dart              # Punto de entrada + ProviderScope
├── app.dart               # MaterialApp.router + tema
├── core/                  # Infraestructura compartida
│   ├── theme/             # Sistema de diseño
│   ├── database/          # SQLite v16
│   ├── backup/            # Copias ZIP y CSV
│   ├── files/             # Almacenamiento de adjuntos
│   ├── notifications/     # Avisos locales
│   ├── settings/          # Preferencias
│   └── utils/             # Utilidades
├── features/              # Features de negocio
│   ├── vehicles/          # CRUD de vehículos y kilometraje
│   ├── maintenance/       # CRUD de mantenimientos
│   ├── documents/         # SOAT, RTM, impuesto, seguro y licencia
│   ├── fuel/              # Combustible y consumo
│   ├── expenses/          # Gastos y categorías
│   ├── finance/           # Resumen y costo por km
│   ├── restrictions/      # Pico y placa
│   ├── reminders/         # Bandeja de recordatorios
│   ├── reports/           # Hoja de vida PDF
│   ├── dashboard/         # Panel principal
│   └── settings/          # Configuración
├── shared/widgets/        # Componentes reutilizables
└── routes/                # Configuración de rutas (5 tabs)
```

Ver la carpeta `docs/` para documentación detallada de arquitectura, base de datos, sistema de diseño y testing.

## Configuración del Entorno

1. Clonar el repositorio
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `flutter run`
5. En VS Code, usa **Select Device** para elegir el teléfono Android o **Linux
   (desktop)** para probar en Ubuntu (ver sección siguiente).

## Desarrollo en Linux / Ubuntu

La plataforma Linux ya está habilitada (carpeta `linux/` en la raíz). El mismo
código corre en Android y en escritorio; solo cambia el backend de SQLite.

### Requisitos

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
flutter doctor -v   # "Linux toolchain" debe quedar en verde
```

No hace falta instalar SQLite por separado: `sqflite_common_ffi` usa la
biblioteca del sistema (o el asset nativo que genera Flutter).

### Ejecutar y probar en el equipo

```bash
flutter devices          # debe listar: Linux (desktop) • linux • linux-x64
flutter run -d linux     # hot reload (r) / hot restart (R)
```

En VS Code: **Select Device → Linux (desktop)** y F5. La app abre en una
ventana **420×880 centrada**, con tamaño mínimo **360×600**, pensada para el
layout mobile-first.

### Base de datos en Linux

```
~/.local/share/com.example.motorcheck/motorcheck.db
```

- `sqflite` (el plugin móvil) no soporta escritorio. En `main()` se llama a
  `initDatabaseFactory()`, que activa `sqflite_common_ffi` solo en
  Linux/Windows/macOS (`lib/core/database/database_factory.dart`).
- En escritorio la BD se guarda en el directorio de soporte de la app
  (`getApplicationSupportDirectory()`); en Android se mantiene la ruta interna
  de `sqflite`.
- Para empezar con datos limpios, cierra la app y elimina `motorcheck.db`.

### Build de release

```bash
flutter build linux --release --no-tree-shake-icons
# Salida: build/linux/x64/release/bundle/motorcheck
```

- `--no-tree-shake-icons` es obligatorio: el tree-shaker de íconos descarta
  glyphs usados y quedan en blanco en release.
- Para distribuir o mover la app hay que copiar **toda la carpeta**
  `build/linux/x64/release/bundle/` (binario + `data/` + `lib/`), no solo el
  ejecutable.
- El binario enlaza contra la glibc del sistema donde se compiló. Lo compilado
  en Ubuntu 26.04 puede no correr en distros más antiguas.

### Instalación local (menú de aplicaciones)

```bash
flutter build linux --release --no-tree-shake-icons
./scripts/install-linux.sh              # instalar / actualizar
./scripts/install-linux.sh --uninstall  # desinstalar
```

Destinos: `~/.local/opt/motorcheck` (bundle completo), `~/.local/bin/motorcheck`
(symlink), `~/.local/share/applications/motorcheck.desktop` y
`~/.local/share/icons/hicolor/256x256/apps/motorcheck.png`. Si `~/.local/bin`
no está en el `PATH`, el script indica cómo agregarlo.

La entrada de escritorio está en [`linux/motorcheck.desktop`](linux/motorcheck.desktop)
y usa `APPLICATION_ID=com.example.motorcheck` (el mismo identificador que
Android).

## Hooks Pre-commit (Lefthook)

```bash
# Instalar lefthook (requiere Go instalado)
go install github.com/evrone/lefthook@latest

# Instalar los hooks en el repo
lefthook install
```

Los hooks ejecutan `dart format`, `flutter analyze` y `flutter test` automáticamente antes de cada commit.

## Licencia

MotorCheck se distribuye bajo la **PolyForm Noncommercial License 1.0.0** (ver
[`LICENSE`](LICENSE)). Puedes leer el código, compilarlo y usarlo para fines
personales, de estudio o educativos. **No** puedes vender la app ni usarla con
fines comerciales. Cualquier otro permiso debe solicitarlo el titular.

Las fuentes Barlow se distribuyen bajo la SIL Open Font License 1.1
([`assets/fonts/OFL.txt`](assets/fonts/OFL.txt)) y su texto se muestra dentro de
la app en **Ajustes → Licencias y términos**.
