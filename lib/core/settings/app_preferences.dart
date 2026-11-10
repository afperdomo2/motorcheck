import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/user_error.dart';

class NotificationSettings {
  const NotificationSettings({this.enabled = true, this.leadDays = 30});

  final bool enabled;
  final int leadDays;

  NotificationSettings copyWith({bool? enabled, int? leadDays}) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      leadDays: leadDays ?? this.leadDays,
    );
  }
}

class AppPreferences {
  AppPreferences._();

  static const notificationsEnabledKey = 'notifications_enabled';
  static const notificationLeadDaysKey = 'notification_lead_days';
  static const autoBackupEnabledKey = 'auto_backup_enabled';
  static const lastBackupAtKey = 'last_backup_at';

  static Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (error) {
      logError('preferencias', error, StackTrace.current);
      return null;
    }
  }

  static Future<NotificationSettings> loadNotificationSettings() async {
    final prefs = await _prefs();
    if (prefs == null) return const NotificationSettings();
    return NotificationSettings(
      enabled: prefs.getBool(notificationsEnabledKey) ?? true,
      leadDays: prefs.getInt(notificationLeadDaysKey) ?? 30,
    );
  }

  static Future<void> saveNotificationSettings(
    NotificationSettings settings,
  ) async {
    final prefs = await _prefs();
    if (prefs == null) return;
    await prefs.setBool(notificationsEnabledKey, settings.enabled);
    await prefs.setInt(notificationLeadDaysKey, settings.leadDays);
  }

  static Future<bool> autoBackupEnabled() async {
    final prefs = await _prefs();
    return prefs?.getBool(autoBackupEnabledKey) ?? true;
  }

  static Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await _prefs();
    await prefs?.setBool(autoBackupEnabledKey, enabled);
  }

  static Future<DateTime?> lastBackupAt() async {
    final prefs = await _prefs();
    final raw = prefs?.getString(lastBackupAtKey);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  static Future<void> setLastBackupAt(DateTime date) async {
    final prefs = await _prefs();
    await prefs?.setString(lastBackupAtKey, date.toIso8601String());
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );

class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() {
    return AppPreferences.loadNotificationSettings();
  }

  Future<void> save(NotificationSettings settings) async {
    state = AsyncValue.data(settings);
    await AppPreferences.saveNotificationSettings(settings);
  }
}
