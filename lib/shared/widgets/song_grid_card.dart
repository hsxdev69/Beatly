import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/dimensions.dart';
import '../../shared/models/song.dart';

class SongGridCard extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongGridCard({
    super.key,
    required this.song,
    this.isPlaying = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.gridItemWidth,
      margin: const EdgeInsets.only(right: 14.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Artwork
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: song.thumbnailUrl.isNotEmpty ? song.thumbnailUrl : song.coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(color: AppColors.darkSurfaceVariant),
                        errorWidget: (c, u, e) => Container(
                          color: AppColors.darkSurfaceVariant,
                          child: const Icon(Icons.music_note, color: AppColors.textTertiary, size: 36),
                        ),
                      ),
                      if (isPlaying)
                        Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: Icon(Icons.equalizer, color: AppColors.primary, size: 32),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0),

              // Title
              Text(
                song.title,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPlaying ? AppColors.primary : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),

              // Artist
              Text(
                song.artist,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
