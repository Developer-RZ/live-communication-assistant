import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utilities/date_formatter.dart';
import '../../../../core/utilities/file_exporter.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/models/conversation.dart';
import '../providers/conversation_history_provider.dart';
import 'conversation_detail_screen.dart';

class ConversationHistoryScreen extends ConsumerStatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  ConsumerState<ConversationHistoryScreen> createState() => _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends ConsumerState<ConversationHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRename(Conversation conv) async {
    final titleController = TextEditingController(text: conv.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Conversation'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Conversation Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, titleController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      await ref
          .read(conversationHistoryNotifierProvider.notifier)
          .renameConversation(conv.id, newTitle);
    }
  }

  Future<void> _handleDelete(Conversation conv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: Text('Are you sure you want to permanently delete "${conv.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(conversationHistoryNotifierProvider.notifier)
          .deleteConversation(conv.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(conversationHistoryNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transcripts or titles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(conversationHistoryNotifierProvider.notifier).search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E2838),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                ref.read(conversationHistoryNotifierProvider.notifier).search(val);
              },
            ),
          ),

          // Conversation List
          Expanded(
            child: historyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyState.conversations.isEmpty
                    ? Center(
                        child: Text(
                          historyState.searchQuery.isEmpty
                              ? 'No saved conversations yet.'
                              : 'No conversations matching "${historyState.searchQuery}".',
                          style: TextStyle(
                            fontSize: 16 * settings.fontScale,
                            color: Colors.white60,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: historyState.conversations.length,
                        itemBuilder: (context, index) {
                          final conv = historyState.conversations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConversationDetailScreen(conversation: conv),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            conv.title,
                                            style: TextStyle(
                                              fontSize: 18 * settings.fontScale,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, color: Colors.white70),
                                          onSelected: (val) {
                                            if (val == 'rename') _handleRename(conv);
                                            if (val == 'delete') _handleDelete(conv);
                                            if (val == 'export') FileExporter.shareConversation(conv);
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(
                                              value: 'rename',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Rename'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'export',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.share, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Export Text File'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      DateFormatter.formatDateTime(conv.startedAt),
                                      style: TextStyle(
                                        fontSize: 13 * settings.fontScale,
                                        color: AppColors.textMutedDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      conv.transcriptPreview,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15 * settings.fontScale,
                                        color: Colors.white70,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
