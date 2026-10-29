import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import 'theme/app_theme.dart';

class LiveAssistantApp extends ConsumerWidget {
  const LiveAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getDarkTheme(
        fontScale: settings.fontScale,
        isHighContrast: settings.isHighContrast,
      ),
      home: const HomeScreen(),
    );
  }
}
