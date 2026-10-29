import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/features/settings/presentation/screens/settings_screen.dart';
import 'package:live_communication_assistant/features/speech_recognition/data/services/mock_speech_recognition_service.dart';
import 'package:live_communication_assistant/features/speech_recognition/presentation/providers/speech_recognition_provider.dart';

void main() {
  testWidgets('SettingsScreen allows configuring font size, language, and high contrast', (WidgetTester tester) async {
    final mockSpeech = MockSpeechRecognitionService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechRecognitionServiceProvider.overrideWithValue(mockSpeech),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify headings
    expect(find.text('Accessibility & Settings'), findsOneWidget);
    expect(find.text('SPeech & Language'.toUpperCase()), findsOneWidget);
    expect(find.text('Visual Accessibility'.toUpperCase()), findsOneWidget);
    expect(find.text('Privacy & Retention'.toUpperCase()), findsOneWidget);

    // Verify font size slider and preview
    expect(find.textContaining('Transcript Font Size'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    // Verify switches
    expect(find.text('High Contrast Mode (WCAG AAA)'), findsOneWidget);
    expect(find.text('Save Raw Audio Recordings'), findsOneWidget);
  });
}
