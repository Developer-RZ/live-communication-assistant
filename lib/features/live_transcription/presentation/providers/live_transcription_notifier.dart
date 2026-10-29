import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../conversations/domain/models/conversation.dart';
import '../../conversations/domain/models/transcript_segment.dart';
import '../../conversations/domain/repositories/conversation_repository.dart';
import '../../conversations/data/repositories/sqlite_conversation_repository.dart';
import '../../core/permissions/permission_service.dart';
import '../../speech_recognition/domain/models/recognition_status.dart';
import '../../speech_recognition/domain/models/supported_language.dart';
import '../../speech_recognition/domain/services/speech_recognition_service.dart';
import '../../speech_recognition/presentation/providers/speech_recognition_provider.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import 'live_transcription_state.dart';

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return SqliteConversationRepository();
});

class LiveTranscriptionNotifier extends StateNotifier<LiveTranscriptionState> {
  final SpeechRecognitionService _speechService;
  final PermissionService _permissionService;
  final ConversationRepository _conversationRepo;
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  LiveTranscriptionNotifier({
    required SpeechRecognitionService speechService,
    required PermissionService permissionService,
    required ConversationRepository conversationRepo,
    required Ref ref,
  })  : _speechService = speechService,
        _permissionService = permissionService,
        _conversationRepo = conversationRepo,
        _ref = ref,
        super(const LiveTranscriptionState()) {
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final granted = await _permissionService.hasMicrophonePermission();
    state = state.copyWith(isPermissionGranted: granted);
  }

  Future<bool> requestPermission() async {
    final granted = await _permissionService.requestMicrophonePermission();
    state = state.copyWith(
      isPermissionGranted: granted,
      status: granted ? RecognitionStatus.idle : RecognitionStatus.permissionDenied,
      errorMessage: granted ? null : 'Microphone permission is required to transcribe speech.',
    );
    return granted;
  }

  Future<void> startSession({SupportedLanguage? language}) async {
    final hasPerm = await _permissionService.hasMicrophonePermission();
    if (!hasPerm) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    final selectedLanguage = language ?? _ref.read(settingsNotifierProvider).preferredLanguage;

    // Create or retain active conversation
    Conversation activeConv = state.activeConversation ??
        Conversation(
          id: _uuid.v4(),
          title: 'Conversation ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          startedAt: DateTime.now(),
          language: selectedLanguage.displayName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    state = state.copyWith(
      activeConversation: activeConv,
      status: RecognitionStatus.initializing,
      clearError: true,
    );

    try {
      await _speechService.startListening(
        language: selectedLanguage,
        onResult: (result) {
          if (result.isFinal) {
            _handleFinalResult(result.recognizedWords, result.speakerLabel);
          } else {
            _handlePartialResult(result.recognizedWords);
          }
        },
        onStatusChanged: (status) {
          state = state.copyWith(status: status);
        },
        onError: (errorMsg) {
          state = state.copyWith(
            status: RecognitionStatus.error,
            errorMessage: errorMsg,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: RecognitionStatus.error,
        errorMessage: 'Failed to start microphone listening: $e',
      );
    }
  }

  void _handlePartialResult(String words) {
    final trimmed = words.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(activePartialText: trimmed);
  }

  void _handleFinalResult(String words, String? speakerLabel) {
    final trimmed = words.trim();
    if (trimmed.isEmpty) return;

    // Deduplication check: Avoid adding exact duplicate of the last segment
    if (state.finalizedSegments.isNotEmpty) {
      final lastSegment = state.finalizedSegments.last;
      if (lastSegment.text.trim().toLowerCase() == trimmed.toLowerCase()) {
        state = state.copyWith(clearPartial: true);
        return;
      }
    }

    final newSegment = TranscriptSegment(
      id: _uuid.v4(),
      conversationId: state.activeConversation?.id ?? 'temp_id',
      text: trimmed,
      timestamp: DateTime.now(),
      isFinal: true,
      speakerLabel: speakerLabel,
      recognitionEngine: _speechService.engineName,
      language: state.activeConversation?.language,
    );

    final updatedSegments = List<TranscriptSegment>.from(state.finalizedSegments)..add(newSegment);

    state = state.copyWith(
      finalizedSegments: updatedSegments,
      clearPartial: true,
    );

    // Auto-persist segment if conversation exists
    if (state.activeConversation != null) {
      _conversationRepo.saveSegment(newSegment);
    }
  }

  Future<void> pauseSession() async {
    await _speechService.pauseListening();
    state = state.copyWith(status: RecognitionStatus.paused);
  }

  Future<void> resumeSession() async {
    await _speechService.resumeListening();
    state = state.copyWith(status: RecognitionStatus.listening);
  }

  Future<void> stopSession() async {
    await _speechService.stopListening();
    state = state.copyWith(status: RecognitionStatus.stopped);
  }

  Future<void> saveCurrentConversation() async {
    if (state.activeConversation == null || state.finalizedSegments.isEmpty) return;

    final convToSave = state.activeConversation!.copyWith(
      endedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      segments: state.finalizedSegments,
    );

    await _conversationRepo.saveConversation(convToSave);
  }

  void clearCurrentTranscript() {
    state = state.copyWith(
      finalizedSegments: [],
      clearPartial: true,
      clearError: true,
    );
  }

  void toggleAutoScroll(bool enabled) {
    state = state.copyWith(autoScroll: enabled);
  }
}

final liveTranscriptionNotifierProvider =
    StateNotifierProvider<LiveTranscriptionNotifier, LiveTranscriptionState>((ref) {
  final speech = ref.watch(speechRecognitionServiceProvider);
  final perm = ref.watch(permissionServiceProvider);
  final repo = ref.watch(conversationRepositoryProvider);

  return LiveTranscriptionNotifier(
    speechService: speech,
    permissionService: perm,
    conversationRepo: repo,
    ref: ref,
  );
});
