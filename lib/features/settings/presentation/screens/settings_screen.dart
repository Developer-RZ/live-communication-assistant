import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../speech_recognition/domain/models/supported_language.dart';
import '../../../speech_recognition/presentation/providers/speech_recognition_provider.dart';
import '../../domain/models/user_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final speechService = ref.watch(speechRecognitionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section: Speech & Language
          _buildSectionHeader('Speech & Language', settings.fontScale),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spoken Language',
                    style: TextStyle(
                      fontSize: 16 * settings.fontScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SupportedLanguage>(
                    value: settings.preferredLanguage,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF162130),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: SupportedLanguage.all.map((lang) {
                      return DropdownMenuItem<SupportedLanguage>(
                        value: lang,
                        child: Text(
                          '${lang.displayName} (${lang.nativeName})',
                          style: TextStyle(fontSize: 14 * settings.fontScale),
                        ),
                      );
                    }).toList(),
                    onChanged: (lang) {
                      if (lang != null) notifier.setLanguage(lang);
                    },
                  ),
                  if (settings.preferredLanguage.note.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        settings.preferredLanguage.note,
                        style: TextStyle(
                          fontSize: 12 * settings.fontScale,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section: Visual Accessibility
          _buildSectionHeader('Visual Accessibility', settings.fontScale),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transcript Font Size (${(settings.fontScale * 100).toInt()}%)',
                    style: TextStyle(
                      fontSize: 16 * settings.fontScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Slider(
                    value: settings.fontScale,
                    min: 1.0,
                    max: 1.8,
                    divisions: 8,
                    label: '${(settings.fontScale * 100).toInt()}%',
                    onChanged: (val) => notifier.setFontScale(val),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Preview: "Accessible text size for effortless reading."',
                      style: TextStyle(
                        fontSize: 18 * settings.fontScale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Divider(height: 28),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'High Contrast Mode (WCAG AAA)',
                      style: TextStyle(
                        fontSize: 15 * settings.fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Increases element borders and pure black backgrounds for enhanced readability.',
                      style: TextStyle(fontSize: 12 * settings.fontScale, color: AppColors.textMutedDark),
                    ),
                    value: settings.isHighContrast,
                    onChanged: (val) => notifier.toggleHighContrast(val),
                  ),
                  const Divider(height: 28),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Auto-Scroll to Newest Speech',
                      style: TextStyle(
                        fontSize: 15 * settings.fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Automatically keeps the newest speech segments in view.',
                      style: TextStyle(fontSize: 12 * settings.fontScale, color: AppColors.textMutedDark),
                    ),
                    value: settings.autoScrollEnabled,
                    onChanged: (val) => notifier.toggleAutoScroll(val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section: Privacy & Storage
          _buildSectionHeader('Privacy & Retention', settings.fontScale),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transcript Retention',
                    style: TextStyle(
                      fontSize: 16 * settings.fontScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TranscriptRetention>(
                    value: settings.retention,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF162130),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: TranscriptRetention.values.map((ret) {
                      return DropdownMenuItem<TranscriptRetention>(
                        value: ret,
                        child: Text(
                          ret.label,
                          style: TextStyle(fontSize: 14 * settings.fontScale),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) notifier.setRetention(val);
                    },
                  ),
                  const Divider(height: 28),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Save Raw Audio Recordings',
                      style: TextStyle(
                        fontSize: 15 * settings.fontScale,
                        fontWeight: FontWeight.w600,
                        color: settings.storeRawAudio ? AppColors.textWarning : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Disabled by default. When off, microphone audio is processed in memory for text recognition and never saved to disk.',
                      style: TextStyle(fontSize: 12 * settings.fontScale, color: AppColors.textMutedDark),
                    ),
                    value: settings.storeRawAudio,
                    onChanged: (val) => notifier.toggleRawAudioStorage(val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section: Engine Info & Privacy Disclosures
          _buildSectionHeader('Engine & System Info', settings.fontScale),
          Card(
            color: const Color(0xFF141F2E),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Active Engine', speechService.engineName, settings.fontScale),
                  const SizedBox(height: 8),
                  _buildInfoRow('Local Mode', speechService.isOffline ? 'Fully Offline' : 'Hybrid (Cloud fallback)', settings.fontScale),
                  const SizedBox(height: 8),
                  _buildInfoRow('Persistence', 'Encrypted Local SQLite Database', settings.fontScale),
                  const SizedBox(height: 8),
                  _buildInfoRow('Cloud Upload', 'None (100% Private Device Storage)', settings.fontScale),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, double fontScale) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13 * fontScale,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double fontScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14 * fontScale, color: AppColors.textMutedDark),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
