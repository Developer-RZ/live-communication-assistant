class AppConstants {
  static const String appName = 'Live Communication Assistant';
  static const String appTagline = 'Accessible Live Speech-to-Text';
  
  // Storage keys & DB
  static const String databaseName = 'live_assistant.db';
  static const int databaseVersion = 1;
  static const String settingsBoxKey = 'user_settings';

  // Accessibility limits
  static const double minFontScale = 1.0;
  static const double maxFontScale = 1.8;
  static const double defaultFontScale = 1.25;

  // Language tags
  static const String langTamil = 'ta_IN';
  static const String langEnglish = 'en_US';
  static const String langMixed = 'ta_IN,en_US';
}
