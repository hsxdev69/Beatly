import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../app/theme/dimensions.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../lyrics/presentation/lyrics_view.dart';
import '../../queue/presentation/queue_sheet.dart';

class FullPlayerSheet extends StatefulWidget {
  const FullPlayerSheet({super.key});

  @override
  State<FullPlayerSheet> createState() => _FullPlayerSheetState();
}

class _FullPlayerSheetState extends State<FullPlayerSheet> {
  bool _showLyrics = false;
  double? _dragValue;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showQueueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.75,
        child: QueueSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final song = player.currentSong;

    if (song == null) {
      return const SizedBox.shrink();
    }

    final duration = player.duration > Duration.zero ? player.duration : (song.duration ?? Duration.zero);
    final position = player.position;
    final sliderMax = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final currentSliderVal = (_dragValue ?? position.inMilliseconds.toDouble()).clamp(0.0, sliderMax);
    final isLiked = player.isFavorite(song.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dynamic blurred backdrop (Apple-music style deep blur)
          CachedNetworkImage(
            imageUrl: song.thumbnailUrl.isNotEmpty ? song.thumbnailUrl : song.coverUrl,
            fit: BoxFit.cover,
            errorWidget: (c, u, e) => Container(color: AppColors.darkBackground),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),

          // 2. Main Player Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Column(
                        children: [
                          Text(
                            'PLAYING FROM QUEUE',
                            style: AppTypography.labelSmall.copyWith(
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.album?.isNotEmpty == true ? song.album! : 'Echo Music Stream',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Error Banner if stream resolution encountered an issue
                if (player.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      player.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),

                // Center Area: Artwork OR Lyrics
                Expanded(
                  child: _showLyrics
                      ? const LyricsView()
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36.0),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.45),
                                      blurRadius: 36.0,
                                      spreadRadius: 4.0,
                                      offset: const Offset(0, 18),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                  child: CachedNetworkImage(
                                    imageUrl: song.thumbnailUrl.isNotEmpty ? song.thumbnailUrl : song.coverUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (c, u) => Container(color: AppColors.darkSurfaceVariant),
                                    errorWidget: (c, u, e) => Container(
                                      color: AppColors.darkSurfaceVariant,
                                      child: const Icon(Icons.music_note, color: AppColors.textTertiary, size: 64),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 16.0),

                // Title, Artist, & Favorite
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MarqueeText(
                              text: song.title,
                              style: AppTypography.headlineMedium.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              song.artist,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isLiked ? AppColors.primary : Colors.white70,
                          size: 28,
                        ),
                        onPressed: () => player.toggleFavorite(song.id),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12.0),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: currentSliderVal,
                          min: 0.0,
                          max: sliderMax,
                          onChanged: (val) {
                            setState(() => _dragValue = val);
                          },
                          onChangeEnd: (val) {
                            player.seek(Duration(milliseconds: val.toInt()));
                            setState(() => _dragValue = null);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8.0),

                // Main Playback Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: player.isShuffle ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
                          size: 26,
                        ),
                        onPressed: player.toggleShuffle,
                      ),

                      // Previous
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 42),
                        onPressed: player.prev,
                      ),

                      // Play / Pause / Buffering
                      GestureDetector(
                        onTap: player.playPause,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: player.isLoading
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 3.0,
                                    ),
                                  )
                                : Icon(
                                    player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.black,
                                    size: 40,
                                  ),
                          ),
                        ),
                      ),

                      // Next
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 42),
                        onPressed: player.next,
                      ),

                      // Repeat
                      IconButton(
                        icon: Icon(
                          player.isRepeat ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                          color: player.isRepeat ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
                          size: 26,
                        ),
                        onPressed: player.toggleRepeat,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                // Bottom Action Bar: Lyrics & Queue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lyrics Button
                      IconButton(
                        icon: Icon(
                          Icons.lyrics_outlined,
                          color: _showLyrics ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
                          size: 26,
                        ),
                        onPressed: () => setState(() => _showLyrics = !_showLyrics),
                      ),

                      // Queue Button
                      IconButton(
                        icon: Icon(
                          Icons.queue_music_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 26,
                        ),
                        onPressed: () => _showQueueModal(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
