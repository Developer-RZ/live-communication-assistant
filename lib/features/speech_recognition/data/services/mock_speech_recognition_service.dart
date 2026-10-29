import 'dart:async';
import '../../domain/models/recognition_status.dart';
import '../../domain/models/speech_recognition_result.dart';
import '../../domain/models/supported_language.dart';
import '../../domain/services/speech_recognition_service.dart';

class MockSpeechRecognitionService implements SpeechRecognitionService {
  RecognitionStatus _status = RecognitionStatus.idle;
  SpeechResultCallback? _onResult;
  StatusChangedCallback? _onStatusChanged;
  ErrorCallback? _onError;
  SupportedLanguage? _currentLanguage;
  Timer? _simulationTimer;

  bool shouldFailInitialization = false;
  bool shouldSimulateNetworkError = false;

  @override
  String get engineName => 'Mock Test SpeechRecognizer';

  @override
  bool get isOffline => true;

  @override
  RecognitionStatus get currentStatus => _status;

  @override
  List<SupportedLanguage> get supportedLanguages => SupportedLanguage.all;

  void _updateStatus(RecognitionStatus newStatus) {
    _status = newStatus;
    _onStatusChanged?.call(newStatus);
  }

  @override
  Future<void> initialize() async {
    _updateStatus(RecognitionStatus.initializing);
    await Future.delayed(const Duration(milliseconds: 50));
    if (shouldFailInitialization) {
      _updateStatus(RecognitionStatus.recognitionUnavailable);
    } else {
      _updateStatus(RecognitionStatus.idle);
    }
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

    if (shouldSimulateNetworkError) {
      _updateStatus(RecognitionStatus.networkUnavailable);
      onError('Network connection unavailable for speech recognition.');
      return;
    }

    _updateStatus(RecognitionStatus.listening);
  }

  void simulatePartialSpeech(String words) {
    if (_status != RecognitionStatus.listening) return;
    _onResult?.call(SpeechRecognitionResult(
      recognizedWords: words,
      isFinal: false,
      confidence: 0.88,
    ));
  }

  void simulateFinalSpeech(String words) {
    if (_status != RecognitionStatus.listening) return;
    _onResult?.call(SpeechRecognitionResult(
      recognizedWords: words,
      isFinal: true,
      confidence: 0.95,
    ));
  }

  void simulateError(String errorMessage) {
    _updateStatus(RecognitionStatus.error);
    _onError?.call(errorMessage);
  }

  @override
  Future<void> pauseListening() async {
    _simulationTimer?.cancel();
    _updateStatus(RecognitionStatus.paused);
  }

  @override
  Future<void> resumeListening() async {
    _updateStatus(RecognitionStatus.listening);
  }

  @override
  Future<void> stopListening() async {
    _simulationTimer?.cancel();
    _updateStatus(RecognitionStatus.stopped);
  }

  @override
  Future<void> dispose() async {
    await stopListening();
  }
}
