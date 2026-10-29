import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../speech_recognition/domain/models/recognition_status.dart';

class ListeningStatusIndicator extends StatefulWidget {
  final RecognitionStatus status;
  final double fontScale;

  const ListeningStatusIndicator({
    super.key,
    required this.status,
    this.fontScale = 1.0,
  });

  @override
  State<ListeningStatusIndicator> createState() => _ListeningStatusIndicatorState();
}

class _ListeningStatusIndicatorState extends State<ListeningStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case RecognitionStatus.listening:
        return AppColors.statusListening;
      case RecognitionStatus.paused:
        return AppColors.statusPaused;
      case RecognitionStatus.initializing:
      case RecognitionStatus.processing:
        return AppColors.statusInitializing;
      case RecognitionStatus.stopped:
      case RecognitionStatus.idle:
        return AppColors.statusStopped;
      case RecognitionStatus.permissionDenied:
      case RecognitionStatus.networkUnavailable:
      case RecognitionStatus.recognitionUnavailable:
      case RecognitionStatus.error:
        return AppColors.statusError;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case RecognitionStatus.listening:
        return Icons.mic;
      case RecognitionStatus.paused:
        return Icons.pause_circle_filled;
      case RecognitionStatus.initializing:
      case RecognitionStatus.processing:
        return Icons.sync;
      case RecognitionStatus.stopped:
      case RecognitionStatus.idle:
        return Icons.mic_off;
      case RecognitionStatus.permissionDenied:
        return Icons.mic_external_off;
      case RecognitionStatus.networkUnavailable:
        return Icons.wifi_off;
      case RecognitionStatus.recognitionUnavailable:
      case RecognitionStatus.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final isListening = widget.status.isActiveListening;

    return Semantics(
      label: 'Speech recognition status: ${widget.status.label}',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isListening
                ? ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  )
                : Icon(
                    _getStatusIcon(),
                    color: color,
                    size: 18 * widget.fontScale,
                  ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.status.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
