import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/core/permissions/permission_service.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/conversation.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/transcript_segment.dart';
import 'package:live_communication_assistant/features/conversations/domain/repositories/conversation_repository.dart';
import 'package:live_communication_assistant/features/live_transcription/presentation/providers/live_transcription_notifier.dart';
import 'package:live_communication_assistant/features/speech_recognition/data/services/mock_speech_recognition_service.dart';
import 'package:live_communication_assistant/features/speech_recognition/domain/models/recognition_status.dart';
import 'package:live_communication_assistant/features/speech_recognition/presentation/providers/speech_recognition_provider.dart';

class MockConversationRepository implements ConversationRepository {
  final List<Conversation> conversations = [];
  final List<TranscriptSegment> segments = [];

  @override
  Future<List<Conversation>> getConversations() async => conversations;

  @override
  Future<Conversation?> getConversationById(String id) async {
    return conversations.firstWhere((c) => c.id == id);
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    conversations.removeWhere((c) => c.id == conversation.id);
    conversations.add(conversation);
  }

  @override
  Future<void> updateConversationTitle(String id, String newTitle) async {
    final idx = conversations.indexWhere((c) => c.id == id);
    if (idx != -1) {
      conversations[idx] = conversations[idx].copyWith(title: newTitle);
    }
  }

  @override
  Future<void> deleteConversation(String id) async {
    conversations.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> saveSegment(TranscriptSegment segment) async {
    segments.add(segment);
  }

  @override
  Future<List<Conversation>> searchConversations(String query) async {
    return conversations.where((c) => c.title.contains(query)).toList();
  }
}

void main() {
  late MockSpeechRecognitionService mockSpeechService;
  late MockPermissionService mockPermissionService;
  late MockConversationRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockSpeechService = MockSpeechRecognitionService();
    mockPermissionService = MockPermissionService(isGranted: true);
    mockRepo = MockConversationRepository();

    container = ProviderContainer(
      overrides: [
        speechRecognitionServiceProvider.overrideWithValue(mockSpeechService),
        permissionServiceProvider.overrideWithValue(mockPermissionService),
        conversationRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Transcript Deduplication & Incremental Stream Tests', () {
    test('Partial speech updates activePartialText without adding finalized segments', () async {
      final notifier = container.read(liveTranscriptionNotifierProvider.notifier);
      await notifier.startSession();

      // Simulate partial words
      mockSpeechService.simulatePartialSpeech('I need');
      var state = container.read(liveTranscriptionNotifierProvider);
      expect(state.activePartialText, 'I need');
      expect(state.finalizedSegments, isEmpty);

      // Subsequent partial update overrides in-flight buffer
      mockSpeechService.simulatePartialSpeech('I need help with my business');
      state = container.read(liveTranscriptionNotifierProvider);
      expect(state.activePartialText, 'I need help with my business');
      expect(state.finalizedSegments, isEmpty);
    });

    test('Finalized speech adds single segment and clears partial buffer', () async {
      final notifier = container.read(liveTranscriptionNotifierProvider.notifier);
      await notifier.startSession();

      mockSpeechService.simulatePartialSpeech('I need help');
      mockSpeechService.simulateFinalSpeech('I need help with my business.');

      final state = container.read(liveTranscriptionNotifierProvider);
      expect(state.activePartialText, '');
      expect(state.finalizedSegments.length, 1);
      expect(state.finalizedSegments.first.text, 'I need help with my business.');
      expect(state.finalizedSegments.first.isFinal, isTrue);
    });

    test('Exact duplicate consecutive final phrases are discarded', () async {
      final notifier = container.read(liveTranscriptionNotifierProvider.notifier);
      await notifier.startSession();

      mockSpeechService.simulateFinalSpeech('Sure, what kind of help?');
      mockSpeechService.simulateFinalSpeech('Sure, what kind of help?');

      final state = container.read(liveTranscriptionNotifierProvider);
      expect(state.finalizedSegments.length, 1, reason: 'Duplicate phrase must not be appended');
      expect(state.finalizedSegments.first.text, 'Sure, what kind of help?');
    });

    test('Paused state pauses recognition and resume re-enables it', () async {
      final notifier = container.read(liveTranscriptionNotifierProvider.notifier);
      await notifier.startSession();
      expect(container.read(liveTranscriptionNotifierProvider).status, RecognitionStatus.listening);

      await notifier.pauseSession();
      expect(container.read(liveTranscriptionNotifierProvider).status, RecognitionStatus.paused);

      await notifier.resumeSession();
      expect(container.read(liveTranscriptionNotifierProvider).status, RecognitionStatus.listening);

      await notifier.stopSession();
      expect(container.read(liveTranscriptionNotifierProvider).status, RecognitionStatus.stopped);
    });

    test('Clearing transcript resets active items', () async {
      final notifier = container.read(liveTranscriptionNotifierProvider.notifier);
      await notifier.startSession();

      mockSpeechService.simulateFinalSpeech('First sentence');
      expect(container.read(liveTranscriptionNotifierProvider).finalizedSegments.length, 1);

      notifier.clearCurrentTranscript();
      final state = container.read(liveTranscriptionNotifierProvider);
      expect(state.finalizedSegments, isEmpty);
      expect(state.activePartialText, '');
    });
  });
}
