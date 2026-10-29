import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../conversations/presentation/screens/conversation_history_screen.dart';
import '../../../live_transcription/presentation/providers/live_transcription_notifier.dart';
import '../../../live_transcription/presentation/screens/live_conversation_screen.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../speech_recognition/presentation/providers/speech_recognition_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final liveState = ref.watch(liveTranscriptionNotifierProvider);
    final speechService = ref.watch(speechRecognitionServiceProvider);
    final fontScale = settings.fontScale;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName, style: TextStyle(fontSize: 20 * fontScale)),
        actions: [
          IconButton(
            tooltip: 'Settings & Accessibility',
            iconSize: 26 * fontScale,
            padding: const EdgeInsets.all(12),
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header tag
              Text(
                'Live Communication Assistant',
                style: TextStyle(
                  fontSize: 26 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Real-time speech transcription for face-to-face and phone conversations.',
                style: TextStyle(
                  fontSize: 15 * fontScale,
                  color: AppColors.textMutedDark,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 20),

              // Status Summary Card
              Card(
                color: const Color(0xFF142032),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Active Language
                      Row(
                        children: [
                          Icon(Icons.language, size: 22 * fontScale, color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Language: ${settings.preferredLanguage.displayName}',
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Colors.white12),
                      // Mic Permission Status
                      Row(
                        children: [
                          Icon(
                            liveState.isPermissionGranted ? Icons.check_circle : Icons.warning_amber_rounded,
                            size: 22 * fontScale,
                            color: liveState.isPermissionGranted ? AppColors.statusListening : AppColors.statusError,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              liveState.isPermissionGranted
                                  ? 'Microphone Permission: Granted'
                                  : 'Microphone Permission: Required',
                              style: TextStyle(
                                fontSize: 14 * fontScale,
                                fontWeight: FontWeight.bold,
                                color: liveState.isPermissionGranted ? AppColors.statusListening : AppColors.statusError,
                              ),
                            ),
                          ),
                          if (!liveState.isPermissionGranted)
                            TextButton(
                              onPressed: () => ref
                                  .read(liveTranscriptionNotifierProvider.notifier)
                                  .requestPermission(),
                              child: const Text('Grant'),
                            ),
                        ],
                      ),
                      const Divider(height: 20, color: Colors.white12),
                      // Speech Engine Info
                      Row(
                        children: [
                          Icon(Icons.memory, size: 22 * fontScale, color: Colors.amberAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Engine: ${speechService.engineName}',
                              style: TextStyle(
                                fontSize: 13 * fontScale,
                                color: AppColors.textMutedDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Primary Action: Start Conversation
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusListening,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 68 * fontScale),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LiveConversationScreen()),
                  );
                },
                icon: Icon(Icons.mic, size: 32 * fontScale),
                label: Text(
                  'Start Conversation',
                  style: TextStyle(
                    fontSize: 20 * fontScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Secondary Action: Conversation History
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56 * fontScale),
                  side: const BorderSide(color: Colors.white54, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ConversationHistoryScreen()),
                  );
                },
                icon: Icon(Icons.history, size: 24 * fontScale),
                label: Text(
                  'Conversation History',
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tertiary Action: Settings
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMutedDark,
                  minimumSize: Size(double.infinity, 48 * fontScale),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: Icon(Icons.tune, size: 20 * fontScale),
                label: Text(
                  'Customize Accessibility & Settings',
                  style: TextStyle(fontSize: 14 * fontScale),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
