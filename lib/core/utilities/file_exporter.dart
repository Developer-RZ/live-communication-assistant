import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/conversations/domain/models/conversation.dart';
import 'date_formatter.dart';

class FileExporter {
  static Future<File> exportConversationAsText(Conversation conversation) async {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('LIVE COMMUNICATION ASSISTANT TRANSCRIPT');
    buffer.writeln('Title: ${conversation.title}');
    buffer.writeln('Date: ${DateFormatter.formatDateTime(conversation.startedAt)}');
    buffer.writeln('Language: ${conversation.language}');
    buffer.writeln('========================================\n');

    for (final segment in conversation.segments) {
      final time = DateFormatter.formatTime(segment.timestamp);
      final speaker = segment.speakerLabel != null ? '[${segment.speakerLabel}] ' : '';
      buffer.writeln('[$time] $speaker${segment.text}');
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'transcript_${DateFormatter.formatForFileName(conversation.startedAt)}.txt';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(buffer.toString());
    return file;
  }

  static Future<void> shareConversation(Conversation conversation) async {
    final file = await exportConversationAsText(conversation);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Transcript: ${conversation.title}',
      subject: conversation.title,
    );
  }
}
