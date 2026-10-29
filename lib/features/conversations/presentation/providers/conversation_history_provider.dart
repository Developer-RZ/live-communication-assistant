import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../../live_transcription/presentation/providers/live_transcription_notifier.dart';

class ConversationHistoryState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String searchQuery;

  const ConversationHistoryState({
    this.conversations = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  ConversationHistoryState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? searchQuery,
  }) {
    return ConversationHistoryState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ConversationHistoryNotifier extends StateNotifier<ConversationHistoryState> {
  final ConversationRepository _repository;

  ConversationHistoryNotifier(this._repository)
      : super(const ConversationHistoryState()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true);
    final results = await _repository.getConversations();
    state = state.copyWith(conversations: results, isLoading: false);
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);
    final results = await _repository.searchConversations(query);
    state = state.copyWith(conversations: results, isLoading: false);
  }

  Future<void> renameConversation(String id, String newTitle) async {
    await _repository.updateConversationTitle(id, newTitle);
    await loadConversations();
  }

  Future<void> deleteConversation(String id) async {
    await _repository.deleteConversation(id);
    await loadConversations();
  }
}

final conversationHistoryNotifierProvider = StateNotifierProvider<
    ConversationHistoryNotifier, ConversationHistoryState>((ref) {
  final repo = ref.watch(conversationRepositoryProvider);
  return ConversationHistoryNotifier(repo);
});
