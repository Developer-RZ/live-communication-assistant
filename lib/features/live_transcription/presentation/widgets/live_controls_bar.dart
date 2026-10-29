import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../speech_recognition/domain/models/recognition_status.dart';

class LiveControlsBar extends StatelessWidget {
  final RecognitionStatus status;
  final double fontScale;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onClear;
  final VoidCallback onSave;

  const LiveControlsBar({
    super.key,
    required this.status,
    required this.fontScale,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onClear,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = status.isActiveListening;
    final isPaused = status.isPaused;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Clear Button
            IconButton(
              tooltip: 'Clear Transcript',
              iconSize: 28 * fontScale,
              padding: const EdgeInsets.all(12),
              color: Colors.white70,
              icon: const Icon(Icons.delete_outline),
              onPressed: onClear,
            ),

            // Main Primary Toggle (Pause / Resume / Start)
            if (isListening)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusPaused,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(120, 56),
                ),
                onPressed: onPause,
                icon: const Icon(Icons.pause, size: 28),
                label: Text(
                  'Pause',
                  style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.bold),
                ),
              )
            else if (isPaused)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusListening,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(120, 56),
                ),
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow, size: 28),
                label: Text(
                  'Resume',
                  style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.bold),
                ),
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusListening,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(120, 56),
                ),
                onPressed: onStart,
                icon: const Icon(Icons.mic, size: 28),
                label: Text(
                  'Listen',
                  style: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.bold),
                ),
              ),

            // Stop Button
            if (isListening || isPaused)
              IconButton(
                tooltip: 'Stop Listening',
                iconSize: 28 * fontScale,
                padding: const EdgeInsets.all(12),
                color: AppColors.statusError,
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: onStop,
              ),

            // Save Button
            IconButton(
              tooltip: 'Save Conversation',
              iconSize: 28 * fontScale,
              padding: const EdgeInsets.all(12),
              color: AppColors.textSuccess,
              icon: const Icon(Icons.bookmark_border),
              onPressed: onSave,
            ),
          ],
        ),
      ),
    );
  }
}
