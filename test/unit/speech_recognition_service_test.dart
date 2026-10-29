import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/features/speech_recognition/data/services/mock_speech_recognition_service.dart';
import 'package:live_communication_assistant/features/speech_recognition/domain/models/recognition_status.dart';
import 'package:live_communication_assistant/features/speech_recognition/domain/models/speech_recognition_result.dart';
import 'package:live_communication_assistant/features/speech_recognition/domain/models/supported_language.dart';

void main() {
  group('SpeechRecognitionService Contract Tests', () {
    late MockSpeechRecognitionService service;

    setUp(() {
      service = MockSpeechRecognitionService();
    });

    test('Initialization succeeds under normal conditions', () async {
      expect(service.currentStatus, RecognitionStatus.idle);
      await service.initialize();
      expect(service.currentStatus, RecognitionStatus.idle);
    });

    test('Initialization marks recognitionUnavailable when hardware fails', () async {
      service.shouldFailInitialization = true;
      await service.initialize();
      expect(service.currentStatus, RecognitionStatus.recognitionUnavailable);
    });

    test('Emits partial and final speech results correctly', () async {
      final List<SpeechRecognitionResult> receivedResults = [];
      RecognitionStatus? lastStatus;

      await service.startListening(
        language: SupportedLanguage.tamil,
        onResult: (res) => receivedResults.add(res),
        onStatusChanged: (st) => lastStatus = st,
        onError: (_) {},
      );

      expect(lastStatus, RecognitionStatus.listening);

      service.simulatePartialSpeech('வணக்கம்');
      expect(receivedResults.length, 1);
      expect(receivedResults.first.recognizedWords, 'வணக்கம்');
      expect(receivedResults.first.isFinal, isFalse);

      service.simulateFinalSpeech('வணக்கம், எப்படி இருக்கிறீர்கள்?');
      expect(receivedResults.length, 2);
      expect(receivedResults.last.recognizedWords, 'வணக்கம், எப்படி இருக்கிறீர்கள்?');
      expect(receivedResults.last.isFinal, isTrue);
    });

    test('Propagates network errors cleanly', () async {
      service.shouldSimulateNetworkError = true;
      String? errorMessage;
      RecognitionStatus? status;

      await service.startListening(
        language: SupportedLanguage.english,
        onResult: (_) {},
        onStatusChanged: (st) => status = st,
        onError: (err) => errorMessage = err,
      );

      expect(status, RecognitionStatus.networkUnavailable);
      expect(errorMessage, contains('Network connection unavailable'));
    });
  });
}
