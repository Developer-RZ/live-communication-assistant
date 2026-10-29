import 'package:equatable/equatable.dart';

class SpeechRecognitionResult extends Equatable {
  final String recognizedWords;
  final bool isFinal;
  final double? confidence;
  final String? speakerLabel;

  const SpeechRecognitionResult({
    required this.recognizedWords,
    required this.isFinal,
    this.confidence,
    this.speakerLabel,
  });

  @override
  List<Object?> get props => [recognizedWords, isFinal, confidence, speakerLabel];
}
