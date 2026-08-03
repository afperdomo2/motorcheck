# Arquitectura

## Stack Tecnológico

| Capa | Tecnología | Razón |
|------|-----------|--------|
| Manejo de Estado | Riverpod 2.x | Ligero, reactivo, similar a la reactividad de Vue |
| Navegación | GoRouter 14.x | Rutas declarativas, tipo-seguras |
| Almacenamiento | sqflite | SQLite en dispositivo, sin backend |
| Generación de Código | freezed + json_serializable | Modelos inmutables, JSON automático |
| Pruebas | flutter_test + mocktail | Pruebas unitarias y de widget, mocks sin code-gen |

## Estructura Orientada a Features

Cada feature es autocontenida con sus propios modelos, repositorio, providers, pantallas y widgets.
El código compartido vive en `core/` y `shared/`.

```
lib/
├── main.dart
├── app.dart
├── core/                    # Infraestructura compartida
│   ├── theme/               # Sistema de diseño (light + dark)
│   ├── database/            # SQLite
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

## Por Qué No Hay Capa de Dominio

Esta es una app local de un solo usuario. Las operaciones CRUD son consultas simples.
Dividir en entidades + casos de uso + repositorios agrega complejidad sin valor.
Los repositorios manejan tanto el acceso a datos como la lógica de negocio directamente.
Si la app crece (API, sincronización, etc.), se puede agregar una capa de dominio por feature.

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
