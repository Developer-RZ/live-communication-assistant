enum RecognitionStatus {
  idle,
  initializing,
  listening,
  processing,
  paused,
  stopped,
  permissionDenied,
  networkUnavailable,
  recognitionUnavailable,
  error;

  String get label {
    switch (this) {
      case RecognitionStatus.idle:
        return 'Ready to Listen';
      case RecognitionStatus.initializing:
        return 'Initializing Audio Engine...';
      case RecognitionStatus.listening:
        return 'Listening & Transcribing...';
      case RecognitionStatus.processing:
        return 'Processing Speech...';
      case RecognitionStatus.paused:
        return 'Listening Paused';
      case RecognitionStatus.stopped:
        return 'Transcription Stopped';
      case RecognitionStatus.permissionDenied:
        return 'Microphone Permission Denied';
      case RecognitionStatus.networkUnavailable:
        return 'Speech Network Unavailable';
      case RecognitionStatus.recognitionUnavailable:
        return 'Speech Recognition Unavailable';
      case RecognitionStatus.error:
        return 'Recognition Error';
    }
  }

  bool get isActiveListening => this == RecognitionStatus.listening;
  bool get isPaused => this == RecognitionStatus.paused;
  bool get hasError =>
      this == RecognitionStatus.error ||
      this == RecognitionStatus.permissionDenied ||
      this == RecognitionStatus.networkUnavailable ||
      this == RecognitionStatus.recognitionUnavailable;
}
