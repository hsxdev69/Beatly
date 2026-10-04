import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../core/services/audio_player_service.dart';
import 'glass_container.dart';
import 'marquee_text.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final song = player.currentSong;

    if (song == null) {
      return const SizedBox.shrink();
    }

    final totalMs = player.duration.inMilliseconds;
    final currentMs = player.position.inMilliseconds;
    final progress = totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: GlassContainer(
        height: AppDimensions.miniPlayerHeight,
        borderRadius: BorderRadius.circular(20.0),
        color: AppColors.darkSurfaceVariant.withValues(alpha: 0.85),
        blur: 24.0,
        onTap: onTap,
        child: Stack(
          children: [
            // Main row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SizedBox(
                      width: 46.0,
                      height: 46.0,
                      child: CachedNetworkImage(
                        imageUrl: song.thumbnailUrl.isNotEmpty ? song.thumbnailUrl : song.coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(color: AppColors.darkSurface),
                        errorWidget: (c, u, e) => Container(
                          color: AppColors.darkSurface,
                          child: const Icon(Icons.music_note, color: AppColors.textTertiary, size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),

                  // Song Title & Artist
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarqueeText(
                          text: song.title,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          song.artist,
                          style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Skip Previous
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 24),
                    onPressed: player.prev,
                  ),

                  // Play / Pause Button with real resolving progress
                  IconButton(
                    icon: player.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            player.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.primary,
                            size: 30,
                          ),
                    onPressed: player.playPause,
                  ),

                  // Skip Next Button
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 24),
                    onPressed: player.next,
                  ),
                ],
              ),
            ),

            // Subtle progress indicator on the bottom edge
            Positioned(
              left: 14,
              right: 14,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2.0,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
