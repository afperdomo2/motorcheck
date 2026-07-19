# MotorCheck

Aplicación Flutter para el seguimiento del mantenimiento personal de vehículos.

## Características

- Registro de múltiples vehículos (carros, motos, bicicletas, camiones)
- Vehículo seleccionado por defecto
- Registro de mantenimientos con múltiples items (cambio de aceite, llantas, filtros, frenos, etc.)
- Costos de mano de obra y repuestos por item
- Almacenamiento local con SQLite (sin conexión a internet)
- Tema claro con sistema de diseño consistente

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| UI | Flutter 3.x / Dart 3.12 |
| Estado | Riverpod 2.x |
| Navegación | GoRouter 14.x |
| Base de datos | sqflite (SQLite) |
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

# Ejecutar la app
flutter run

# Formatear código
dart format .
```

## Arquitectura

Estructura orientada a features con patrón Smart/Dumb components.

```
lib/
├── main.dart              # Punto de entrada + ProviderScope
├── app.dart               # MaterialApp.router + tema
├── core/                  # Infraestructura compartida
│   ├── theme/             # Sistema de diseño
│   ├── database/          # SQLite
│   └── utils/             # Utilidades
├── features/              # Features de negocio
│   ├── vehicles/          # CRUD de vehículos
│   ├── maintenance/       # CRUD de mantenimientos
│   └── dashboard/         # Panel principal
├── shared/widgets/        # Componentes reutilizables
└── routes/                # Configuración de rutas
```

Ver la carpeta `docs/` para documentación detallada de arquitectura, base de datos, sistema de diseño y testing.

## Configuración del Entorno

1. Clonar el repositorio
2. `flutter pub get`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `flutter run`

## Hooks Pre-commit (Lefthook)

```bash
# Instalar lefthook (requiere Go instalado)
go install github.com/evrone/lefthook@latest

# Instalar los hooks en el repo
lefthook install
```

Los hooks ejecutan `dart format`, `flutter analyze` y `flutter test` automáticamente antes de cada commit.
