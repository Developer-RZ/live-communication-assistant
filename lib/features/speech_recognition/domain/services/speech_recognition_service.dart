import 'recognition_status.dart';
import 'speech_recognition_result.dart';
import 'supported_language.dart';

typedef SpeechResultCallback = void Function(SpeechRecognitionResult result);
typedef StatusChangedCallback = void Function(RecognitionStatus status);
typedef ErrorCallback = void Function(String errorMessage);

abstract class SpeechRecognitionService {
  Future<void> initialize();

  Future<void> startListening({
    required SupportedLanguage language,
    required SpeechResultCallback onResult,
    required StatusChangedCallback onStatusChanged,
    required ErrorCallback onError,
  });

  Future<void> pauseListening();
  Future<void> resumeListening();
  Future<void> stopListening();
  Future<void> dispose();

  RecognitionStatus get currentStatus;
  List<SupportedLanguage> get supportedLanguages;
  String get engineName;
  bool get isOffline;
}
