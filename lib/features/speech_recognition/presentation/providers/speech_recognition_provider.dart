import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/permissions/permission_service.dart';
import '../../domain/services/speech_recognition_service.dart';
import '../../data/services/android_speech_recognition_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return AppPermissionService();
});

final speechRecognitionServiceProvider = Provider<SpeechRecognitionService>((ref) {
  return AndroidSpeechRecognitionService();
});
