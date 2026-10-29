import 'package:sqflite/sqflite.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/transcript_segment.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../database/app_database.dart';
import '../database/database_schema.dart';

class SqliteConversationRepository implements ConversationRepository {
  final AppDatabase _dbProvider;

  SqliteConversationRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<Database> get _db async => await _dbProvider.database;

  @override
  Future<List<Conversation>> getConversations() async {
    final db = await _db;
    final List<Map<String, dynamic>> convMaps = await db.query(
      DatabaseSchema.tableConversations,
      orderBy: 'started_at DESC',
    );

    final List<Conversation> conversations = [];
    for (final map in convMaps) {
      final convId = map['id'] as String;
      final segmentMaps = await db.query(
        DatabaseSchema.tableSegments,
        where: 'conversation_id = ?',
        whereArgs: [convId],
        orderBy: 'timestamp ASC',
      );
      final segments = segmentMaps.map(TranscriptSegment.fromMap).toList();
      conversations.add(Conversation.fromMap(map, segments: segments));
    }
    return conversations;
  }

  @override
  Future<Conversation?> getConversationById(String id) async {
    final db = await _db;
    final maps = await db.query(
      DatabaseSchema.tableConversations,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final segmentMaps = await db.query(
      DatabaseSchema.tableSegments,
      where: 'conversation_id = ?',
      whereArgs: [id],
      orderBy: 'timestamp ASC',
    );

    final segments = segmentMaps.map(TranscriptSegment.fromMap).toList();
    return Conversation.fromMap(maps.first, segments: segments);
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        DatabaseSchema.tableConversations,
        conversation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final segment in conversation.segments) {
        await txn.insert(
          DatabaseSchema.tableSegments,
          segment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> updateConversationTitle(String id, String newTitle) async {
    final db = await _db;
    await db.update(
      DatabaseSchema.tableConversations,
      {
        'title': newTitle,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteConversation(String id) async {
    final db = await _db;
    await db.delete(
      DatabaseSchema.tableConversations,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> saveSegment(TranscriptSegment segment) async {
    final db = await _db;
    await db.insert(
      DatabaseSchema.tableSegments,
      segment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Conversation>> searchConversations(String query) async {
    final all = await getConversations();
    if (query.trim().isEmpty) return all;
    final lowerQuery = query.toLowerCase();

    return all.where((c) {
      final inTitle = c.title.toLowerCase().contains(lowerQuery);
      final inSegments = c.segments.any((s) => s.text.toLowerCase().contains(lowerQuery));
      return inTitle || inSegments;
    }).toList();
  }
}
