import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../speech_recognition/domain/models/recognition_status.dart';
import '../providers/live_transcription_notifier.dart';
import '../widgets/listening_status_indicator.dart';
import '../widgets/transcript_segment_bubble.dart';
import '../widgets/live_controls_bar.dart';

class LiveConversationScreen extends ConsumerStatefulWidget {
  const LiveConversationScreen({super.key});

  @override
  ConsumerState<LiveConversationScreen> createState() => _LiveConversationScreenState();
}

class _LiveConversationScreenState extends ConsumerState<LiveConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _userScrolledUp = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveTranscriptionNotifierProvider.notifier).startSession();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // If user is more than 80px away from bottom, mark userScrolledUp
      if (maxScroll - currentScroll > 80) {
        if (!_userScrolledUp) {
          setState(() => _userScrolledUp = true);
        }
      } else {
        if (_userScrolledUp) {
          setState(() => _userScrolledUp = false);
        }
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _userScrolledUp = false);
    }
  }

  Future<void> _confirmClearTranscript() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Transcript?'),
        content: const Text('This will delete all current live conversation text from the screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.textError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(liveTranscriptionNotifierProvider.notifier).clearCurrentTranscript();
    }
  }

  Future<void> _handleSave() async {
    await ref.read(liveTranscriptionNotifierProvider.notifier).saveCurrentConversation();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation successfully saved to History.'),
          backgroundColor: AppColors.textSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveTranscriptionNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    // Auto scroll if enabled and user has not scrolled up to inspect
    if (settings.autoScrollEnabled && !_userScrolledUp && liveState.hasActiveContent) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          liveState.activeConversation?.title ?? 'Live Conversation',
        ),
        actions: [
          IconButton(
            tooltip: 'Language: ${settings.preferredLanguage.displayName}',
            icon: const Icon(Icons.translate),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Active Language: ${settings.preferredLanguage.displayName}'),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Top status bar with visual indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black26,
                child: Center(
                  child: ListeningStatusIndicator(
                    status: liveState.status,
                    fontScale: settings.fontScale,
                  ),
                ),
              ),

              // Error banner if any
              if (liveState.errorMessage != null)
                Container(
                  width: double.infinity,
                  color: AppColors.statusError.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          liveState.errorMessage!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * settings.fontScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (liveState.status == RecognitionStatus.permissionDenied)
                        TextButton(
                          onPressed: () => ref
                              .read(liveTranscriptionNotifierProvider.notifier)
                              .requestPermission(),
                          child: const Text('Allow Mic', style: TextStyle(color: Colors.yellowAccent)),
                        ),
                    ],
                  ),
                ),

              // Transcripts list
              Expanded(
                child: liveState.finalizedSegments.isEmpty && liveState.activePartialText.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.hearing,
                                size: 64 * settings.fontScale,
                                color: Colors.white30,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Speak or listen to someone speaking.\nWords will appear here instantly.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16 * settings.fontScale,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        itemCount: liveState.finalizedSegments.length +
                            (liveState.activePartialText.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < liveState.finalizedSegments.length) {
                            return TranscriptSegmentBubble(
                              segment: liveState.finalizedSegments[index],
                              fontScale: settings.fontScale,
                              isHighContrast: settings.isHighContrast,
                            );
                          } else {
                            return TranscriptSegmentBubble(
                              partialText: liveState.activePartialText,
                              fontScale: settings.fontScale,
                              isHighContrast: settings.isHighContrast,
                            );
                          }
                        },
                      ),
              ),

              // Bottom control bar
              LiveControlsBar(
                status: liveState.status,
                fontScale: settings.fontScale,
                onStart: () => ref
                    .read(liveTranscriptionNotifierProvider.notifier)
                    .startSession(),
                onPause: () => ref
                    .read(liveTranscriptionNotifierProvider.notifier)
                    .pauseSession(),
                onResume: () => ref
                    .read(liveTranscriptionNotifierProvider.notifier)
                    .resumeSession(),
                onStop: () => ref
                    .read(liveTranscriptionNotifierProvider.notifier)
                    .stopSession(),
                onClear: _confirmClearTranscript,
                onSave: _handleSave,
              ),
            ],
          ),

          // Floating resume auto-scroll button if user scrolled up
          if (_userScrolledUp)
            Positioned(
              bottom: 90,
              right: 16,
              child: FloatingActionButton.extended(
                backgroundColor: AppColors.statusListening,
                foregroundColor: Colors.black,
                onPressed: _scrollToBottom,
                icon: const Icon(Icons.arrow_downward),
                label: const Text('Resume Auto-Scroll', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
