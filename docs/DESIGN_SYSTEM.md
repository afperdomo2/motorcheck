# MotorCheck — Sistema de Diseño

> Guía completa del lenguaje visual, componentes y patrones UX de la aplicación.
> Versión 1.0 · Julio 2026

---

## Índice

1. [Principios de Diseño](#1-principios-de-diseño)
2. [Paleta de Color](#2-paleta-de-color)
3. [Tipografía](#3-tipografía)
4. [Espaciado](#4-espaciado)
5. [Bordes y Elevación](#5-bordes-y-elevación)
6. [Iconografía](#6-iconografía)
7. [Componentes Compartidos](#7-componentes-compartidos)
8. [Componentes de Feature](#8-componentes-de-feature)
9. [Patrones de Layout](#9-patrones-de-layout)
10. [Estados de UI](#10-estados-de-ui)
11. [Interacciones y Feedback](#11-interacciones-y-feedback)
12. [Configuración de Tema](#12-configuración-de-tema)
13. [Reglas de UX](#13-reglas-de-ux)
14. [Apéndice: Guía Rápida de Uso](#14-apéndice-guía-rápida-de-uso)

---

## 1. Principios de Diseño

MotorCheck sigue 5 principios fundamentales que guían cada decisión de UI/UX:

| Principio | Descripción |
|---|---|
| **Claridad** | Flat design sin ruido visual. Cada pantalla comunica su propósito de inmediato. |
| **Jerarquía** | La tipografía y el espaciado guían el ojo desde lo más importante a los detalles. |
| **Consistencia** | Tokens compartidos en todo el sistema. Un `Card` siempre luce y se comporta igual. |
| **Eficiencia** | Mínimo de toques para cada tarea. Acciones frecuentes a un tap de distancia. |
| **Accesibilidad** | Contraste WCAG AA garantizado. Touch targets mínimos de 48px en dispositivos móviles. |

### Filosofía visual

- **Flat**: cero sombras, cero elevación, diseño limpio y moderno.
- **Mobile-first**: la app está diseñada exclusivamente para teléfonos. Layout de columna única con scroll.
- **Material Design 3**: aprovecha el sistema de tokens, colores y tipografía de M3.
- **Color con propósito**: los colores de tipo de vehículo crean identidad visual inmediata.

---

## 2. Paleta de Color

### 2.1 Colores Principales

| Token | Hex | Muestra | Uso |
|---|---|---|---|
| `primary` | `#2563EB` | ██ | Botones principales, FAB, enlaces, bordes de selección |
| `primaryVariant` | `#1D4ED8` | ██ | Estados hover/presionados de primary |
| `secondary` | `#7C3AED` | ██ | Acentos decorativos, variante de moto |
| `secondaryVariant` | `#6D28D9` | ██ | Estados hover/presionados de secondary |

**Ratio de contraste** (sobre blanco `#FFFFFF`):
- `primary` → 5.0:1 ✅ WCAG AA (texto normal)
- `secondary` → 6.3:1 ✅ WCAG AA (texto normal)

### 2.2 Paleta Neutral

| Token | Hex | Muestra | Uso |
|---|---|---|---|
| `background` | `#F8FAFC` | ██ | Fondo del scaffold, superficie base de la app |
| `surface` | `#FFFFFF` | ██ | Cards, diálogos, AppBar |
| `onSurface` | `#1E293B` | ██ | Texto principal, títulos, iconos activos |
| `onSurfaceVariant` | `#64748B` | ██ | Texto secundario, captions, iconos inactivos |
| `outline` | `#CBD5E1` | ██ | Bordes, dividers, líneas decorativas |

### 2.3 Colores Semánticos

| Token | Hex | Muestra | Uso |
|---|---|---|---|
| `error` | `#DC2626` | ██ | Estados de error, acciones destructivas, iconos de eliminar |

### 2.4 Colores por Tipo de Vehículo

Cada tipo de vehículo tiene un color de identidad que se usa de dos formas:

**Uso 1 — Iconos y texto** (opacidad 100%):
```dart
AppColors.forVehicleType(vehicle.type) // Color sólido para el icono
```

**Uso 2 — Fondos y badges** (opacidad 15%):
```dart
AppColors.forVehicleType(vehicle.type).withValues(alpha: 0.15) // Fondo tintado
```

| Tipo | Clave | Hex | Muestra | Ícono |
|---|---|---|---|---|
| Carro | `car` | `#2563EB` | ██ | `directions_car` |
| Moto | `motorcycle` | `#7C3AED` | ██ | `motorcycle` |
| Bicicleta | `bike` | `#059669` | ██ | `pedal_bike` |
| Camión | `truck` | `#D97706` | ██ | `local_shipping` |
| Otro | `other` | `#64748B` | ██ | `help_outline` |

**API**:
```dart
Color color = AppColors.forVehicleType(vehicle.type);
```

---

## 3. Tipografía

### 3.1 Configuración Base

| Propiedad | Valor |
|---|---|
| Familia | `Roboto` (Material Design default) |
| Color base | `onSurface` (`#1E293B`) |
| Sistema | Material Design 3 Type Scale |

### 3.2 Escala Tipográfica

```
┌─────────────────────────────────────────────────────────────────┐
│  headlineLarge   32px · w600   TÍTULOS DE PANTALLA             │
│  headlineMedium  28px · w600   VALORES DESTACADOS              │
│  titleLarge      22px · w500   NOMBRE DE VEHÍCULO              │
│  titleMedium     16px · w500   TÍTULOS DE CARD, LIST TILES     │
│  bodyLarge       16px · w400   TEXTO DE CUERPO                 │
│  bodyMedium      14px · w400   TEXTO SECUNDARIO, SUBTÍTULOS    │
│  labelLarge      14px · w500   BOTONES, ETIQUETAS DE FORM      │
│  labelMedium     12px · w500   CHIPS, BADGES, PLACAS           │
└─────────────────────────────────────────────────────────────────┘
```

### 3.3 Tabla Completa

| Token | Tamaño | Peso | Color | Altura de línea | Uso en la app |
|---|---|---|---|---|---|
| `headlineLarge` | 32px | 600 | onSurface | 1.25 | Título de sección en Dashboard ("Mantenimientos", "Total gastado") |
| `headlineMedium` | 28px | 600 | onSurface | 1.25 | Valores numéricos destacados en QuickStats |
| `titleLarge` | 22px | 500 | onSurface | 1.25 | Nombre del vehículo en QuickStats |
| `titleMedium` | 16px | 500 | onSurface | 1.25 | Título de cards (VehicleCard, MaintenanceCard), títulos de sección |
| `bodyLarge` | 16px | 400 | onSurface | 1.5 | Texto de cuerpo principal (poco usado actualmente) |
| `bodyMedium` | 14px | 400 | onSurfaceVariant | 1.5 | Subtítulos, texto secundario, fechas, kilometraje |
| `labelLarge` | 14px | 500 | onSurface | 1.25 | Botones, etiquetas de formulario, "Costo total" |
| `labelMedium` | 12px | 500 | onSurface | 1.25 | Placas de vehículos, chips "Default", badges |

### 3.4 Cómo usar la tipografía

```dart
// Desde el tema (recomendado)
Theme.of(context).textTheme.titleMedium
Theme.of(context).textTheme.bodyMedium

// Desde la clase estática (poco usado)
AppTextStyles.headlineLarge
```

> **Regla**: usar `Theme.of(context).textTheme.*` para que cambios de tema (ej. dark mode futuro) se propaguen automáticamente.

---

## 4. Espaciado

### 4.1 Escala de Tokens

| Token | Valor | Uso principal |
|---|---|---|
| `xs` | 4px | Gap ícono↔texto en chips, iconos inline con texto |
| `sm` | 8px | Gap entre bloques de texto, separación entre elementos de lista |
| `md` | 16px | **Unidad base**: padding de pantalla, padding de cards, gaps entre campos de formulario |
| `lg` | 24px | Separación de botones de acción, padding de estado vacío alternativo |
| `xl` | 32px | Padding exterior en EmptyState/ErrorState, height de divider |
| `xxl` | 48px | Altura mínima de botones de acción |

### 4.2 Dónde se aplica cada token

| Contexto | Token | Implementación |
|---|---|---|
| Padding de pantalla (listas, formularios) | `md` (16px) | `EdgeInsets.all(16)` en `SingleChildScrollView` |
| Padding interno de Card | `md` (16px) | `EdgeInsets.all(16)` dentro de cada Card |
| Padding interno de Card anidada (ItemFormRow) | `12px` | `EdgeInsets.all(12)` |
| Gap entre campos de formulario | `md` (16px) | `SizedBox(height: 16)` |
| Gap entre secciones de texto en Card | `sm` (8px) | `SizedBox(height: 8)` |
| Gap ícono↔etiqueta en fila | `xs` (4px) | `SizedBox(width: 4)` |
| Botón separado del contenido | `lg` (24px) | `SizedBox(height: 24)` |
| Padding de EmptyState / ErrorState | `xl` (32px) | `EdgeInsets.all(32)` |
| Height de Divider | `xl` (32px) | `Divider(height: 32)` |
| Altura mínima de botón | `xxl` (48px) | `Size.fromHeight(48)` |
| Padding vertical de inputs | 12px | `contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)` |

### 4.3 Layouts de lista

```dart
// Estructura estándar de lista
ListView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  itemBuilder: (context, index) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: MyCard(...),
  ),
)
```

---

## 5. Bordes y Elevación

### 5.1 Radio de Borde

| Componente | Radio | Forma |
|---|---|---|
| Cards | 12px | `RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))` |
| Botones (Elevated + Outlined) | 8px | `RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))` |
| Campos de texto (Input) | 8px | `OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))` |
| ChoiceChips | Material 3 default | Pill shape automática |

### 5.2 Sistema de Elevación

MotorCheck usa un diseño **completamente plano**:

| Componente | Elevación |
|---|---|
| Cards | `0` (sin sombra) |
| AppBar | `0` (sin sombra) |
| AppBar (con scroll) | `1` (`scrolledUnderElevation: 1` — separación sutil al hacer scroll) |
| FAB | Default Material 3 |

> **Decisión de diseño**: cero sombras = interfaz más limpia, moderna y enfocada en contenido. La separación visual se logra con color de fondo (`background` vs `surface`) y bordes.

### 5.3 Bordes Especiales

| Contexto | Estilo |
|---|---|
| Card seleccionada (VehicleCard) | `BorderSide(color: AppColors.primary, width: 2)` |
| Card normal | `BorderSide.none` |
| OutlinedButton | `BorderSide(color: AppColors.primary)` |
| Divider | `color: AppColors.outline, thickness: 1` |

---

## 6. Iconografía

### 6.1 Navegación (Bottom Bar)

| Pantalla | Inactivo | Activo |
|---|---|---|
| Dashboard | `dashboard_outlined` | `dashboard` |
| Mantenimientos | `build_outlined` | `build` |
| Vehículos | `directions_car_outlined` | `directions_car` |

### 6.2 Tipos de Vehículo

| Tipo | Ícono |
|---|---|
| Carro | `directions_car` |
| Moto | `motorcycle` |
| Bicicleta | `pedal_bike` |
| Camión | `local_shipping` |
| Otro | `help_outline` |

### 6.3 Acciones

| Acción | Ícono | Tamaño |
|---|---|---|
| Agregar / Nuevo | `add` | default (FAB) |
| Editar | `edit` | 20px (PopupMenu) |
| Eliminar | `delete` | 20px (PopupMenu) |
| Cerrar / Remover | `close` | 20px (IconButton) |
| Calendario / Fecha | `calendar_today` | 16px (Card), 20px (formulario) |
| Kilometraje | `speed` | 16px (Card) |
| Navegar / Siguiente | `chevron_right` | default (ListTile) |
| Seleccionar vehículo | `directions_car` | default (AppBar action) |

### 6.4 Estados de UI

| Estado | Ícono | Tamaño | Color |
|---|---|---|---|
| Empty (dashboard) | `directions_car` | 64px | `disabledColor` |
| Empty (mantenimientos) | `build` | 64px | `disabledColor` |
| Error | `error_outline` | 64px | `Colors.red` |
| Loading | `CircularProgressIndicator` | default | `primary` |

### 6.5 Estadísticas (Dashboard)

| Estadística | Ícono | Tamaño | Color |
|---|---|---|---|
| Mantenimientos | `build` | 28px | `primary` |
| Total gastado | `payments` | 28px | `primary` |
| Actividad reciente | `build` (CircleAvatar) | 20px | default |

### 6.6 Reglas de Uso

- **Tamaños**: 16px (inline con texto), 20px (acciones en menús), 24px (íconos de feature), 28px (stats), 64px (estados vacíos/error).
- **Color en CircleAvatar**: usar `typeColor.withValues(alpha: 0.15)` como fondo y `typeColor` sólido para el ícono.
- **Color en iconos de estado**: `disabledColor` para empty, `Colors.red` para error.
- **Color en acciones**: `AppColors.primary` para acciones normales, `Colors.red` para eliminar.

---

## 7. Componentes Compartidos

Los componentes compartidos están en `lib/shared/widgets/`. Son widgets dumb: reciben datos y callbacks, no manejan estado por sí mismos.

### 7.1 LoadingIndicator

Anatomía:
```
┌────────────────────────────────────┐
│                                    │
│            ◉ (spinner)            │
│                                    │
│       Cargando vehículos...        │  ← opcional (bodyMedium)
│                                    │
└────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `message` | `String?` | No | `null` | Texto opcional bajo el spinner |

**Uso típico**:
```dart
vehiclesAsync.when(
  loading: () => const LoadingIndicator(message: 'Cargando vehículos...'),
  data: (vehicles) => VehiclesList(vehicles: vehicles),
  error: (e, _) => ErrorState(message: e.toString(), onRetry: ref.refresh),
)
```

### 7.2 EmptyState

Anatomía:
```
┌────────────────────────────────────┐
│                                    │
│              🚗 (64px)             │  ← icon, disabledColor
│                                    │
│        No tienes vehículos         │  ← title (titleMedium, centrado)
│    Agrega tu primer vehículo...    │  ← subtitle opcional (bodyMedium)
│                                    │
│        [ Agregar vehículo ]        │  ← botón opcional (si onAction + actionLabel)
│                                    │
└────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `icon` | `IconData` | Sí | — | Ícono grande (64px) |
| `title` | `String` | Sí | — | Título principal |
| `subtitle` | `String?` | No | `null` | Texto secundario explicativo |
| `onAction` | `VoidCallback?` | No | `null` | Callback del botón de acción |
| `actionLabel` | `String?` | No | `null` | Texto del botón de acción |

> **Importante**: el botón solo se renderiza si **ambos** `onAction` y `actionLabel` son no-nulos.

**Variantes de uso en la app**:

| Pantalla | Icon | Title | Subtitle | Action |
|---|---|---|---|---|
| Dashboard (sin vehículo) | `directions_car` | "Bienvenido a MotorCheck" | "Agrega un vehículo para comenzar" | "Agregar vehículo" → navega a /vehicles/new |
| Dashboard (sin datos) | `directions_car` | "Sin datos disponibles" | null | null |
| Vehículos (lista vacía) | `directions_car` | "No tienes vehículos" | "Agrega tu primer vehículo..." | "Agregar vehículo" |
| Mantenimientos (sin vehículo) | `build` | "Selecciona un vehículo" | "Elige un vehículo..." | "Ir a vehículos" |
| Mantenimientos (sin registros) | `build` | "Sin mantenimientos" | "Agrega el primer..." | "Agregar mantenimiento" |

### 7.3 ErrorState

Anatomía:
```
┌────────────────────────────────────┐
│                                    │
│           ⚠️ (64px, rojo)         │  ← Icons.error_outline
│                                    │
│           Algo salió mal           │  ← título fijo (titleMedium)
│    No se pudo cargar los datos     │  ← message (bodyMedium)
│                                    │
│           [ Reintentar ]           │  ← botón opcional (OutlinedButton)
│                                    │
└────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `message` | `String` | Sí | — | Mensaje descriptivo del error |
| `onRetry` | `VoidCallback?` | No | `null` | Callback para reintentar |

> **Nota**: el título "Algo salió mal" es fijo (hardcoded en español). El botón de reintentar solo aparece si `onRetry` no es null.

### 7.4 showConfirmDialog

Función top-level que muestra un `AlertDialog` de confirmación.

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `context` | `BuildContext` | Sí | — | Contexto de build |
| `title` | `String` | Sí | — | Título del diálogo |
| `message` | `String` | Sí | — | Cuerpo del diálogo |
| `confirmLabel` | `String` | No | `'Confirmar'` | Texto del botón de confirmación |
| `cancelLabel` | `String` | No | `'Cancelar'` | Texto del botón de cancelación |
| `isDestructive` | `bool` | No | `false` | Si `true`, el botón de confirmar se muestra en rojo |

**Retorna**: `Future<bool?>` — `true` si confirma, `false` si cancela, `null` si cierra sin seleccionar.

**Uso típico**:
```dart
final confirmed = await showConfirmDialog(
  context,
  title: 'Eliminar vehículo',
  message: '¿Estás seguro? Esta acción no se puede deshacer.',
  confirmLabel: 'Eliminar',
  isDestructive: true,
);
if (confirmed == true && context.mounted) {
  ref.read(vehiclesProvider.notifier).delete(vehicle.id);
}
```

---

## 8. Componentes de Feature

Estos componentes están dentro de cada feature (`lib/features/<feature>/widgets/`) y encapsulan patrones de UI específicos del dominio.

### 8.1 VehicleCard

Muestra un vehículo en formato card con avatar coloreado por tipo, datos principales y menú de acciones.

Anatomía:
```
┌──────────────────────────────────────────────┐
│ ┌──────┐                                    │
│ │  🚗  │  Mi Carro                    ⋮    │  ← CircleAvatar tintado + nombre + PopupMenu
│ │      │  Toyota Corolla                    │  ← marca + modelo (bodyMedium, opcional)
│ └──────┘  ABC-123                           │  ← placa (labelMedium, opcional)
│                                              │
│           [ Default ]                        │  ← Chip si vehicle.isDefault
└──────────────────────────────────────────────┘
```

Estados visuales:
- **Normal**: borde transparente
- **Seleccionado** (`isSelected: true`): borde azul 2px (`AppColors.primary`)

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `vehicle` | `Vehicle` | Sí | — | Datos del vehículo |
| `isSelected` | `bool` | No | `false` | Muestra borde de selección |
| `onTap` | `VoidCallback` | Sí | — | Callback al tocar la card |
| `onEdit` | `VoidCallback?` | No | `null` | Acción de editar (menú) |
| `onDelete` | `VoidCallback?` | No | `null` | Acción de eliminar (menú) |

> El PopupMenu solo se muestra si `onEdit` o `onDelete` no son null.

### 8.2 VehicleTypeSelector

Selector de tipo de vehículo con `ChoiceChip` en layout `Wrap`.

Anatomía:
```
┌──────────────────────────────────────────────┐
│  🚗 Carro   🏍 Moto   🚲 Bici   🚚 Camión   ? Otro  │
└──────────────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `selectedType` | `String?` | Sí | — | Tipo seleccionado (`'car'`, `'motorcycle'`, etc.) |
| `onChanged` | `ValueChanged<String>` | Sí | — | Callback al seleccionar un tipo |

**Colores de selección**: `AppColors.forVehicleType(type).withValues(alpha: 0.2)` como `selectedColor`.

### 8.3 MaintenanceCard

Muestra un mantenimiento con título, fecha, kilometraje, costo total y notas.

Anatomía:
```
┌──────────────────────────────────────────────┐
│  Cambio de aceite                       ⋮   │  ← título + PopupMenu
│                                              │
│  📅 2026-07-15    🏎️ 15,000 km              │  ← iconos 16px + bodyMedium
│  Costo total: $850                           │  ← labelLarge (si total > 0)
│  Aceite sintético 5W-30, filtro...           │  ← bodyMedium, maxLines 2, ellipsis
└──────────────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `maintenance` | `Maintenance` | Sí | — | Datos del mantenimiento |
| `onTap` | `VoidCallback` | Sí | — | Callback al tocar |
| `onEdit` | `VoidCallback?` | No | `null` | Acción de editar |
| `onDelete` | `VoidCallback?` | No | `null` | Acción de eliminar |

### 8.4 ItemFormRow

Fila de formulario para un ítem de mantenimiento dentro del formulario de mantenimiento.

Anatomía:
```
┌──────────────────────────────────────────────┐
│  Item 1                                   ✕  │  ← labelLarge + botón cerrar (si canRemove)
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │ Nombre *                             │    │  ← TextFormField
│  └──────────────────────────────────────┘    │
│  ┌──────────────────────────────────────┐    │
│  │ Categoría                        ▼  │    │  ← DropdownButtonFormField
│  └──────────────────────────────────────┘    │
│  ┌──────────────┐ ┌──────────────────┐      │
│  │ Mano de obra │ │ Repuestos        │      │  ← Row con Expanded
│  └──────────────┘ └──────────────────┘      │
└──────────────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `item` | `MaintenanceItem` | Sí | — | Datos del ítem |
| `index` | `int` | Sí | — | Índice (se muestra como "Item {index+1}") |
| `onRemove` | `VoidCallback` | Sí | — | Callback para eliminar |
| `canRemove` | `bool` | Sí | — | Si `true`, muestra el botón ✕ |
| `onChanged` | `ValueChanged<MaintenanceItem>` | Sí | — | Callback al modificar cualquier campo |

**Categorías disponibles**:
| Valor | Etiqueta |
|---|---|
| `oil` | Aceite |
| `tires` | Llantas |
| `filters` | Filtros |
| `brakes` | Frenos |
| `suspension` | Suspensión |
| `general` | General |
| `other` | Otro |

### 8.5 QuickStats

Resumen dashboard del vehículo seleccionado con stats principales.

Anatomía:
```
┌──────────────────────────────────────────────┐
│ ┌──────┐                                     │
│ │  🚗  │  Mi Carro                           │  ← CircleAvatar 28px + titleLarge
│ │      │  ABC-123                             │  ← bodyMedium (placa)
│ └──────┘                                     │
│────────────────────────────────────────────  │  ← Divider (height: 32)
│       🔧                💰                   │
│        3               $1,250                │  ← _StatItem (icon 28px primary)
│  Mantenimientos    Total gastado              │
│────────────────────────────────────────────  │  ← Divider (opcional, si hay último)
│  Último mantenimiento                        │
│  Cambio de aceite - 2026-07-15               │
└──────────────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `summary` | `DashboardSummary` | Sí | — | Datos del resumen |

### 8.6 RecentActivity

Lista de últimos mantenimientos del vehículo.

Anatomía (con datos):
```
┌──────────────────────────────────────────────┐
│  Actividad reciente                          │  ← titleMedium
│                                              │
│  ┌──┐  Cambio de aceite                 ▸   │
│  │🔧│  2026-07-15                            │  ← ListTile con CircleAvatar + chevron_right
│  └──┘                                        │
│  ┌──┐  Rotación de llantas              ▸   │
│  │🔧│  2026-06-01                            │
│  └──┘                                        │
└──────────────────────────────────────────────┘
```

Anatomía (vacío):
```
┌──────────────────────────────────────────────┐
│                                              │
│     Sin mantenimientos registrados           │  ← bodyMedium, padding 24px
│                                              │
└──────────────────────────────────────────────┘
```

**API**:
| Parámetro | Tipo | Requerido | Default | Descripción |
|---|---|---|---|---|
| `summary` | `DashboardSummary` | Sí | — | Datos del resumen (contiene `recentMaintenances`) |

**Navegación**: al tocar un ListTile, navega a `/maintenance/:id/edit` vía `context.push()`.

---

## 9. Patrones de Layout

### 9.1 Estructura de Pantalla Típica

```
┌──────────────────────────────────────────────┐
│ AppBar                                        │  ← elevation: 0, centrado
│  Título                  [action]             │
├──────────────────────────────────────────────┤
│                                              │
│  ┌──────────────────────────────────────┐    │
│  │                                      │    │
│  │  Content Area                        │    │
│  │  - padding: 16px                     │    │
│  │  - ScrollView / ListView             │    │
│  │  - Cards con 16px padding            │    │
│  │  - Gaps de 8-16px entre cards        │    │
│  │                                      │    │
│  └──────────────────────────────────────┘    │
│                                              │
│                                    ┌────┐    │
│                                    │ +  │    │  ← FAB (opcional)
│                                    └────┘    │
└──────────────────────────────────────────────┘
```

### 9.2 Pantalla de Lista (Dashboard, Vehículos, Mantenimientos)

```dart
Scaffold(
  appBar: AppBar(title: Text('Título')),
  body: AsyncValueWidget(
    value: asyncData,
    loading: () => const LoadingIndicator(message: '...'),
    error: (e, _) => ErrorState(message: e.toString(), onRetry: ...),
    data: (items) {
      if (items.isEmpty) return EmptyState(...);
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ItemCard(...),
        ),
      );
    },
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () => context.push('/route/new'),
    child: const Icon(Icons.add),
  ),
)
```

### 9.3 Pantalla de Formulario (Crear/Editar)

```dart
Scaffold(
  appBar: AppBar(title: Text('Título')),
  body: Form(
    key: formKey,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Campo1,           // TextFormField
          SizedBox(height: 16),
          Campo2,           // DropdownButtonFormField
          SizedBox(height: 16),
          Campo3,           // otro campo
          SizedBox(height: 32),
          SizedBox(         // Botón full-width de 48px alto
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: save,
              child: Text('Guardar'),
            ),
          ),
        ],
      ),
    ),
  ),
)
```

### 9.4 Layout Responsivo

La app es **mobile-only**. No hay breakpoints, grid system ni `LayoutBuilder`. Algunas consideraciones:

- Las filas de campos (Marca/Modelo, Mano de obra/Repuestos) usan `Expanded` en un `Row` con 12px de gap.
- Los `ChoiceChip` del `VehicleTypeSelector` usan `Wrap` para fluir a la siguiente línea si no caben.
- No hay adaptación a tablets o pantallas anchas (no es un requisito actual).

---

## 10. Estados de UI

Toda pantalla de la app maneja **4 estados** de forma consistente:

### 10.1 Ciclo de Estados

```
       ┌──────────┐
       │ Loading   │──→ Spinner centrado + texto opcional
       └─────┬────┘
             │
       ┌─────▼────┐
   ┌───│  Data     │
   │   └─────┬────┘
   │         │
   │    ┌────▼────┐     ┌──────────┐
   │    │ ¿Vacío?  │─Sí─→│ Empty     │──→ Ícono 64px + título + acción
   │    └────┬────┘     └──────────┘
   │         │ No
   │    ┌────▼────┐
   └────│ Content  │──→ Datos renderizados normalmente
        └─────────┘
             │
       ┌─────▼────┐
       │ Error     │──→ Ícono rojo + "Algo salió mal" + mensaje + reintentar
       └───────────┘
```

### 10.2 Mapeo de Componentes

| Estado | Componente | ¿Cuándo? |
|---|---|---|
| Loading | `LoadingIndicator` | Datos cargando de BD/async |
| Empty | `EmptyState` | Lista vacía, sin vehículo seleccionado |
| Content | Widgets de feature | Datos disponibles |
| Error | `ErrorState` | Excepción en carga de datos |

### 10.3 Implementación con Riverpod

```dart
vehiclesAsync.when(
  loading: () => const LoadingIndicator(message: 'Cargando vehículos...'),
  error: (error, stack) => ErrorState(
    message: error.toString(),
    onRetry: () => ref.invalidate(vehiclesProvider),
  ),
  data: (vehicles) {
    if (vehicles.isEmpty) {
      return EmptyState(
        icon: Icons.directions_car,
        title: 'No tienes vehículos',
        subtitle: 'Agrega tu primer vehículo para comenzar',
        onAction: () => context.push('/vehicles/new'),
        actionLabel: 'Agregar vehículo',
      );
    }
    return VehiclesList(vehicles: vehicles);
  },
)
```

---

## 11. Interacciones y Feedback

### 11.1 Navegación

| Acción | Comportamiento |
|---|---|
| Bottom Navigation Bar | Cambia entre Dashboard / Mantenimientos / Vehículos (3 tabs) |
| FAB (+) | Navega a formulario de creación (`context.push('/route/new')`) |
| Tap en Card | Navega al detalle o edición |
| Tap en ListTile (RecentActivity) | `context.push('/maintenance/:id/edit')` |
| Back button / gesto | `context.pop()` automático vía GoRouter |

### 11.2 Acciones Contextuales

| Acción | Mecanismo | Feedback |
|---|---|---|
| Editar | PopupMenuButton en card → ítem "Editar" | Navega a pantalla de edición |
| Eliminar | PopupMenuButton → "Eliminar" | **Siempre** pide confirmación con `showConfirmDialog(isDestructive: true)` |
| Guardar formulario | ElevatedButton "Guardar" | SnackBar de éxito/error, navega hacia atrás |

### 11.3 Diálogos de Confirmación

Las acciones destructivas (eliminar vehículo, eliminar mantenimiento) **siempre** muestran confirmación previa:

```
┌────────────────────────────────────┐
│  Eliminar vehículo                 │
│                                    │
│  ¿Estás seguro? Esta acción no     │
│  se puede deshacer.                │
│                                    │
│           [ Cancelar ] [ Eliminar ]│  ← Eliminar en rojo
└────────────────────────────────────┘
```

### 11.4 SnackBars

Se usan para confirmar acciones exitosas:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Vehículo guardado correctamente')),
);
```

### 11.5 InkWell y Ripple

Todas las Cards usan `InkWell` con `borderRadius` coincidente para el efecto ripple de Material:
```dart
Card(
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(...),
  ),
)
```

### 11.6 Formateo de Datos

| Dato | Formato | Ejemplo |
|---|---|---|
| Fecha | `yyyy-MM-dd` | 2026-07-15 |
| Moneda | `$X,XXX` (sin decimales) | $1,250 |
| Kilometraje | `X km` o `X,XXX km` (≥1000) | 15000 km |

Ver `lib/core/utils/formatters.dart` para la implementación.

---

## 12. Configuración de Tema

### 12.1 Tema Actual

| Propiedad | Valor |
|---|---|
| Modo | Solo claro (light) |
| Material | Material 3 (`useMaterial3: true`) |
| Banner de debug | Oculto (`debugShowCheckedModeBanner: false`) |

### 12.2 ThemeData Completo

```dart
// lib/core/theme/app_theme.dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,            // #2563EB
    onPrimary: AppColors.surface,          // #FFFFFF
    secondary: AppColors.secondary,        // #7C3AED
    onSecondary: AppColors.surface,        // #FFFFFF
    error: AppColors.error,                // #DC2626
    surface: AppColors.surface,            // #FFFFFF
    onSurface: AppColors.onSurface,        // #1E293B
    onSurfaceVariant: AppColors.onSurfaceVariant, // #64748B
    outline: AppColors.outline,            // #CBD5E1
  ),
  scaffoldBackgroundColor: AppColors.background, // #F8FAFC
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface,
      minimumSize: Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: Size.fromHeight(48),
      side: BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.surface,
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.outline,
    thickness: 1,
  ),
)
```

### 12.3 Tema Oscuro

> **Estado**: no implementado. Planeado para versión futura.

Cuando se implemente, se debe:
1. Crear `static ThemeData get dark` en `AppTheme`
2. Invertir la paleta neutral (surface oscuro, texto claro)
3. Mantener los colores de marca (primary, secondary, vehicle types) pero ajustar para contraste en fondo oscuro
4. Soportar `MediaQuery.platformBrightnessOf(context)` para modo automático

---

## 13. Reglas de UX

### 13.1 Touch Targets

| Elemento | Altura mínima | Implementación |
|---|---|---|
| Botones de acción | 48px | `minimumSize: Size.fromHeight(48)` en ElevatedButton y OutlinedButton |
| ListTile | 48px (default M3) | Estándar |
| IconButton | 48px (default M3) | Estándar |
| ChoiceChip | default M3 | Estándar |

### 13.2 Acciones Destructivas

- **Siempre** requieren confirmación mediante `showConfirmDialog`.
- El botón de confirmación se muestra en rojo (`isDestructive: true`).
- El texto explica que la acción es irreversible.

### 13.3 Estados Vacíos

- Siempre muestran un ícono contextual grande (64px).
- Incluyen un título claro sobre qué falta.
- Ofrecen un camino a seguir (CTA) cuando es posible.
- El CTA debe llevar directamente a la acción que resuelve el vacío.

### 13.4 Estados de Error

- Muestran un mensaje descriptivo (no genérico).
- Siempre ofrecen un botón de "Reintentar" si aplica.
- No bloquean al usuario sin opciones.

### 13.5 Formularios

- Validación en tiempo real (al escribir, no solo al submit).
- Campos requeridos marcados con `*` en el label.
- Teclado numérico para campos de costo/kilometraje (`TextInputType.number`).
- El botón de guardar ocupa todo el ancho con altura 48px.
- Padding consistente de 16px alrededor del formulario.

### 13.6 Idioma

- **Todo el UI está en español**. No hay sistema de localización (i18n).
- Los textos están hardcodeados en los widgets.

### 13.7 Feedback

- Toda acción de escritura (crear, editar, eliminar) debe mostrar feedback visual.
- Crear/editar exitoso → SnackBar + navegación hacia atrás.
- Eliminar → confirmación previa + SnackBar o actualización de lista.

---

## 14. Apéndice: Guía Rápida de Uso

### 14.1 Usar Colores

```dart
import 'package:motorcheck/core/theme/app_colors.dart';

// Color primario
final bg = AppColors.primary;

// Color por tipo de vehículo
final vehicleColor = AppColors.forVehicleType(vehicle.type);

// Fondo tintado para avatar
final avatarBg = AppColors.forVehicleType(type).withValues(alpha: 0.15);

// Color de error
final errorColor = AppColors.error;
```

### 14.2 Usar Tipografía

```dart
// Desde el tema (recomendado — responde a cambios de tema)
final title = Theme.of(context).textTheme.titleMedium;
final body = Theme.of(context).textTheme.bodyMedium;

// Desde la clase estática (solo si necesitas consistencia absoluta)
final headline = AppTextStyles.headlineLarge;
```

### 14.3 Usar Componentes Compartidos

```dart
import 'package:motorcheck/shared/widgets/loading_indicator.dart';
import 'package:motorcheck/shared/widgets/empty_state.dart';
import 'package:motorcheck/shared/widgets/error_state.dart';
import 'package:motorcheck/shared/widgets/confirm_dialog.dart';

// Loading
const LoadingIndicator(message: 'Cargando...');

// Empty
EmptyState(
  icon: Icons.directions_car,
  title: 'No hay vehículos',
  subtitle: 'Agrega el primero',
  onAction: () => context.push('/vehicles/new'),
  actionLabel: 'Agregar vehículo',
);

// Error
ErrorState(
  message: 'No se pudo cargar',
  onRetry: () => ref.invalidate(provider),
);

// Confirmación
final ok = await showConfirmDialog(
  context,
  title: '¿Eliminar?',
  message: 'Esta acción no se puede deshacer.',
  confirmLabel: 'Eliminar',
  isDestructive: true,
);
```

### 14.4 Agregar un Componente Nuevo

Al crear un nuevo componente de UI, seguir este checklist:

1. **Ubicación**: `lib/shared/widgets/` si es genérico, `lib/features/<feature>/widgets/` si es específico.
2. **Dumb component**: solo recibe datos y callbacks, sin estado propio.
3. **Usar tokens del tema**: colores, textos y estilos desde `Theme.of(context)`, no hardcodeados.
4. **`const` constructor**: si el widget lo permite.
5. **Documentar en este archivo**: agregar la API del componente a la sección 7 u 8.
6. **Estados**: considerar estados vacío, loading, error y normal.

### 14.5 Archivos Clave del Sistema de Diseño

| Archivo | Propósito |
|---|---|
| `lib/core/theme/app_colors.dart` | Todos los tokens de color |
| `lib/core/theme/app_text_styles.dart` | Escala tipográfica |
| `lib/core/theme/app_theme.dart` | Configuración de ThemeData |
| `lib/shared/widgets/loading_indicator.dart` | Estado de carga |
| `lib/shared/widgets/empty_state.dart` | Estado vacío |
| `lib/shared/widgets/error_state.dart` | Estado de error |
| `lib/shared/widgets/confirm_dialog.dart` | Diálogo de confirmación |
| `lib/core/utils/formatters.dart` | Formateo de fechas, moneda, kilometraje |

---

> **Última actualización**: Julio 19, 2026
> **Mantenedor**: este documento debe actualizarse cuando se agreguen, modifiquen o eliminen componentes, colores o patrones de diseño.
