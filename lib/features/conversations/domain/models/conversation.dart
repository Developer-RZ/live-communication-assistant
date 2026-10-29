import 'package:equatable/equatable.dart';
import 'transcript_segment.dart';

class Conversation extends Equatable {
  final String id;
  final String title;
  final String conversationMode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranscriptSegment> segments;

  const Conversation({
    required this.id,
    required this.title,
    this.conversationMode = 'face_to_face',
    required this.startedAt,
    this.endedAt,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    this.segments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'conversation_mode': conversationMode,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map, {List<TranscriptSegment> segments = const []}) {
    return Conversation(
      id: map['id'] as String,
      title: map['title'] as String,
      conversationMode: map['conversation_mode'] as String,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at'] as String) : null,
      language: map['language'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      segments: segments,
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    String? conversationMode,
    DateTime? startedAt,
    DateTime? endedAt,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TranscriptSegment> segments,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      conversationMode: conversationMode ?? this.conversationMode,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      segments: segments ?? this.segments,
    );
  }

  String get transcriptPreview {
    if (segments.isEmpty) return 'No conversation text recorded.';
    final text = segments.map((s) => s.text).join(' ');
    return text.length > 120 ? '${text.substring(0, 117)}...' : text;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        conversationMode,
        startedAt,
        endedAt,
        language,
        createdAt,
        updatedAt,
        segments,
      ];
}
