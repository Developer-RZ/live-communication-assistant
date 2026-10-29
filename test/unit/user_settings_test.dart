import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/features/settings/domain/models/user_settings.dart';
import 'package:live_communication_assistant/features/speech_recognition/domain/models/supported_language.dart';

void main() {
  group('UserSettings Serialization & Constraints Tests', () {
    test('Default settings comply with accessibility and privacy invariants', () {
      const settings = UserSettings();
      expect(settings.fontScale, 1.25);
      expect(settings.isHighContrast, isTrue);
      expect(settings.storeRawAudio, isFalse, reason: 'Raw audio storage must strictly default to false');
      expect(settings.preferredLanguage, SupportedLanguage.english);
      expect(settings.autoScrollEnabled, isTrue);
    });

    test('Serialization toMap and fromMap roundtrip preserves all values', () {
      const original = UserSettings(
        preferredLanguage: SupportedLanguage.tamil,
        fontScale: 1.5,
        isHighContrast: false,
        autoLanguageDetection: true,
        retention: TranscriptRetention.thirtyDays,
        storeRawAudio: false,
        autoScrollEnabled: false,
        hapticFeedbackEnabled: true,
      );

      final map = original.toMap();
      final restored = UserSettings.fromMap(map);

      expect(restored.preferredLanguage.code, 'ta_IN');
      expect(restored.fontScale, 1.5);
      expect(restored.isHighContrast, isFalse);
      expect(restored.retention, TranscriptRetention.thirtyDays);
      expect(restored.autoScrollEnabled, isFalse);
    });
  });
}
