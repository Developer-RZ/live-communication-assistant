class AppFailure implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppFailure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';
}

class PermissionFailure extends AppFailure {
  const PermissionFailure({required super.message, super.code});
}

class SpeechRecognitionFailure extends AppFailure {
  const SpeechRecognitionFailure({required super.message, super.code});
}

class StorageFailure extends AppFailure {
  const StorageFailure({required super.message, super.code});
}
