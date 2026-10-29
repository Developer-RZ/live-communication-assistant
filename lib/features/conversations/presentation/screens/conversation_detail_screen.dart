import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utilities/date_formatter.dart';
import '../../../../core/utilities/file_exporter.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/models/conversation.dart';
import '../widgets/transcript_segment_bubble.dart';

class ConversationDetailScreen extends ConsumerWidget {
  final Conversation conversation;

  const ConversationDetailScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(conversation.title),
        actions: [
          IconButton(
            tooltip: 'Export Transcript',
            icon: const Icon(Icons.share),
            onPressed: () => FileExporter.shareConversation(conversation),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF141F2F),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormatter.formatDateTime(conversation.startedAt),
                  style: TextStyle(
                    fontSize: 14 * settings.fontScale,
                    color: AppColors.textMutedDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Language: ${conversation.language} • Total Segments: ${conversation.segments.length}',
                  style: TextStyle(
                    fontSize: 13 * settings.fontScale,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Segments list
          Expanded(
            child: conversation.segments.isEmpty
                ? Center(
                    child: Text(
                      'No transcript segments recorded.',
                      style: TextStyle(
                        fontSize: 16 * settings.fontScale,
                        color: Colors.white54,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: conversation.segments.length,
                    itemBuilder: (context, index) {
                      return TranscriptSegmentBubble(
                        segment: conversation.segments[index],
                        fontScale: settings.fontScale,
                        isHighContrast: settings.isHighContrast,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
