import '../../domain/models/recognition_status.dart';
import '../../domain/models/speech_recognition_result.dart';
import '../../domain/models/supported_language.dart';
import '../../domain/services/speech_recognition_service.dart';

enum WhisperModelSize {
  tiny('tiny', 39, 0.4),
  base('base', 74, 0.8),
  small('small', 244, 2.0);

  final String id;
  final int sizeMb;
  final double estimatedLatencySec;
  const WhisperModelSize(this.id, this.sizeMb, this.estimatedLatencySec);
}

class WhisperSpeechService implements SpeechRecognitionService {
  final WhisperModelSize modelSize;
  RecognitionStatus _status = RecognitionStatus.idle;
  SupportedLanguage? _currentLanguage;
  SpeechResultCallback? _onResult;
  StatusChangedCallback? _onStatusChanged;
  ErrorCallback? _onError;

  WhisperSpeechService({this.modelSize = WhisperModelSize.base});

  @override
  String get engineName => 'Local Whisper (${modelSize.id})';

  @override
  bool get isOffline => true;

  @override
  RecognitionStatus get currentStatus => _status;

  @override
  List<SupportedLanguage> get supportedLanguages => [
        SupportedLanguage.english,
        SupportedLanguage.tamil,
      ];

  void _updateStatus(RecognitionStatus newStatus) {
    _status = newStatus;
    _onStatusChanged?.call(newStatus);
  }

  @override
  Future<void> initialize() async {
    _updateStatus(RecognitionStatus.initializing);
    // In production, loads local whisper.cpp binary or ONNX runtime session
    await Future.delayed(const Duration(milliseconds: 100));
    _updateStatus(RecognitionStatus.idle);
  }

  @override
  Future<void> startListening({
    required SupportedLanguage language,
    required SpeechResultCallback onResult,
    required StatusChangedCallback onStatusChanged,
    required ErrorCallback onError,
  }) async {
    _currentLanguage = language;
    _onResult = onResult;
    _onStatusChanged = onStatusChanged;
    _onError = onError;
    _updateStatus(RecognitionStatus.listening);
  }

  @override
  Future<void> pauseListening() async {
    _updateStatus(RecognitionStatus.paused);
  }

  @override
  Future<void> resumeListening() async {
    _updateStatus(RecognitionStatus.listening);
  }

  @override
  Future<void> stopListening() async {
    _updateStatus(RecognitionStatus.stopped);
  }

  @override
  Future<void> dispose() async {
    await stopListening();
  }
}
