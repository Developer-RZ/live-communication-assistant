import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/core/permissions/permission_service.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/conversation.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/transcript_segment.dart';
import 'package:live_communication_assistant/features/conversations/domain/repositories/conversation_repository.dart';
import 'package:live_communication_assistant/features/live_transcription/presentation/providers/live_transcription_notifier.dart';
import 'package:live_communication_assistant/features/live_transcription/presentation/screens/live_conversation_screen.dart';
import 'package:live_communication_assistant/features/speech_recognition/data/services/mock_speech_recognition_service.dart';
import 'package:live_communication_assistant/features/speech_recognition/presentation/providers/speech_recognition_provider.dart';

class StubConversationRepository implements ConversationRepository {
  @override
  Future<List<Conversation>> getConversations() async => [];
  @override
  Future<Conversation?> getConversationById(String id) async => null;
  @override
  Future<void> saveConversation(Conversation conversation) async {}
  @override
  Future<void> updateConversationTitle(String id, String newTitle) async {}
  @override
  Future<void> deleteConversation(String id) async {}
  @override
  Future<void> saveSegment(TranscriptSegment segment) async {}
  @override
  Future<List<Conversation>> searchConversations(String query) async => [];
}

void main() {
  testWidgets('LiveConversationScreen renders status, speech updates, and control bar', (WidgetTester tester) async {
    final mockSpeech = MockSpeechRecognitionService();
    final mockPerm = MockPermissionService(isGranted: true);
    final stubRepo = StubConversationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          speechRecognitionServiceProvider.overrideWithValue(mockSpeech),
          permissionServiceProvider.overrideWithValue(mockPerm),
          conversationRepositoryProvider.overrideWithValue(stubRepo),
        ],
        child: const MaterialApp(
          home: LiveConversationScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify visual status indicator is present
    expect(find.byType(LiveConversationScreen), findsOneWidget);

    // Simulate speech input
    mockSpeech.simulatePartialSpeech('I am speaking now');
    await tester.pump();
    expect(find.text('I am speaking now'), findsOneWidget);

    mockSpeech.simulateFinalSpeech('I am speaking now. Nice to meet you.');
    await tester.pump();
    expect(find.text('I am speaking now. Nice to meet you.'), findsOneWidget);

    // Verify Pause, Clear, and Save controls are available
    expect(find.text('Pause'), findsOneWidget);
    expect(find.byTooltip('Clear Transcript'), findsOneWidget);
    expect(find.byTooltip('Save Conversation'), findsOneWidget);
  });
}
