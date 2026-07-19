# Sistema de Diseño

## Colores

### Paleta Principal

| Token | Hex | Uso |
|-------|-----|-----|
| primary | `#2563EB` | Botones, FAB, estados activos |
| primaryVariant | `#1D4ED8` | Estados presionados, acentos oscuros |
| secondary | `#7C3AED` | Elementos de acento |
| secondaryVariant | `#6D28D9` | Estados presionados secundarios |

### Paleta Neutral

| Token | Hex | Uso |
|-------|-----|-----|
| background | `#F8FAFC` | Fondo del scaffold (claro) |
| surface | `#FFFFFF` | Tarjetas, diálogos |
| onSurface | `#1E293B` | Texto principal |
| onSurfaceVariant | `#64748B` | Texto secundario, leyendas |
| outline | `#CBD5E1` | Bordes, divisores |
| error | `#DC2626` | Estados de error |

### Colores por Tipo de Vehículo

| Tipo | Color |
|------|-------|
| car (carro) | `#2563EB` (azul) |
| motorcycle (moto) | `#7C3AED` (púrpura) |
| bike (bicicleta) | `#059669` (verde) |
| truck (camión) | `#D97706` (ámbar) |
| other (otro) | `#64748B` (gris) |

## Tipografía

Escala basada en Material Design 3 type scale:

| Token | Tamaño | Peso | Uso |
|-------|--------|------|-----|
| displayLarge | 57px | 400 | (reservado) |
| headlineLarge | 32px | 600 | Títulos de pantalla |
| headlineMedium | 28px | 600 | Títulos de tarjeta |
| titleLarge | 22px | 500 | Encabezados de sección |
| titleMedium | 16px | 500 | List tiles |
| bodyLarge | 16px | 400 | Texto de cuerpo |
| bodyMedium | 14px | 400 | Texto secundario |
| labelLarge | 14px | 500 | Botones |
| labelMedium | 12px | 500 | Chips, badges |

## Espaciado

| Token | Tamaño |
|-------|--------|
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |
| xxl | 48px |

## Formas

| Componente | Border Radius |
|------------|--------------|
| Tarjetas | 12px |
| Botones | 8px |
| Chips | 16px (totalmente redondeado) |
| Campos de entrada | 8px |

## Componentes Base

### AppCard
- Fondo color surface
- 12px border radius
- Sin elevación (`Elevation(0)`)
- 16px padding interno

### AppButton
- Primario: relleno, color primary
- Secundario: contorno, borde color primary
- Destructivo: relleno, color error (para acciones de eliminar)
- Altura mínima: 48px
- 8px border radius

### AppInput
- Borde contorneado
- 8px border radius
- Label flotante superior
- Texto de ayuda inferior para validación

### EmptyState
- Centrado con ícono + título + subtítulo opcional
- Se usa cuando las listas no tienen datos

### ErrorState
- Centrado con ícono de error + mensaje + botón de reintentar
- Se usa cuando falla la carga de datos
