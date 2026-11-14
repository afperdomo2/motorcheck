import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/settings/app_preferences.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
import 'package:motorcheck/features/components/models/component_status.dart';
import 'package:motorcheck/features/components/models/vehicle_component.dart';
import 'package:motorcheck/features/components/providers.dart';
import 'package:motorcheck/features/documents/providers.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/reminders/models/reminder.dart';
import 'package:motorcheck/features/reminders/providers.dart';
import 'package:motorcheck/features/restrictions/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationSettings extends NotificationSettingsNotifier {
  @override
  Future<NotificationSettings> build() async {
    return const NotificationSettings(leadDays: 30);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('usa solo el documento vigente por tipo', () async {
    final vehicle = Vehicle(
      id: 1,
      name: 'Toyota',
      type: 'car',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final now = DateTime.now();
    final latestSoat = VehicleDocument(
      id: 2,
      vehicleId: 1,
      type: 'soat',
      name: 'SOAT vigente',
      expiresAt: now.add(const Duration(days: 10)),
      createdAt: now,
      updatedAt: now,
    );
    final oldSoat = VehicleDocument(
      id: 1,
      vehicleId: 1,
      type: 'soat',
      name: 'SOAT viejo',
      expiresAt: now.subtract(const Duration(days: 100)),
      createdAt: now,
      updatedAt: now,
    );
    final rtm = VehicleDocument(
      id: 3,
      vehicleId: 1,
      type: 'rtm',
      name: 'RTM',
      expiresAt: now.add(const Duration(days: 20)),
      createdAt: now,
      updatedAt: now,
    );

    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith((ref) async => [vehicle]),
        notificationSettingsProvider.overrideWith(
          _FakeNotificationSettings.new,
        ),
        upcomingMaintenanceProvider(1).overrideWith((ref) async => []),
        vehicleDocumentsProvider(
          1,
        ).overrideWith((ref) async => [latestSoat, oldSoat, rtm]),
        globalDocumentsProvider.overrideWith((ref) async => []),
        restrictionStatusesProvider.overrideWith(
          (ref) async => <VehicleRestrictionEntry>[],
        ),
        vehicleComponentStatusesProvider(1).overrideWith((ref) async => []),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationSettingsProvider.future);

    final reminders = await container.read(remindersProvider.future);
    final documents = reminders
        .where((reminder) => reminder.kind == ReminderKind.document)
        .toList();

    expect(documents, hasLength(2));
    expect(documents.map((r) => r.title), contains('SOAT vigente'));
    expect(documents.map((r) => r.title), isNot(contains('SOAT viejo')));
  });

  test('incluye componentes vencidos y próximos, no los inactivos', () async {
    final vehicle = Vehicle(
      id: 1,
      name: 'Toyota',
      type: 'car',
      currentMileage: 152300,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final now = DateTime.now();

    ComponentStatus status({
      required int id,
      required String name,
      required int installedKm,
      required int intervalKm,
      int? warningKm,
      bool active = true,
    }) {
      return componentStatusFor(
        VehicleComponent(
          id: id,
          vehicleId: 1,
          name: name,
          type: 'tire',
          installedAt: now.subtract(const Duration(days: 200)),
          installedKm: installedKm,
          intervalKm: intervalKm,
          warningKm: warningKm,
          active: active,
          createdAt: now,
          updatedAt: now,
        ),
        currentMileage: vehicle.currentMileage,
      );
    }

    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith((ref) async => [vehicle]),
        notificationSettingsProvider.overrideWith(
          _FakeNotificationSettings.new,
        ),
        upcomingMaintenanceProvider(1).overrideWith((ref) async => []),
        vehicleDocumentsProvider(1).overrideWith((ref) async => []),
        globalDocumentsProvider.overrideWith((ref) async => []),
        restrictionStatusesProvider.overrideWith(
          (ref) async => <VehicleRestrictionEntry>[],
        ),
        vehicleComponentStatusesProvider(1).overrideWith(
          (ref) async => [
            status(
              id: 1,
              name: 'Llanta vencida',
              installedKm: 100000,
              intervalKm: 10000,
            ),
            status(
              id: 2,
              name: 'Llanta próxima',
              installedKm: 151000,
              intervalKm: 2000,
              warningKm: 1000,
            ),
            status(
              id: 3,
              name: 'Llanta al día',
              installedKm: 152000,
              intervalKm: 50000,
            ),
            status(
              id: 4,
              name: 'Llanta inactiva',
              installedKm: 100000,
              intervalKm: 1000,
              active: false,
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationSettingsProvider.future);
    final reminders = await container.read(remindersProvider.future);
    final components = reminders
        .where((reminder) => reminder.kind == ReminderKind.component)
        .toList();

    expect(components, hasLength(2));
    expect(
      components.map((r) => r.title),
      containsAll(['Llanta vencida', 'Llanta próxima']),
    );
    expect(
      components.firstWhere((r) => r.title == 'Llanta vencida').severity,
      ReminderSeverity.overdue,
    );
    expect(
      components.firstWhere((r) => r.title == 'Llanta próxima').severity,
      ReminderSeverity.warning,
    );
    expect(components.first.route, '/vehicles/1/components/1');
  });
}
