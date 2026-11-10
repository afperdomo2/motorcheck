# MotorCheck — Sistema de Diseño v3.0

> Identidad **grafito + ámbar industrial**, Material 3 y tipografía Barlow.
> Última actualización: noviembre 2026.

## 1. Principios

1. **Un solo acento:** el ámbar significa acción o atención.
2. **Superficies tonales:** cards con borde de 1 px, sin sombras.
3. **Mobile-first:** una columna, targets de 48 dp y 8 dp entre acciones.
4. **Paridad light/dark:** todo color nace de un token del tema.
5. **Estado con icono + texto + color**, nunca solo color.
6. **Español de Colombia** en textos, fechas, moneda y date pickers.

## 2. Paleta

### Light

| Rol | Hex | Uso |
|---|---|---|
| background | `#F5F4F1` | fondo del scaffold |
| surface | `#FFFFFF` | cards, AppBar, inputs |
| surfaceContainerLow | `#F0EEE9` | chips y contenedores suaves |
| surfaceContainer | `#EAE7E0` | contenedores y skeletons |
| onSurface | `#1B1D21` | texto principal |
| onSurfaceVariant | `#5A5F66` | texto secundario |
| outline | `#7F848B` | bordes de componentes |
| outlineVariant | `#D8D4CC` | divisores y bordes de card |
| primary | `#B45309` | CTA, FAB, selección |
| onPrimary | `#FFFFFF` | texto sobre ámbar |
| primaryContainer | `#FDE68A` | fondos de selección |
| accentText | `#92400E` | texto/icono sobre ámbar claro |

### Dark

| Rol | Hex |
|---|---|
| background | `#121417` |
| surface | `#1A1D21` |
| surfaceContainer | `#22262B` |
| onSurface | `#E8E6E1` |
| onSurfaceVariant | `#A6A9AE` |
| outline | `#6B7077` |
| outlineVariant | `#343941` |
| primary | `#FBBF24` |
| onPrimary | `#1F2328` |

### Estados semánticos

| Estado | Light | Dark |
|---|---|---|
| success | `#047857` | `#34D399` |
| warning | `#B45309` | `#FBBF24` |
| danger | `#B91C1C` | `#F87171` |

Cada estado tiene contenedor y color `on*` propio. En texto siempre se usa
el par `onContainer / container`.

### Identidad por vehículo

| Tipo | Light | Dark |
|---|---|---|
| Carro | `#1D4ED8` | `#93B4FF` |
| Moto | `#6D28D9` | `#C4B5FD` |
| Bicicleta | `#047857` | `#6EE7B7` |
| Camión | `#0E7490` | `#67E8F9` |
| Otro | `#475569` | `#CBD5E1` |

El azul está reservado para “carro”: no se usa como color de marca.

## 3. Tipografía

- **Barlow Semi Condensed 600/700:** títulos y cifras.
- **Barlow 400/500/600:** cuerpo, labels y navegación.
- Fuentes empaquetadas en `assets/fonts/` (OFL), sin red.

| Token | Tamaño / alto | Familia | Uso |
|---|---|---|---|
| headlineLarge | 32/40 | Semi Condensed | cabeceras grandes |
| headlineMedium | 28/36 | Semi Condensed | totales |
| headlineSmall | 24/32 | Semi Condensed | km y montos |
| titleLarge | 22/28 | Semi Condensed | título de pantalla |
| titleMedium | 16/24 | Semi Condensed | títulos de card |
| titleSmall | 14/20 | Semi Condensed | filas destacadas |
| bodyLarge | 16/24 | Barlow | cuerpo |
| bodyMedium | 14/20 | Barlow | secundario |
| bodySmall | 12/16 | Barlow | helper |
| labelLarge | 14/20 | Barlow | botones |
| labelMedium | 12/16 | Barlow | chips |
| labelSmall | 11/16 | Barlow | badges |

Ningún texto funcional por debajo de 11 px.

## 4. Espaciado, radios y elevación

- Grid de 4 pt: `4, 8, 12, 16, 24, 32, 48`.
- Listas: `AppSpacing.sm` (8) entre cards y `AppSpacing.lg` (16) entre
  secciones. Las cards no llevan margen propio: la separación la define el
  contenedor de la lista.
- Radios: cards 16, inputs/botones 12, pills 999.
- Elevación 0 en cards, botones y FAB. La jerarquía se logra con superficies
  tonales y bordes.

## 5. Tema

Archivos:

| Archivo | Propósito |
|---|---|
| `core/theme/app_colors.dart` | paleta cruda |
| `core/theme/app_semantic_colors.dart` | extensión `ThemeExtension` |
| `core/theme/app_text_styles.dart` | escala Barlow |
| `core/theme/app_theme.dart` | `ThemeData` y temas de componentes |
| `core/theme/app_spacing.dart` | espaciado |
| `core/theme/app_radii.dart` | radios |

**Regla:** los widgets consumen `Theme.of(context)` o
`AppSemanticColors.of(context)`. No se permiten colores literales fuera de
`core/theme/`.

## 6. Componentes compartidos

| Componente | Archivo | Uso |
|---|---|---|
| `VehicleAvatar` | `shared/widgets/vehicle_avatar.dart` | avatar por tipo |
| `StatusChip` | `shared/widgets/status_chip.dart` | estado ok/warning/danger/neutral |
| `SectionHeader` | `shared/widgets/section_header.dart` | título de sección + acción |
| `StatTile` | `shared/widgets/stat_tile.dart` | métrica compacta |
| `FormSection` | `shared/widgets/form_section.dart` | grupo de formulario |
| `StickyBottomBar` | `shared/widgets/sticky_bottom_bar.dart` | acción fija con safe area |
| `MonthHeader` | `features/maintenance/widgets/month_header.dart` | cabecera de mes con total |
| `DateField` | `shared/widgets/date_field.dart` | fecha con selector |
| `AppSnackBar` | `shared/widgets/app_snack_bar.dart` | feedback global |
| `EmptyState` | `shared/widgets/empty_state.dart` | vacío con CTA |
| `ErrorState` | `shared/widgets/error_state.dart` | error con reintento |
| `LoadingIndicator` | `shared/widgets/loading_indicator.dart` | carga |
| `showConfirmDialog` | `shared/widgets/confirm_dialog.dart` | confirmación destructiva |

### APIs

```dart
StatusChip(status: AppStatus.warning, label: 'Vence en 12 días', icon: Icons.schedule)
VehicleAvatar(type: 'car', size: 48)
FormSection(title: 'Documentos', icon: Icons.description_outlined, child: ...)
StickyBottomBar(child: FilledButton(...))
AppSnackBar.success('Vehículo guardado')
```

## 7. Pantallas

### Shell

- 4 tabs: Inicio, Mantenimientos, Vehículos, Ajustes.
- Etiquetas siempre visibles y badge de pendientes en Mantenimientos.
- AppBar alineada a la izquierda.

### Inicio

Saludo + estado del **vehículo por defecto** (o el primero si no hay
predeterminado): card del vehículo con documentos, próximos por km,
documentos por vencer (globales), gasto del mes y actividad reciente. FAB
“Registrar”.

### Vehículos

Cards con avatar de tipo, placa/kilometraje, favorito y menú contextual.
Detalle con editar/eliminar en menú overflow.

### Mantenimientos

Selector de vehículo reutilizando `VehicleSelectorSheet`, secciones por mes
con total, cards con costo y detalle de items.

### Formularios

Secciones, una columna, validación inline, barra inferior fija, guardia de
cambios sin guardar y snackbar de éxito.

### Ajustes

Apariencia, catálogos y acerca de, agrupados en cards.

## 8. Localización y formatos

- `flutter_localizations` con `locale: es_CO`.
- Moneda: `$ 1.250` (`NumberFormat.currency` con patrón propio).
- Kilometraje: `15.000 km` (`decimalPattern('es_CO')`).
- Fechas: `15 de julio de 2026`.
- Date pickers y textos de Material en español.

## 9. Accesibilidad

- Contraste mínimo 4.5:1 en texto y 3:1 en componentes.
- Targets de 48×48 dp con 8 dp de separación.
- No se comunica información solo con color.
- Iconos decorativos con `Semantics` o tooltip cuando son acciones. El grid de
  íconos de categorías usa `Tooltip` + `Semantics` con estado seleccionado.
- Soporte de text scale hasta 2.0 sin overflow. Los AppBar de dos líneas se
  reemplazaron por títulos de una línea; las acciones y métricas permiten 2
  líneas o escalan con `FittedBox`.
- En escritorio el contenido se centra con un máximo de 720 px; las hojas
  inferiores usan un máximo de 640 px.
- Respeto a `MediaQuery.disableAnimations`.

## 10. Verificación

```bash
flutter analyze
flutter test --concurrency 1
flutter test test/core/theme/contrast_test.dart
```

Prueba manual: 360×800 y 412×915, light/dark, text scale 1.0/1.3/2.0,
teclado abierto, date picker en español y ventana Linux 420×880.

> Este documento es la fuente de verdad visual. Si cambias tokens o
> componentes, actualiza también `AGENTS.md`.
