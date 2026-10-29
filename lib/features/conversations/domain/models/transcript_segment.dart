import 'package:equatable/equatable.dart';

class TranscriptSegment extends Equatable {
  final String id;
  final String conversationId;
  final String text;
  final DateTime timestamp;
  final bool isFinal;
  final String? speakerLabel;
  final String recognitionEngine;
  final String? language;

  const TranscriptSegment({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.timestamp,
    required this.isFinal,
    this.speakerLabel,
    required this.recognitionEngine,
    this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'finalization_status': isFinal ? 1 : 0,
      'speaker_label': speakerLabel,
      'recognition_engine': recognitionEngine,
      'language': language,
    };
  }

  factory TranscriptSegment.fromMap(Map<String, dynamic> map) {
    return TranscriptSegment(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      text: map['text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isFinal: (map['finalization_status'] as int) == 1,
      speakerLabel: map['speaker_label'] as String?,
      recognitionEngine: map['recognition_engine'] as String,
      language: map['language'] as String?,
    );
  }

  TranscriptSegment copyWith({
    String? id,
    String? conversationId,
    String? text,
    DateTime? timestamp,
    bool? isFinal,
    String? speakerLabel,
    String? recognitionEngine,
    String? language,
  }) {
    return TranscriptSegment(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFinal: isFinal ?? this.isFinal,
      speakerLabel: speakerLabel ?? this.speakerLabel,
      recognitionEngine: recognitionEngine ?? this.recognitionEngine,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        text,
        timestamp,
        isFinal,
        speakerLabel,
        recognitionEngine,
        language,
      ];
}
