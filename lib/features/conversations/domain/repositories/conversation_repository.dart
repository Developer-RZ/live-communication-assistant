import '../models/conversation.dart';
import '../models/transcript_segment.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation?> getConversationById(String id);
  Future<void> saveConversation(Conversation conversation);
  Future<void> updateConversationTitle(String id, String newTitle);
  Future<void> deleteConversation(String id);
  Future<void> saveSegment(TranscriptSegment segment);
  Future<List<Conversation>> searchConversations(String query);
}
