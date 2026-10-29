import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utilities/date_formatter.dart';
import '../../../conversations/domain/models/transcript_segment.dart';

class TranscriptSegmentBubble extends StatelessWidget {
  final TranscriptSegment? segment;
  final String? partialText;
  final double fontScale;
  final bool isHighContrast;

  const TranscriptSegmentBubble({
    super.key,
    this.segment,
    this.partialText,
    required this.fontScale,
    required this.isHighContrast,
  }) : assert(segment != null || partialText != null, 'Either segment or partialText must be provided');

  @override
  Widget build(BuildContext context) {
    final bool isPartial = partialText != null;
    final String text = isPartial ? partialText! : segment!.text;
    final String timeStr = isPartial
        ? 'Speaking now...'
        : DateFormatter.formatTime(segment!.timestamp);

    final borderColor = isPartial
        ? AppColors.statusListening
        : (isHighContrast ? Colors.white38 : Colors.transparent);

    final bgColor = isPartial
        ? const Color(0xFF1E3A2F)
        : (isHighContrast ? const Color(0xFF161616) : AppColors.cardDark);

    return Semantics(
      label: 'Transcript: $text. Spoken at $timeStr',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isPartial ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (segment?.speakerLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      segment!.speakerLabel!,
                      style: TextStyle(
                        fontSize: 12 * fontScale,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: isPartial ? AppColors.statusListening : AppColors.textMutedDark,
                    fontWeight: isPartial ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: (isPartial ? 20 : 18) * fontScale,
                fontWeight: isPartial ? FontWeight.w600 : FontWeight.w500,
                color: isPartial ? Colors.white : AppColors.textHighContrast,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
