import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/core/settings/app_preferences.dart';
import 'package:motorcheck/features/documents/models/vehicle_document.dart';
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
}
