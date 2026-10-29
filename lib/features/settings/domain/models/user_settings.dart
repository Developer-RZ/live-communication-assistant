import 'package:equatable/equatable.dart';
import '../../speech_recognition/domain/models/supported_language.dart';

enum TranscriptRetention {
  sevenDays(7, '7 Days'),
  thirtyDays(30, '30 Days'),
  forever(0, 'Forever');

  final int days;
  final String label;
  const TranscriptRetention(this.days, this.label);
}

class UserSettings extends Equatable {
  final SupportedLanguage preferredLanguage;
  final double fontScale;
  final bool isHighContrast;
  final bool autoLanguageDetection;
  final TranscriptRetention retention;
  final bool storeRawAudio; // Strictly disabled by default
  final bool autoScrollEnabled;
  final bool hapticFeedbackEnabled;

  const UserSettings({
    this.preferredLanguage = SupportedLanguage.english,
    this.fontScale = 1.25,
    this.isHighContrast = true,
    this.autoLanguageDetection = false,
    this.retention = TranscriptRetention.forever,
    this.storeRawAudio = false,
    this.autoScrollEnabled = true,
    this.hapticFeedbackEnabled = true,
  });

  UserSettings copyWith({
    SupportedLanguage? preferredLanguage,
    double? fontScale,
    bool? isHighContrast,
    bool? autoLanguageDetection,
    TranscriptRetention? retention,
    bool? storeRawAudio,
    bool? autoScrollEnabled,
    bool? hapticFeedbackEnabled,
  }) {
    return UserSettings(
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      fontScale: fontScale ?? this.fontScale,
      isHighContrast: isHighContrast ?? this.isHighContrast,
      autoLanguageDetection: autoLanguageDetection ?? this.autoLanguageDetection,
      retention: retention ?? this.retention,
      storeRawAudio: storeRawAudio ?? this.storeRawAudio,
      autoScrollEnabled: autoScrollEnabled ?? this.autoScrollEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preferred_language': preferredLanguage.code,
      'font_scale': fontScale,
      'is_high_contrast': isHighContrast ? 1 : 0,
      'auto_language_detection': autoLanguageDetection ? 1 : 0,
      'retention_days': retention.days,
      'store_raw_audio': storeRawAudio ? 1 : 0,
      'auto_scroll_enabled': autoScrollEnabled ? 1 : 0,
      'haptic_feedback_enabled': hapticFeedbackEnabled ? 1 : 0,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      preferredLanguage: SupportedLanguage.fromCode(map['preferred_language'] as String? ?? 'en_US'),
      fontScale: (map['font_scale'] as num?)?.toDouble() ?? 1.25,
      isHighContrast: (map['is_high_contrast'] as int? ?? 1) == 1,
      autoLanguageDetection: (map['auto_language_detection'] as int? ?? 0) == 1,
      retention: TranscriptRetention.values.firstWhere(
        (r) => r.days == (map['retention_days'] as int? ?? 0),
        orElse: () => TranscriptRetention.forever,
      ),
      storeRawAudio: (map['store_raw_audio'] as int? ?? 0) == 1,
      autoScrollEnabled: (map['auto_scroll_enabled'] as int? ?? 1) == 1,
      hapticFeedbackEnabled: (map['haptic_feedback_enabled'] as int? ?? 1) == 1,
    );
  }

  @override
  List<Object?> get props => [
        preferredLanguage,
        fontScale,
        isHighContrast,
        autoLanguageDetection,
        retention,
        storeRawAudio,
        autoScrollEnabled,
        hapticFeedbackEnabled,
      ];
}
