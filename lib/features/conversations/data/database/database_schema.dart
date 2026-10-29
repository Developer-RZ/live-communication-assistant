class DatabaseSchema {
  static const String tableConversations = 'conversations';
  static const String tableSegments = 'transcript_segments';

  static const String createConversationsTable = '''
    CREATE TABLE $tableConversations (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      conversation_mode TEXT NOT NULL,
      started_at TEXT NOT NULL,
      ended_at TEXT,
      language TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  ''';

  static const String createSegmentsTable = '''
    CREATE TABLE $tableSegments (
      id TEXT PRIMARY KEY,
      conversation_id TEXT NOT NULL,
      text TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      finalization_status INTEGER NOT NULL,
      speaker_label TEXT,
      recognition_engine TEXT NOT NULL,
      language TEXT,
      FOREIGN KEY (conversation_id) REFERENCES $tableConversations (id) ON DELETE CASCADE
    );
  ''';

  static const String createSegmentIndex = '''
    CREATE INDEX idx_segments_conversation ON $tableSegments(conversation_id);
  ''';
}
