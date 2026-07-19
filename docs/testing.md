# Estrategia de Testing

## Tipos de Pruebas

| Tipo | Herramienta | Alcance |
|------|-------------|---------|
| Unitarias | flutter_test + mocktail | Repositorios, providers, utils |
| Widget | flutter_test | Componentes UI (pantallas, widgets) |
| Base de datos | sqflite_common_ffi | Consultas SQLite en memoria |

## Estructura

```
test/                           # Espejo de lib/
├── core/
│   ├── database/               # Pruebas de SQLite con sqflite_common_ffi
│   └── utils/                  # Pruebas de formateadores
├── features/
│   ├── vehicles/               # Modelos, repositorios
│   └── maintenance/            # Modelos
└── shared/widgets/             # Widgets dumb
```

## Ejecución

```bash
flutter test                                    # Todas las pruebas
flutter test test/features/vehicles/            # Por feature
flutter test --name "formatea"                  # Por nombre (regex)
flutter test test/features/vehicles/vehicle_test.dart  # Archivo específico
flutter test --coverage                         # Con cobertura
```

## Convenciones

1. Los archivos de prueba reflejan la estructura de `lib/` dentro de `test/`
2. Nombrado: `*_test.dart` coincidiendo con el archivo fuente
3. Agrupar pruebas por método o comportamiento usando `group()`
4. Usar `setUp`/`setUpAll` para arreglos comunes
5. Preferir `mocktail` sobre `mockito` (sin generación de código)
6. `sqflite_common_ffi` para pruebas de BD en memoria
7. **NO ejecutar `flutter test` tras cambios en archivos `.md` o documentación**

## Ejemplo con Mocktail

```dart
class MockVehicleRepository extends Mock implements VehicleRepository {}

void main() {
  late MockVehicleRepository repository;
  late VehiclesNotifier notifier;

  setUp(() {
    repository = MockVehicleRepository();
    notifier = VehiclesNotifier(repository);
  });

  test('debe cargar la lista de vehículos', () async {
    when(() => repository.getAll()).thenAnswer((_) async => [mockVehicle]);

    await notifier.loadVehicles();

    expect(notifier.state, [mockVehicle]);
    verify(() => repository.getAll()).called(1);
  });
}
```

## Testing de SQLite

```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('debe insertar un vehículo', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute(CREATE_TABLE_VEHICLES);
    await db.close();
  });
}
```

## Objetivo de Cobertura

- Repositorios: >90% (todas las consultas SQL cubiertas)
- Providers: >80% (transiciones de estado)
- Widgets: >60% (casos felices + estados vacío/error)
- Utils/Formateadores: 100%
