import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/core/permissions/permission_service.dart';
import 'package:live_communication_assistant/features/home/presentation/screens/home_screen.dart';
import 'package:live_communication_assistant/features/speech_recognition/data/services/mock_speech_recognition_service.dart';
import 'package:live_communication_assistant/features/speech_recognition/presentation/providers/speech_recognition_provider.dart';

void main() {
  testWidgets('HomeScreen renders accessible buttons and permission info', (WidgetTester tester) async {
    final mockSpeech = MockSpeechRecognitionService();
    final mockPerm = MockPermissionService(isGranted: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechRecognitionServiceProvider.overrideWithValue(mockSpeech),
          permissionServiceProvider.overrideWithValue(mockPerm),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and Subtitle
    expect(find.text('Live Communication Assistant'), findsOneWidget);
    expect(find.textContaining('Real-time speech transcription'), findsOneWidget);

    // Verify Primary Action Button
    expect(find.text('Start Conversation'), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Verify Secondary Action Button
    expect(find.text('Conversation History'), findsOneWidget);

    // Verify Status Card
    expect(find.textContaining('Language:'), findsOneWidget);
    expect(find.textContaining('Microphone Permission: Granted'), findsOneWidget);
  });
}
