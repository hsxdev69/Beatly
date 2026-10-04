import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/services/audio_player_service.dart';

class LyricsView extends StatefulWidget {
  const LyricsView({super.key});

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLine(int index) {
    if (_lastActiveIndex == index || !_scrollController.hasClients) return;
    _lastActiveIndex = index;

    final targetOffset = (index * 56.0) - 150.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final song = player.currentSong;

    if (song == null || song.lyrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_off_outlined, color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 12),
            Text('No lyrics available for this song', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final lyrics = song.lyrics;
    final currentPos = player.position;
    int activeIndex = -1;

    for (int i = 0; i < lyrics.length; i++) {
      if (currentPos >= lyrics[i].time) {
        activeIndex = i;
      } else {
        break;
      }
    }

    if (activeIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveLine(activeIndex);
      });
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
      itemCount: lyrics.length,
      itemBuilder: (context, index) {
        final line = lyrics[index];
        final isActive = index == activeIndex;
        final isPast = index < activeIndex;

        return GestureDetector(
          onTap: () => player.seek(line.time),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: isActive ? 12.0 : 8.0),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isActive ? 24.0 : 18.0,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : isPast
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.55),
                letterSpacing: -0.3,
                height: 1.4,
              ),
              child: Text(line.text),
            ),
          ),
        );
      },
    );
  }
}
