import 'package:flutter_test/flutter_test.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/conversation.dart';
import 'package:live_communication_assistant/features/conversations/domain/models/transcript_segment.dart';
import 'package:live_communication_assistant/features/conversations/domain/repositories/conversation_repository.dart';

class InMemoryConversationRepository implements ConversationRepository {
  final Map<String, Conversation> _storage = {};
  final List<TranscriptSegment> _segments = [];

  @override
  Future<List<Conversation>> getConversations() async {
    final list = _storage.values.toList();
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  @override
  Future<Conversation?> getConversationById(String id) async {
    return _storage[id];
  }

  @override
  Future<void> saveConversation(Conversation conversation) async {
    _storage[conversation.id] = conversation;
  }

  @override
  Future<void> updateConversationTitle(String id, String newTitle) async {
    final existing = _storage[id];
    if (existing != null) {
      _storage[id] = existing.copyWith(title: newTitle, updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> deleteConversation(String id) async {
    _storage.remove(id);
    _segments.removeWhere((s) => s.conversationId == id);
  }

  @override
  Future<void> saveSegment(TranscriptSegment segment) async {
    _segments.add(segment);
    final conv = _storage[segment.conversationId];
    if (conv != null) {
      final updatedSegments = List<TranscriptSegment>.from(conv.segments)..add(segment);
      _storage[segment.conversationId] = conv.copyWith(segments: updatedSegments);
    }
  }

  @override
  Future<List<Conversation>> searchConversations(String query) async {
    final lower = query.toLowerCase();
    return _storage.values.where((c) {
      return c.title.toLowerCase().contains(lower) ||
          c.segments.any((s) => s.text.toLowerCase().contains(lower));
    }).toList();
  }
}

void main() {
  late InMemoryConversationRepository repo;

  setUp(() {
    repo = InMemoryConversationRepository();
  });

  group('ConversationRepository CRUD & Search Tests', () {
    test('Saves and retrieves conversations accurately', () async {
      final conv = Conversation(
        id: 'c-100',
        title: 'Interview with Client',
        startedAt: DateTime.now(),
        language: 'English (US)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveConversation(conv);

      final fetched = await repo.getConversationById('c-100');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Interview with Client');
    });

    test('Updates conversation title', () async {
      final conv = Conversation(
        id: 'c-101',
        title: 'Draft Title',
        startedAt: DateTime.now(),
        language: 'Tamil',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveConversation(conv);
      await repo.updateConversationTitle('c-101', 'Finalized Meeting Title');

      final updated = await repo.getConversationById('c-101');
      expect(updated!.title, 'Finalized Meeting Title');
    });

    test('Deletes conversation properly', () async {
      final conv = Conversation(
        id: 'c-102',
        title: 'To Be Deleted',
        startedAt: DateTime.now(),
        language: 'English',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveConversation(conv);
      await repo.deleteConversation('c-102');

      final fetched = await repo.getConversationById('c-102');
      expect(fetched, isNull);
    });

    test('Search finds matches in title or transcript segments', () async {
      final conv = Conversation(
        id: 'c-103',
        title: 'Dentist Appointment',
        startedAt: DateTime.now(),
        language: 'English',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        segments: [
          TranscriptSegment(
            id: 's-1',
            conversationId: 'c-103',
            text: 'Your next root canal session is scheduled for Tuesday.',
            timestamp: DateTime.now(),
            isFinal: true,
            recognitionEngine: 'Mock',
          ),
        ],
      );

      await repo.saveConversation(conv);

      // Search by title keyword
      final titleMatch = await repo.searchConversations('Dentist');
      expect(titleMatch.length, 1);

      // Search by segment text keyword
      final segmentMatch = await repo.searchConversations('canal');
      expect(segmentMatch.length, 1);

      // Search non-existent keyword
      final noMatch = await repo.searchConversations('astronaut');
      expect(noMatch, isEmpty);
    });
  });
}
