import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

class MotorCheckApp extends ConsumerWidget {
  const MotorCheckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'MotorCheck',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModeAsync.value ?? ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
