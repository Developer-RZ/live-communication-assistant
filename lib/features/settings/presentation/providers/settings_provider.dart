import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> saveSettings(UserSettings settings);
}

class InMemorySettingsRepository implements SettingsRepository {
  UserSettings _settings;

  InMemorySettingsRepository({UserSettings? initialSettings})
      : _settings = initialSettings ?? const UserSettings();

  @override
  Future<UserSettings> getSettings() async => _settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    _settings = settings;
  }
}

class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const UserSettings()) {
    _load();
  }

  Future<void> _load() async {
    final s = await _repository.getSettings();
    state = s;
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    state = newSettings;
    await _repository.saveSettings(newSettings);
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    await _repository.saveSettings(state);
  }

  Future<void> toggleHighContrast(bool value) async {
    state = state.copyWith(isHighContrast: value);
    await _repository.saveSettings(state);
  }

  Future<void> setLanguage(dynamic lang) async {
    state = state.copyWith(preferredLanguage: lang);
    await _repository.saveSettings(state);
  }

  Future<void> toggleAutoScroll(bool value) async {
    state = state.copyWith(autoScrollEnabled: value);
    await _repository.saveSettings(state);
  }

  Future<void> toggleRawAudioStorage(bool value) async {
    state = state.copyWith(storeRawAudio: value);
    await _repository.saveSettings(state);
  }

  Future<void> setRetention(TranscriptRetention retention) async {
    state = state.copyWith(retention: retention);
    await _repository.saveSettings(state);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return InMemorySettingsRepository();
});

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
