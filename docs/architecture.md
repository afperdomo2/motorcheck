# Arquitectura

## Stack Tecnológico

| Capa | Tecnología | Razón |
|------|-----------|--------|
| Manejo de Estado | Riverpod 2.x | Ligero, reactivo, similar a la reactividad de Vue |
| Navegación | GoRouter 14.x | Rutas declarativas, tipo-seguras |
| Almacenamiento | sqflite (Android/iOS) + sqflite_common_ffi (escritorio) | SQLite local, sin backend |
| Generación de Código | freezed 4 + json_serializable | Modelos inmutables, JSON automático |
| Notificaciones | flutter_local_notifications + timezone | Alertas programadas en Android |
| Respaldo | archive + file_selector + share_plus | ZIP local con datos y adjuntos |
| Reportes | pdf + printing | Hoja de vida del vehículo |
| Pruebas | flutter_test + mocktail | Pruebas unitarias y de widget, mocks sin code-gen |

## Plataformas

| Plataforma | UI | SQLite | Notificaciones |
|-----------|----|--------|----------------|
| Android | Flutter móvil | `sqflite` nativo | Programadas por el sistema |
| Linux (Ubuntu) | Ventana 420×880 (mín. 360×600) | `sqflite_common_ffi` | Solo bandeja dentro de la app |

El código de features es idéntico en ambas plataformas. Solo cambia el backend
de base de datos, inicializado en `lib/core/database/database_factory.dart`
desde `main()`. Ver `README.md` → «Desarrollo en Linux / Ubuntu».

## Estructura Orientada a Features

Cada feature es autocontenida con sus propios modelos, repositorio, providers, pantallas y widgets.
El código compartido vive en `core/` y `shared/`.

```
lib/
├── main.dart
├── app.dart
├── core/                    # Infraestructura compartida
│   ├── app_info.dart        # Nombre, versión y datos de licencia
│   ├── theme/               # Sistema de diseño (light + dark)
│   ├── database/            # SQLite v15 + factory FFI (escritorio)
│   ├── backup/              # ZIP (datos + adjuntos) y CSV
│   ├── notifications/       # Notificaciones locales y sincronización
│   ├── settings/            # Preferencias de avisos y respaldo
│   └── utils/               # Utilidades
├── features/                # Features de negocio
│   ├── vehicles/            # CRUD vehículos, selección default y kilometraje
│   ├── maintenance/         # CRUD mantenimientos + items + categorías
│   ├── dashboard/           # Inicio, recordatorios y pico y placa
│   ├── documents/           # SOAT, RTM, impuesto, seguro y licencia
│   ├── restrictions/        # Regla semanal de pico y placa
│   ├── reminders/           # Bandeja única y salud del vehículo
│   ├── reports/             # Hoja de vida en PDF
│   └── settings/            # Tema, talleres, categorías, respaldo, avisos y licencias
├── shared/                  # Widgets reutilizables (dumb)
│   └── widgets/
└── routes/                  # Navegación (4 tabs con StatefulShellRoute)
```

## Patrón Smart/Dumb Components

Adaptado del patrón de componentes de Vue 3:

### Smart (screens/ + providers.dart)
- Acceden a providers de Riverpod mediante `ref.watch` y `ref.read`
- Manejan lógica de negocio, navegación, mutaciones de estado
- Componen widgets dumb pasando datos y callbacks
- `ConsumerWidget` para solo-lectura, `ConsumerStatefulWidget` para formularios con estado local
- Siempre manejan `AsyncValue.when(loading:, error:, data:)`

### Dumb (widgets/ + shared/widgets/)
- Reciben todos los datos mediante parámetros del constructor
- Emiten eventos mediante callbacks `VoidCallback` o `ValueChanged<T>`
- **Nunca** acceden a providers o repositorios directamente
- Siempre constructores `const` donde sea posible
- Excepción: `VehicleSelectorSheet` en `shared/widgets/` es `ConsumerWidget` (widget reutilizable que necesita acceso a providers)

## Flujo de Datos

```
Acción del Usuario → Pantalla (Smart)
                       ↓ read(notifier).método()
                     Notifier (Estado)
                       ↓ llama al repositorio
                     Repositorio
                       ↓ consultas SQL
                     Base de Datos SQLite
                       ↓ retorna resultados
                     Repositorio → Notifier (nuevo estado) → Pantalla reconstruye UI
```

### Contrato de borrado

```
Pantalla → confirmación → await notifier.remove(id)
                              ↓
                        repo.delete(id)
                         ├─ error → se relanza, la lista no cambia
                         └─ ok    → recarga la lista y actualiza el estado
Pantalla ← snackbar de éxito o error
```

### Invalidación de caché

Después de una mutación, invalida los providers derivados:

- **Vehículo actualizado:** `selectedVehicleProvider(id)`, `vehiclesProvider`
  y `defaultVehicleProvider`. Los próximos mantenimientos dependen de
  `selectedVehicleProvider`, así que se recalculan al cambiar km o tipo.
- **Mantenimiento creado/editado/borrado:** `maintenancesProvider`, detalle e
  ítems del mantenimiento, resumen del vehículo, próximos, badge y estado de
  vehículos (el repositorio pudo subir el km).
- **Dashboard:** el resumen depende de `maintenancesProvider` para reflejar
  altas, ediciones y borrados sin refrescar manualmente.

### Inicio

El dashboard muestra el **vehículo por defecto** (o el primero si no hay
predeterminado): salud, recordatorios, pico y placa, actividad y estadísticas.
`remindersProvider` unifica mantenimiento (km y fecha), documentos y pico y
placa; el badge de navegación usa esa misma bandeja.

### Recordatorios y notificaciones

```
Datos (mantenimiento, documentos, restricción)
                 ↓
        remindersProvider
   ├─ bandeja en la app (/reminders)
   └─ NotificationService.sync()
          ↓
   Android: notificaciones programadas
   Linux: solo bandeja (sin scheduler)
```

`remindersProvider` usa un solo documento por tipo: el de mayor `expires_at`.
Los documentos históricos no generan avisos. `NotificationSync` escucha
`remindersProvider` y `notificationSettingsProvider` para reprogramar avisos.
Los mantenimientos solo por km usan la fecha estimada según el promedio km/día
de `mileage_readings`.

Al tocar una notificación con la app cerrada, `NotificationService` lee
`getNotificationAppLaunchDetails` y navega después del primer frame.

### Respaldo

```
Ajustes → Datos y respaldo
   ├─ Crear copia → ZIP (data.json + attachments/)
   ├─ Exportar CSV → ZIP con un archivo por tabla
   └─ Restaurar → validar → copia previa → transacción → adjuntos
```

La restauración reemplaza todos los datos y se ejecuta en una transacción. Los
adjuntos se guardan en `documents/` dentro del directorio de soporte de la app.

### Responsive

- `AppShell` centra el contenido con `maxWidth: 720`; la barra de navegación
  sigue ocupando todo el ancho.
- Las hojas (`VehicleSelectorSheet`, `CategoryHistorySheet`) usan
  `maxWidth: 640` y scroll interno.
- El buscador tiene una prueba de widget a 360×640 con text scale 2.0.

### Licencias

- La app se distribuye bajo **PolyForm Noncommercial 1.0.0** (`LICENSE`):
  uso personal, de estudio o educativo; venta y uso comercial prohibidos.
- `core/app_info.dart` centraliza nombre, versión, titular y datos de licencia.
- `Ajustes → Licencias y términos` muestra la licencia, el enlace oficial y el
  texto OFL de las fuentes Barlow (`assets/fonts/OFL.txt`).
- La pantalla también abre las licencias de paquetes de Flutter/Dart mediante
  `showLicensePage`.

## Por Qué No Hay Capa de Dominio

Esta es una app local de un solo usuario. Las operaciones CRUD son consultas simples.
Dividir en entidades + casos de uso + repositorios agrega complejidad sin valor.
Los repositorios manejan tanto el acceso a datos como la lógica de negocio directamente.
Si la app crece (API, sincronización, etc.), se puede agregar una capa de dominio por feature.

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
