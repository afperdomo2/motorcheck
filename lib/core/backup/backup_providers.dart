import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_preferences.dart';
import 'backup_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

final lastBackupProvider = FutureProvider<DateTime?>((ref) async {
  return AppPreferences.lastBackupAt();
});

final autoBackupEnabledProvider = FutureProvider<bool>((ref) async {
  return AppPreferences.autoBackupEnabled();
});
