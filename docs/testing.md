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
flutter test --name "formatea"                  # Por nombre (regex, busca en todos los archivos)
flutter test test/features/vehicles/vehicle_test.dart  # Archivo específico
flutter test --concurrency 1                    # Evitar race conditions en SQLite
flutter test --coverage                         # Con cobertura
```

## Convenciones

1. Los archivos de prueba reflejan la estructura de `lib/` dentro de `test/`
2. Nombrado: `*_test.dart` coincidiendo con el archivo fuente
3. Agrupar pruebas por método o comportamiento usando `group()`
4. Descripciones y nombres de test en **español**
5. **Imports del proyecto en tests**: siempre `package:motorcheck/...` (nunca relativos)
6. Usar `setUp`/`setUpAll` para arreglos comunes
7. Preferir `mocktail` sobre `mockito` (sin generación de código)
8. `sqflite_common_ffi` para pruebas de BD en memoria
9. Widget tests: envolver en `MaterialApp` + `Scaffold`, usar `tester.pumpWidget()`
10. **NO ejecutar `flutter test` tras cambios en archivos `.md` o documentación**

## Ejemplo con Mocktail

```dart
import 'package:mocktail/mocktail.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

void main() {
  late MockVehicleRepository repository;

  setUp(() {
    repository = MockVehicleRepository();
  });

  test('debe obtener todos los vehículos', () async {
    when(() => repository.getAll()).thenAnswer((_) async => [mockVehicle]);

    final vehicles = await repository.getAll();

    expect(vehicles.length, 1);
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

  test('debe crear la tabla vehicles', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('CREATE TABLE vehicles (...);');

    final result = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type="table" AND name="vehicles"',
    );
    expect(result.length, 1);

    await db.close();
  });
}
```

## Objetivo de Cobertura

- Repositorios: >90% (todas las consultas SQL cubiertas)
- Providers: >80% (transiciones de estado)
- Widgets: >60% (casos felices + estados vacío/error)
- Utils/Formateadores: 100%

---

> **Nota para agentes**: este documento es referenciado por `AGENTS.md`.
> Si modificas este archivo, verifica que AGENTS.md siga siendo consistente.
