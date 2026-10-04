import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../shared/models/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onPlayNext;
  final VoidCallback? onAddToQueue;
  final VoidCallback? onAddToPlaylist;

  const SongListItem({
    super.key,
    required this.song,
    this.isPlaying = false,
    required this.onTap,
    this.onFavoriteToggle,
    this.onPlayNext,
    this.onAddToQueue,
    this.onAddToPlaylist,
  });

  String _formatDuration(Duration? d) {
    if (d == null) return '';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppDimensions.borderSmall,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Artwork with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  width: AppDimensions.listThumbnailSize,
                  height: AppDimensions.listThumbnailSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: song.thumbnailUrl.isNotEmpty ? song.thumbnailUrl : song.coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(color: AppColors.darkSurfaceVariant),
                        errorWidget: (c, u, e) => Container(
                          color: AppColors.darkSurfaceVariant,
                          child: const Icon(Icons.music_note, color: AppColors.textTertiary),
                        ),
                      ),
                      if (isPlaying)
                        Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: Icon(Icons.equalizer, color: AppColors.primary, size: 24),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14.0),

              // Title and Artist
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isPlaying ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            song.artist,
                            style: AppTypography.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (song.duration != null) ...[
                          const SizedBox(width: 6.0),
                          const Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                          const SizedBox(width: 6.0),
                          Text(
                            _formatDuration(song.duration),
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Heart Icon
              if (onFavoriteToggle != null)
                IconButton(
                  icon: Icon(
                    song.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: song.isLiked ? AppColors.primary : AppColors.textTertiary,
                  ),
                  onPressed: onFavoriteToggle,
                ),

              // Popup Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                color: AppColors.darkSurfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'next') onPlayNext?.call();
                  if (val == 'queue') onAddToQueue?.call();
                  if (val == 'playlist') onAddToPlaylist?.call();
                },
                itemBuilder: (c) => [
                  const PopupMenuItem(
                    value: 'next',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_play, color: AppColors.textPrimary, size: 20),
                        SizedBox(width: 12),
                        Text('Play next', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'queue',
                    child: Row(
                      children: [
                        Icon(Icons.queue_music, color: AppColors.textPrimary, size: 20),
                        SizedBox(width: 12),
                        Text('Add to queue', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'playlist',
                    child: Row(
                      children: [
                        Icon(Icons.add_to_photos, color: AppColors.textPrimary, size: 20),
                        SizedBox(width: 12),
                        Text('Add to playlist', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
