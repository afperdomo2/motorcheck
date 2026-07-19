# MotorCheck - Instrucciones para Agentes

## Resumen del Proyecto

MotorCheck es una aplicación Flutter para el seguimiento del mantenimiento personal de vehículos.
Usuario único, almacenamiento local SQLite, sin autenticación.

## Comandos

```bash
# Instalar dependencias
flutter pub get

# Generar código (después de modificar clases anotadas con @freezed o @riverpod)
dart run build_runner build --delete-conflicting-outputs

# Modo watch para generación de código (recomendado durante desarrollo)
dart run build_runner watch --delete-conflicting-outputs

# Formatear código
dart format .

# Análisis estático (REQUERIDO antes de hacer commit)
flutter analyze

# Ejecutar todas las pruebas
flutter test

# Ejecutar pruebas con cobertura
flutter test --coverage

# Ejecutar la app en un dispositivo/emulador conectado
flutter run
```

## Reglas de Trabajo

1. **Antes de hacer commit**: ejecutar `flutter analyze` (cero advertencias), `dart format .` y `flutter test`
2. **Después de modificar modelos o providers**: ejecutar `dart run build_runner build --delete-conflicting-outputs` inmediatamente
3. **Constructores const**: siempre usar `const` en widgets estáticos, bordes, padding, etc.
4. **Patrón Smart/Dumb**: pantallas + providers = smart (lógica de estado), widgets = dumb (reciben datos + callbacks)
5. **Nombrado de archivos**: snake_case para archivos, PascalCase para clases
6. **Imports**: usar imports relativos para archivos del proyecto, imports de paquete para dependencias externas
7. **Riverpod**: usar ConsumerWidget/ConsumerStatefulWidget para la UI, Notifier para el estado
8. **Modelos**: todos los modelos usan @freezed para inmutabilidad, igualdad, copyWith y serialización JSON

## Arquitectura

**Orientada a features** con core compartido y widgets reutilizables.
Ver `docs/architecture.md` y `docs/database.md` para más detalles.

```
lib/
├── main.dart              # Punto de entrada + ProviderScope
├── app.dart               # MaterialApp.router + tema
├── core/
│   ├── theme/             # Colores, AppTheme, TextStyles
│   ├── database/          # SQLite helper + DDL
│   └── utils/             # Formateadores, extensiones
├── features/
│   ├── vehicles/          # CRUD vehículos + selección por defecto
│   ├── maintenance/       # CRUD mantenimientos + items
│   └── dashboard/         # Resumen del vehículo por defecto
├── shared/widgets/        # Componentes dumb reutilizables
└── routes/                # Configuración GoRouter
```

## Skills Disponibles

Carga estas skills cuando sean relevantes para la tarea:

| Skill | Ruta | Cuándo Usar |
|-------|------|-------------|
| flutter-expert | `.agents/skills/flutter-expert/` | Widgets, estado, navegación, rendimiento |
| flutter-animations | `.agents/skills/flutter-animations/` | Animaciones, transiciones, efectos de movimiento |
| dart-best-practices | `.agents/skills/dart-best-practices/` | Estilo de código, convenciones, características del lenguaje |

## Context7 MCP

Usa Context7 MCP para obtener documentación actualizada de:
- APIs de librerías (Riverpod, GoRouter, sqflite, freezed, etc.)
- Preguntas de configuración sobre cualquier dependencia
- Documentación específica de versiones

Siempre resuelve el ID de la librería primero (`context7_resolve-library-id`), luego consulta la documentación.
