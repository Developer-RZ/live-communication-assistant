import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../domain/models/recognition_status.dart';
import '../../domain/models/speech_recognition_result.dart';
import '../../domain/models/supported_language.dart';
import '../../domain/services/speech_recognition_service.dart';

class AndroidSpeechRecognitionService implements SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  RecognitionStatus _status = RecognitionStatus.idle;
  SupportedLanguage? _currentLanguage;
  SpeechResultCallback? _onResult;
  StatusChangedCallback? _onStatusChanged;
  ErrorCallback? _onError;
  bool _isInitialized = false;

  @override
  String get engineName => 'Android Native SpeechRecognizer';

  @override
  bool get isOffline => false;

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
    try {
      final available = await _speech.initialize(
        onError: (errorNotification) {
          _updateStatus(RecognitionStatus.error);
          _onError?.call(errorNotification.errorMsg);
        },
        onStatus: (statusStr) {
          if (statusStr == 'listening') {
            _updateStatus(RecognitionStatus.listening);
          } else if (statusStr == 'notListening' || statusStr == 'done') {
            if (_status == RecognitionStatus.listening) {
              _updateStatus(RecognitionStatus.stopped);
            }
          }
        },
      );

      if (available) {
        _isInitialized = true;
        _updateStatus(RecognitionStatus.idle);
      } else {
        _updateStatus(RecognitionStatus.recognitionUnavailable);
      }
    } catch (e) {
      _updateStatus(RecognitionStatus.error);
      _onError?.call(e.toString());
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

    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      _updateStatus(RecognitionStatus.recognitionUnavailable);
      onError('Speech recognition engine failed to initialize.');
      return;
    }

    try {
      _updateStatus(RecognitionStatus.listening);
      
      // Determine locale ID
      final localeId = language.code.contains(',')
          ? language.code.split(',').first
          : language.code;

      await _speech.listen(
        onResult: (result) {
          final recognitionResult = SpeechRecognitionResult(
            recognizedWords: result.recognizedWords,
            isFinal: result.finalResult,
            confidence: result.hasConfidenceRating ? result.confidence : null,
          );
          _onResult?.call(recognitionResult);
        },
        localeId: localeId,
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      );
    } catch (e) {
      _updateStatus(RecognitionStatus.error);
      _onError?.call('Failed to start listening: $e');
    }
  }

  @override
  Future<void> pauseListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    _updateStatus(RecognitionStatus.paused);
  }

  @override
  Future<void> resumeListening() async {
    if (_currentLanguage != null && _onResult != null && _onStatusChanged != null && _onError != null) {
      await startListening(
        language: _currentLanguage!,
        onResult: _onResult!,
        onStatusChanged: _onStatusChanged!,
        onError: _onError!,
      );
    }
  }

  @override
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    _updateStatus(RecognitionStatus.stopped);
  }

  @override
  Future<void> dispose() async {
    await stopListening();
    _speech.cancel();
  }
}
