# Arquitectura

## Stack Tecnológico

| Capa | Tecnología | Razón |
|------|-----------|--------|
| Manejo de Estado | Riverpod 2.x | Ligero, reactivo, similar a la reactividad de Vue |
| Navegación | GoRouter 14.x | Rutas declarativas, tipo-seguras |
| Almacenamiento | sqflite (Android/iOS) + sqflite_common_ffi (escritorio) | SQLite local, sin backend |
| Generación de Código | freezed + json_serializable | Modelos inmutables, JSON automático |
| Pruebas | flutter_test + mocktail | Pruebas unitarias y de widget, mocks sin code-gen |

## Plataformas

| Plataforma | UI | SQLite |
|-----------|----|--------|
| Android | Flutter móvil | `sqflite` nativo |
| Linux (Ubuntu) | Ventana 420×880 (mín. 360×600) | `sqflite_common_ffi` |

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
│   ├── theme/               # Sistema de diseño (light + dark)
│   ├── database/            # SQLite + factory FFI (escritorio)
│   └── utils/               # Utilidades
├── features/                # Features de negocio
│   ├── vehicles/            # CRUD vehículos + selección default
│   ├── maintenance/         # CRUD mantenimientos + items + categorías
│   ├── dashboard/           # Resumen + alertas vencimiento
│   └── settings/            # Tema (system/light/dark) + CRUD talleres + categorías
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
predeterminado): resumen, próximos, actividad y estadísticas. Las alertas de
documentos (SOAT/RTM) siguen siendo globales por seguridad. El badge de
navegación también cuenta pendientes de todos los vehículos.

## Por Qué No Hay Capa de Dominio

Esta es una app local de un solo usuario. Las operaciones CRUD son consultas simples.
Dividir en entidades + casos de uso + repositorios agrega complejidad sin valor.
Los repositorios manejan tanto el acceso a datos como la lógica de negocio directamente.
Si la app crece (API, sincronización, etc.), se puede agregar una capa de dominio por feature.

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
