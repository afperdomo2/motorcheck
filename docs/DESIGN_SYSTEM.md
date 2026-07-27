# MotorCheck — Sistema de Diseño

> Guía completa del lenguaje visual, componentes y patrones UX de la aplicación.
> Versión 2.0 · Julio 2026

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
- **Soporte Light + Dark**: la app tiene temas claro y oscuro completos, configurables por el usuario.

---

## 2. Paleta de Color

### 2.1 Colores Principales

| Token | Hex | Muestra | Uso |
|---|---|---|---|
| `primary` | `#3B82F6` | ██ | Botones principales, FAB, enlaces, bordes de selección |
| `primaryVariant` | `#2563EB` | ██ | Estados hover/presionados de primary |
| `secondary` | `#8B5CF6` | ██ | Acentos decorativos, variante de moto |
| `secondaryVariant` | `#7C3AED` | ██ | Estados hover/presionados de secondary |

**Ratio de contraste** (sobre blanco `#FFFFFF`):
- `primary` → 4.65:1
- `secondary` → 5.3:1

### 2.2 Paleta Neutral

| Token | Hex | Muestra | Modo Light | Modo Dark |
|---|---|---|---|---|
| `background` | `#F8FAFC` / `#0F172A` | ██ | Fondo del scaffold | Fondo oscuro profundo |
| `surface` | `#FFFFFF` / `#1E293B` | ██ | Cards, diálogos, AppBar | Superficies elevadas |
| `onSurface` | `#1E293B` / `#F1F5F9` | ██ | Texto principal, títulos | Texto claro |
| `onSurfaceVariant` | `#64748B` / `#94A3B8` | ██ | Texto secundario | Texto secundario |
| `outline` | `#CBD5E1` / `#475569` | ██ | Bordes, dividers | Bordes oscuros |

### 2.3 Colores Semánticos

| Token | Hex | Muestra | Uso |
|---|---|---|---|
| `error` | `#EF4444` | ██ | Estados de error, acciones destructivas, iconos de eliminar |

### 2.4 Colores por Tipo de Vehículo

Cada tipo de vehículo tiene un color de identidad:

| Tipo | Clave | Hex | Muestra | Ícono |
|---|---|---|---|---|
| Carro | `car` | `#3B82F6` | ██ | `directions_car` |
| Moto | `motorcycle` | `#8B5CF6` | ██ | `motorcycle` |
| Bicicleta | `bike` | `#10B981` | ██ | `pedal_bike` |
| Camión | `truck` | `#F59E0B` | ██ | `local_shipping` |
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
| Sistema | Material Design 3 Type Scale |

### 3.2 Tabla Completa

| Token | Tamaño | Peso | Uso en la app |
|---|---|---|---|
| `headlineLarge` | 32px | 600 | Valores numéricos destacados en QuickStats |
| `headlineMedium` | 28px | 600 | Título de pantalla ("Dashboard") |
| `titleLarge` | 22px | 500 | Nombre del vehículo, total vehículos |
| `titleMedium` | 16px | 500 | Título de cards, títulos de sección |
| `bodyLarge` | 16px | 400 | Texto de cuerpo principal |
| `bodyMedium` | 14px | 400 | Subtítulos, texto secundario, fechas |
| `labelLarge` | 14px | 500 | Botones, etiquetas de formulario |
| `labelMedium` | 12px | 500 | Placas de vehículos, chips, badges |

**Uso**: siempre `Theme.of(context).textTheme.*` para que cambios de tema se propaguen automáticamente.

---

## 4. Espaciado

| Token | Valor | Uso principal |
|---|---|---|
| `xs` | 4px | Gap ícono↔texto en chips |
| `sm` | 8px | Gap entre bloques de texto, separación entre cards |
| `md` | 16px | **Unidad base**: padding de pantalla, padding de cards |
| `lg` | 24px | Separación de botones de acción |
| `xl` | 32px | Padding en EmptyState/ErrorState, height de divider |
| `xxl` | 48px | Altura mínima de botones de acción |

### Dónde se aplica cada token

| Contexto | Token |
|---|---|
| Padding de pantalla | `md` (16px) |
| Padding interno de Card | `md` (16px) |
| Padding de Card anidada (ItemFormRow) | `12px` |
| Gap entre campos de formulario | `md` (16px) |
| Gap entre secciones en Card | `sm` (8px) |
| Gap ícono↔etiqueta en fila | `xs` (4px) |
| Padding de EmptyState / ErrorState | `xl` (32px) |
| Altura mínima de botón | `xxl` (48px) |

### Layouts de lista

```dart
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

| Componente | Radio |
|---|---|
| Cards | 12px |
| Botones (Elevated + Outlined) | 8px |
| Campos de texto (Input) | 8px |
| ChoiceChips | Pill shape automática (M3) |

MotorCheck usa un diseño **completamente plano**: elevación 0 en cards y AppBar.
Solo `scrolledUnderElevation: 1` al hacer scroll.

---

## 6. Iconografía

### 6.1 Navegación (Bottom Bar — 4 tabs)

| Pantalla | Inactivo | Activo |
|---|---|---|
| Dashboard | `dashboard_outlined` | `dashboard` |
| Mantenimientos | `build_outlined` | `build` |
| Vehículos | `directions_car_outlined` | `directions_car` |
| Configuración | `tune` | `tune` |

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
| Calendario / Fecha | `calendar_today` | 16px |
| Kilometraje | `speed` | 16px |
| Navegar / Siguiente | `chevron_right` | default |

### 6.4 Estados de UI

| Estado | Ícono | Tamaño | Color |
|---|---|---|---|
| Empty (dashboard) | `directions_car` | 64px | `disabledColor` |
| Empty (mantenimientos) | `build` | 64px | `disabledColor` |
| Error | `error_outline` | 64px | `Colors.red` |
| Loading | `CircularProgressIndicator` | default | `primary` |

### 6.5 Estadísticas (Dashboard)

| Estadística | Ícono | Tamaño |
|---|---|---|
| Mantenimientos | `build` | 28px |
| Total gastado | `payments` | 28px |

---

## 7. Componentes Compartidos

Los componentes compartidos están en `lib/shared/widgets/`. Son widgets dumb: reciben datos y callbacks, no manejan estado por sí mismos.

### 7.1 LoadingIndicator

Spinner centrado con mensaje opcional bajo él.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `message` | `String?` | No | `null` |

### 7.2 EmptyState

Ícono grande (64px) + título + subtítulo opcional + botón CTA opcional.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `icon` | `IconData` | Sí | — |
| `title` | `String` | Sí | — |
| `subtitle` | `String?` | No | `null` |
| `onAction` | `VoidCallback?` | No | `null` |
| `actionLabel` | `String?` | No | `null` |

El botón solo se renderiza si **ambos** `onAction` y `actionLabel` son no-nulos.

**Variantes en la app**:

| Pantalla | Icon | Title | Subtitle | Action |
|---|---|---|---|---|
| Dashboard (sin vehículo) | `directions_car` | "Bienvenido a MotorCheck" | "Agrega un vehículo para comenzar" | "Agregar vehículo" |
| Vehículos (lista vacía) | `directions_car` | "No tienes vehículos" | "Agrega tu primer vehículo..." | "Agregar vehículo" |
| Mantenimientos (sin vehículo) | `build` | "Selecciona un vehículo" | "Elige un vehículo..." | "Ir a vehículos" |
| Mantenimientos (sin registros) | `build` | "Sin mantenimientos" | "Agrega el primer..." | "Agregar mantenimiento" |

### 7.3 ErrorState

Ícono de error (64px, rojo) + "Algo salió mal" + mensaje + botón Reintentar opcional.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `message` | `String` | Sí | — |
| `onRetry` | `VoidCallback?` | No | `null` |

### 7.4 showConfirmDialog

Función top-level que muestra un `AlertDialog` de confirmación.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `context` | `BuildContext` | Sí | — |
| `title` | `String` | Sí | — |
| `message` | `String` | Sí | — |
| `confirmLabel` | `String` | No | `'Confirmar'` |
| `cancelLabel` | `String` | No | `'Cancelar'` |
| `isDestructive` | `bool` | No | `false` |

Retorna `Future<bool?>` — `true` si confirma, `false` si cancela, `null` si cierra.

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

### 8.1 VehicleCard

Muestra un vehículo con avatar coloreado por tipo, nombre, marca/modelo, placa, kilometraje, y estrella de vehículo default.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `vehicle` | `Vehicle` | Sí | — |
| `onTap` | `VoidCallback` | Sí | — |
| `onSetDefault` | `VoidCallback?` | No | `null` |

La estrella a la derecha marca si es el vehículo default (⭐ dorada) o no (☆ outline). Al tocar la estrella, llama a `onSetDefault` con feedback háptico. El PopupMenu de editar/eliminar no existe en este componente; la edición y eliminación se manejan en la pantalla de detalle.

### 8.2 VehicleTypeSelector

Selector de tipo de vehículo con `ChoiceChip` en layout `Wrap`.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `selectedType` | `String?` | Sí | — |
| `onChanged` | `ValueChanged<String>` | Sí | — |

### 8.3 TimelineTile

Componente principal de la lista de mantenimientos. Muestra cada mantenimiento como una card dentro de una línea de tiempo vertical con conector.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `maintenance` | `Maintenance` | Sí | — |
| `onTap` | `VoidCallback` | Sí | — |
| `vehicleName` | `String?` | No | `null` |
| `vehicleType` | `String?` | No | `null` |
| `workshopName` | `String?` | No | `null` |
| `workshopLocation` | `String?` | No | `null` |
| `items` | `List<MaintenanceItem>` | No | `[]` |
| `showConnector` | `bool` | No | `true` |
| `isLastInGroup` | `bool` | No | `false` |

Muestra: nombre del vehículo (si no es null), badges de categorías (máx 2 + "+N"), kilometraje, taller, notas, costo total. Las categorías usan los iconos definidos en `MaintenanceCategories`.

### 8.4 ItemFormRow

Fila de formulario para un ítem de mantenimiento dentro del formulario.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `item` | `MaintenanceItem` | Sí | — |
| `index` | `int` | Sí | — |
| `onRemove` | `VoidCallback` | Sí | — |
| `canRemove` | `bool` | Sí | — |
| `onChanged` | `ValueChanged<MaintenanceItem>` | Sí | — |
| `vehicleType` | `String` | Sí | — |

Campos: dropdown de categoría (filtrado por tipo de vehículo), campo numérico de repuestos ($), campo de notas. Las categorías disponibles varían según `vehicleType` (ver `lib/features/maintenance/categories.dart`).

### 8.5 QuickStats

Resumen dashboard con total de vehículos, conteo de mantenimientos y total gastado.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `summary` | `DashboardSummary` | Sí | — |

Muestra: icono de garaje + total vehículos, dos stats lado a lado (mantenimientos + total gastado), y último mantenimiento registrado.

### 8.6 RecentActivity

Lista de últimos mantenimientos del vehículo.

**API**:
| Parámetro | Tipo | Requerido | Default |
|---|---|---|---|
| `summary` | `DashboardSummary` | Sí | — |

Muestra lista de `ListTile` con CircleAvatar por tipo de vehículo. Al tocar un ítem, navega a `/maintenance/:id/edit`.

### 8.7 ExpiryAlerts

Alertas de documentos por vencer (SOAT y Tecnomecánica). Se muestra automáticamente como `ConsumerWidget` que lee `vehiclesProvider`.

Sin parámetros (es `ConsumerWidget`). Filtra vehículos con `soatExpiresAt` o `rtmExpiresAt` a 30 días o menos de vencer (o ya vencidos). Muestra un Card con header "Documentos por vencer" y lista de alertas con badge de días restantes coloreado (rojo/amarillo según proximidad). Al tocar, navega al detalle del vehículo.

---

## 9. Patrones de Layout

### 9.1 Estructura de Pantalla Típica

```
┌──────────────────────────────────────────────┐
│ AppBar                                        │  ← elevation: 0, centrado
│  Título                  [action]             │
├──────────────────────────────────────────────┤
│                                              │
│  Content Area                                │
│  - padding: 16px                             │
│  - ScrollView / ListView                     │
│  - Cards con 16px padding                    │
│  - Gaps de 8-16px entre cards                │
│                                              │
│                                    ┌────┐    │
│                                    │ +  │    │  ← FAB (opcional)
│                                    └────┘    │
└──────────────────────────────────────────────┘
```

### 9.2 Pantalla de Lista

```dart
Scaffold(
  appBar: AppBar(title: Text('Título')),
  body: asyncData.when(
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

### 9.3 Pantalla de Formulario

```dart
Scaffold(
  appBar: AppBar(title: Text('Título')),
  body: Form(
    key: formKey,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Campo1,
          SizedBox(height: 16),
          Campo2,
          SizedBox(height: 32),
          SizedBox(
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

---

## 10. Estados de UI

Toda pantalla de la app maneja **4 estados**:

| Estado | Componente | ¿Cuándo? |
|---|---|---|
| Loading | `LoadingIndicator` | Datos cargando de BD/async |
| Empty | `EmptyState` | Lista vacía, sin vehículo seleccionado |
| Content | Widgets de feature | Datos disponibles |
| Error | `ErrorState` | Excepción en carga de datos |

**Implementación con Riverpod**:
```dart
asyncValue.when(
  loading: () => const LoadingIndicator(message: 'Cargando...'),
  error: (error, stack) => ErrorState(
    message: error.toString(),
    onRetry: () => ref.invalidate(provider),
  ),
  data: (items) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.directions_car,
        title: 'No hay datos',
        subtitle: 'Agrega un registro para comenzar',
        onAction: () => context.push('/route/new'),
        actionLabel: 'Agregar',
      );
    }
    return ContentList(items: items);
  },
)
```

---

## 11. Interacciones y Feedback

### 11.1 Navegación

| Acción | Comportamiento |
|---|---|
| Bottom Navigation Bar | 4 tabs: Dashboard / Mantenimientos / Vehículos / Configuración |
| FAB (+) | Navega a formulario de creación (`context.push('/route/new')`) |
| Tap en Card | Navega al detalle |
| Tap en ListTile (RecentActivity) | `context.push('/maintenance/:id/edit')` |
| Back button / gesto | `context.pop()` automático vía GoRouter |
| Tap en alerta (ExpiryAlerts) | `context.push('/vehicles/:id')` |

### 11.2 Acciones Contextuales

| Acción | Mecanismo | Feedback |
|---|---|---|
| Guardar formulario | ElevatedButton "Guardar" | SnackBar de éxito/error, navega hacia atrás |
| Eliminar | PopupMenuButton → "Eliminar" | **Siempre** confirmación con `showConfirmDialog(isDestructive: true)` |
| Marcar default | Estrella en VehicleCard | Animación de transición, actualización inmediata |

### 11.3 Formateo de Datos

| Dato | Formato | Ejemplo |
|---|---|---|
| Fecha | `d MMMM yyyy` o `yyyy-MM-dd` (ISO 8601 para BD) | 15 julio 2026 |
| Moneda | `$X,XXX` (sin decimales) | $1,250 |
| Kilometraje | `X km` o `X,XXX km` (≥1000) | 15000 km |

Ver `lib/core/utils/formatters.dart` para la implementación completa.

---

## 12. Configuración de Tema

### 12.1 Modos de Tema

La app soporta **3 modos** de tema, configurables desde la pantalla de Configuración mediante un `SegmentedButton<ThemeMode>`:

| Modo | Descripción |
|---|---|
| `ThemeMode.system` | Sigue el tema del sistema operativo |
| `ThemeMode.light` | Tema claro forzado |
| `ThemeMode.dark` | Tema oscuro forzado |

La preferencia se persiste en `SharedPreferences` y se carga al iniciar la app.

### 12.2 ThemeData

Ambos temas (`AppTheme.light` y `AppTheme.dark`) comparten la misma estructura:
- `useMaterial3: true`
- Cards: elevación 0, border radius 12px
- AppBar: centrado, elevación 0, `scrolledUnderElevation: 1`
- Botones: altura mínima 48px, border radius 8px
- Inputs: border radius 8px, padding horizontal 16px, vertical 12px

**Archivos clave**:
- `lib/core/theme/app_colors.dart` — Tokens light + dark
- `lib/core/theme/app_text_styles.dart` — Escala tipográfica
- `lib/core/theme/app_theme.dart` — `ThemeData` light y dark
- `lib/core/theme/theme_mode_provider.dart` — Persistencia del modo
- `lib/features/settings/screens/settings_screen.dart` — UI del selector

---

## 13. Reglas de UX

### 13.1 Touch Targets

| Elemento | Altura mínima |
|---|---|
| Botones de acción | 48px |
| ListTile | 48px (default M3) |
| IconButton | 48px (default M3) |

### 13.2 Acciones Destructivas

- **Siempre** requieren confirmación mediante `showConfirmDialog`.
- El botón de confirmación se muestra en rojo (`isDestructive: true`).

### 13.3 Estados Vacíos

- Ícono contextual grande (64px) + título claro + CTA cuando es posible.
- El CTA debe llevar directamente a la acción que resuelve el vacío.

### 13.4 Estados de Error

- Mensaje descriptivo (no genérico) + botón de "Reintentar".
- No bloquean al usuario sin opciones.

### 13.5 Formularios

- Campos requeridos marcados con `*` en el label.
- Teclado numérico para campos de costo/kilometraje (`TextInputType.number`).
- Botón de guardar full-width con altura 48px.
- Padding consistente de 16px alrededor.

### 13.6 Idioma

- **Todo el UI está en español**. Sin sistema de localización (i18n).
- Los textos están hardcodeados en los widgets.

---

## 14. Apéndice: Guía Rápida de Uso

### 14.1 Usar Colores

```dart
import '../../core/theme/app_colors.dart';

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
// Siempre desde el tema (responde a cambios light/dark)
final title = Theme.of(context).textTheme.titleMedium;
final body = Theme.of(context).textTheme.bodyMedium;
```

### 14.3 Usar Componentes Compartidos

```dart
// Imports relativos desde el feature
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/confirm_dialog.dart';
```

### 14.4 Archivos Clave

| Archivo | Propósito |
|---|---|
| `lib/core/theme/app_colors.dart` | Tokens de color (light + dark) |
| `lib/core/theme/app_text_styles.dart` | Escala tipográfica |
| `lib/core/theme/app_theme.dart` | `ThemeData` light + dark |
| `lib/core/theme/theme_mode_provider.dart` | Persistencia del modo de tema |
| `lib/shared/widgets/loading_indicator.dart` | Estado de carga |
| `lib/shared/widgets/empty_state.dart` | Estado vacío |
| `lib/shared/widgets/error_state.dart` | Estado de error |
| `lib/shared/widgets/confirm_dialog.dart` | Diálogo de confirmación |
| `lib/core/utils/formatters.dart` | Formateo de fechas, moneda, kilometraje |
| `lib/features/maintenance/categories.dart` | Categorías por tipo de vehículo |

---

> **Última actualización**: Julio 26, 2026
> **Mantenedor**: este documento debe actualizarse cuando se agreguen, modifiquen o eliminen componentes, colores o patrones de diseño.
>
> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
