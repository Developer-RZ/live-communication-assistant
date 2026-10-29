import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/conversation.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/transcript_segment.dart';
import 'package:live_communication_assistant/features/live_transcription/presentation/providers/live_transcription_state.dart';
import 'package:live_communication_assistant/features/speech_recognition/domain/models/recognition_status.dart';

void main() {
  group('LiveTranscriptionState Tests', () {
    test('Initial state has expected defaults', () {
      const state = LiveTranscriptionState();
      expect(state.status, RecognitionStatus.idle);
      expect(state.activeConversation, isNull);
      expect(state.finalizedSegments, isEmpty);
      expect(state.activePartialText, '');
      expect(state.errorMessage, isNull);
      expect(state.autoScroll, isTrue);
      expect(state.isPermissionGranted, isFalse);
      expect(state.isListening, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.hasActiveContent, isFalse);
    });

    test('State transitions correctly when listening with partial text', () {
      const state = LiveTranscriptionState(
        status: RecognitionStatus.listening,
        activePartialText: 'Hello world',
        isPermissionGranted: true,
      );

      expect(state.isListening, isTrue);
      expect(state.hasActiveContent, isTrue);
      expect(state.activePartialText, 'Hello world');
    });

    test('copyWith updates state immutably and supports clearing error/partial', () {
      const state = LiveTranscriptionState(
        status: RecognitionStatus.error,
        activePartialText: 'Partial hypothesis',
        errorMessage: 'Microphone timeout',
      );

      final updated = state.copyWith(
        status: RecognitionStatus.listening,
        clearError: true,
        clearPartial: true,
      );

      expect(updated.status, RecognitionStatus.listening);
      expect(updated.errorMessage, isNull);
      expect(updated.activePartialText, '');
    });

    test('hasActiveContent returns true when finalized segments exist', () {
      final segment = TranscriptSegment(
        id: 'seg-1',
        conversationId: 'conv-1',
        text: 'This is finalized',
        timestamp: DateTime.now(),
        isFinal: true,
        recognitionEngine: 'Mock',
      );

      final state = LiveTranscriptionState(
        finalizedSegments: [segment],
      );

      expect(state.hasActiveContent, isTrue);
    });
  });
}
