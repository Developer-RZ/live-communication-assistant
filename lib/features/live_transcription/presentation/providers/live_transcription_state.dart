import 'package:equatable/equatable.dart';
import '../../conversations/domain/models/conversation.dart';
import '../../conversations/domain/models/transcript_segment.dart';
import '../../speech_recognition/domain/models/recognition_status.dart';

class LiveTranscriptionState extends Equatable {
  final RecognitionStatus status;
  final Conversation? activeConversation;
  final List<TranscriptSegment> finalizedSegments;
  final String activePartialText;
  final String? errorMessage;
  final bool autoScroll;
  final bool isPermissionGranted;

  const LiveTranscriptionState({
    this.status = RecognitionStatus.idle,
    this.activeConversation,
    this.finalizedSegments = const [],
    this.activePartialText = '',
    this.errorMessage,
    this.autoScroll = true,
    this.isPermissionGranted = false,
  });

  bool get isListening => status == RecognitionStatus.listening;
  bool get isPaused => status == RecognitionStatus.paused;
  bool get hasActiveContent => finalizedSegments.isNotEmpty || activePartialText.isNotEmpty;

  LiveTranscriptionState copyWith({
    RecognitionStatus? status,
    Conversation? activeConversation,
    List<TranscriptSegment>? finalizedSegments,
    String? activePartialText,
    String? errorMessage,
    bool? autoScroll,
    bool? isPermissionGranted,
    bool clearError = false,
    bool clearPartial = false,
  }) {
    return LiveTranscriptionState(
      status: status ?? this.status,
      activeConversation: activeConversation ?? this.activeConversation,
      finalizedSegments: finalizedSegments ?? this.finalizedSegments,
      activePartialText: clearPartial ? '' : (activePartialText ?? this.activePartialText),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      autoScroll: autoScroll ?? this.autoScroll,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeConversation,
        finalizedSegments,
        activePartialText,
        errorMessage,
        autoScroll,
        isPermissionGranted,
      ];
}
