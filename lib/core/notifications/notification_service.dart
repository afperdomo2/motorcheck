import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/reminders/models/reminder.dart';
import '../../routes/app_router.dart';
import '../settings/app_preferences.dart';
import '../utils/user_error.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initializing;

  bool get supportsScheduling =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      tz.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (error) {
        logError('zona horaria', error, StackTrace.current);
      }

      const android = AndroidInitializationSettings('ic_notification');
      const linux = LinuxInitializationSettings(
        defaultActionName: 'Abrir MotorCheck',
      );
      const settings = InitializationSettings(android: android, linux: linux);

      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          final route = response.payload;
          if (route != null && route.isNotEmpty) {
            appRouter.go(route);
          }
        },
      );

      try {
        final launchDetails = await _plugin.getNotificationAppLaunchDetails();
        final initialRoute = launchDetails?.didNotificationLaunchApp == true
            ? launchDetails?.notificationResponse?.payload
            : null;
        if (initialRoute != null && initialRoute.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appRouter.go(initialRoute);
          });
        }
      } catch (error) {
        logError('notificación inicial', error, StackTrace.current);
      }

      _initialized = true;
    } catch (error) {
      logError('inicializar notificaciones', error, StackTrace.current);
    }
  }

  Future<bool> requestPermission() async {
    if (!supportsScheduling) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    } catch (error) {
      logError('permiso notificaciones', error, StackTrace.current);
      return false;
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (!supportsScheduling) return true;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (error) {
      logError('estado notificaciones', error, StackTrace.current);
      return false;
    }
  }

  Future<void> sync(
    List<Reminder> reminders,
    NotificationSettings settings,
  ) async {
    await initialize();
    try {
      await _plugin.cancelAll();
      if (!settings.enabled || !supportsScheduling) return;

      var id = 1000;
      for (final reminder in reminders) {
        final dates = _scheduleDates(reminder, settings.leadDays);
        for (final date in dates) {
          if (date.isBefore(DateTime.now())) continue;
          if (id > 1100) return;
          await _plugin.zonedSchedule(
            id: id++,
            title: reminder.title,
            body: '${reminder.vehicleName} · ${reminder.statusLabel}',
            scheduledDate: tz.TZDateTime.from(date, tz.local),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'motorcheck_reminders',
                'Recordatorios MotorCheck',
                channelDescription:
                    'Vencimientos de mantenimiento, documentos y pico y placa',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: reminder.route,
          );
        }
      }
    } catch (error) {
      logError('programar notificaciones', error, StackTrace.current);
    }
  }

  List<DateTime> _scheduleDates(Reminder reminder, int leadDays) {
    final due = reminder.dueDate;
    if (due == null) return const [];

    if (reminder.kind == ReminderKind.restriction) {
      final previousDay = DateTime(
        due.year,
        due.month,
        due.day,
      ).subtract(const Duration(days: 1));
      if (previousDay.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      )) {
        return const [];
      }
      return [
        DateTime(previousDay.year, previousDay.month, previousDay.day, 20),
      ];
    }

    final leads =
        <int>{leadDays, 15, 7, 1, 0}.where((days) => days <= leadDays).toList()
          ..sort((a, b) => b.compareTo(a));

    return leads.map((days) {
      final date = DateTime(
        due.year,
        due.month,
        due.day,
      ).subtract(Duration(days: days));
      return DateTime(date.year, date.month, date.day, 9);
    }).toList();
  }

  Future<void> showTest() async {
    await initialize();
    try {
      await _plugin.show(
        id: 42,
        title: 'MotorCheck',
        body: 'Las notificaciones están funcionando.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'motorcheck_reminders',
            'Recordatorios MotorCheck',
            channelDescription:
                'Vencimientos de mantenimiento, documentos y pico y placa',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (error) {
      logError('notificación de prueba', error, StackTrace.current);
    }
  }
}
