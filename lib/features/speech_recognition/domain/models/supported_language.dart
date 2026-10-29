import 'package:equatable/equatable.dart';

class SupportedLanguage extends Equatable {
  final String code;
  final String displayName;
  final String nativeName;
  final bool isOfflineSupported;
  final String note;

  const SupportedLanguage({
    required this.code,
    required this.displayName,
    required this.nativeName,
    this.isOfflineSupported = false,
    this.note = '',
  });

  static const SupportedLanguage tamil = SupportedLanguage(
    code: 'ta_IN',
    displayName: 'Tamil (India)',
    nativeName: 'தமிழ்',
    isOfflineSupported: false,
    note: 'Recognizes spoken Tamil. Requires internet connection unless offline model is installed on device.',
  );

  static const SupportedLanguage english = SupportedLanguage(
    code: 'en_US',
    displayName: 'English (US / India)',
    nativeName: 'English',
    isOfflineSupported: true,
    note: 'Broad vocabulary support with high streaming accuracy.',
  );

  static const SupportedLanguage tamilEnglishMixed = SupportedLanguage(
    code: 'ta_IN,en_US',
    displayName: 'Tamil-English Mixed (Tanglish)',
    nativeName: 'தமிழ் & English',
    isOfflineSupported: false,
    note: 'Recognizes bilingual conversation. Note: Speech engines may alternate between Tamil script and Latin letters depending on speaker cadence.',
  );

  static const List<SupportedLanguage> all = [
    tamil,
    english,
    tamilEnglishMixed,
  ];

  static SupportedLanguage fromCode(String code) {
    return all.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english,
    );
  }

  @override
  List<Object?> get props => [code, displayName, nativeName, isOfflineSupported];
}
