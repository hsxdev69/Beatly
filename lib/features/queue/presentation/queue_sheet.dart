import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../app/theme/dimensions.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../shared/models/song.dart';
import '../../../shared/widgets/glass_container.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final currentSong = player.currentSong;
    final queue = player.queue;

    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      color: AppColors.darkSurface.withValues(alpha: 0.95),
      blur: 32.0,
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Playing Queue', style: AppTypography.titleLarge),
                    Text(
                      '${queue.length} track${queue.length == 1 ? '' : 's'}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: player.isShuffle ? AppColors.primary : AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: player.toggleShuffle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.darkGlassBorder, height: 1),

          // Now Playing Section
          if (currentSong != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 4.0),
              child: Row(
                children: [
                  const Text('NOW PLAYING', style: AppTypography.labelSmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Active', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            _buildSongRow(
              context: context,
              song: currentSong,
              isCurrent: true,
              onTap: () {},
            ),
            const Divider(color: AppColors.darkGlassBorder, height: 16),
          ],

          // Up Next Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
            child: Row(
              children: [
                const Text('UP NEXT', style: AppTypography.labelSmall),
                const SizedBox(width: 8),
                Text(
                  '(${queue.length})',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          // Queue List
          Expanded(
            child: queue.isEmpty
                ? const Center(
                    child: Text('Queue is empty', style: AppTypography.bodyMedium),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      final isCurrent = item.id == currentSong?.id;

                      return _buildSongRow(
                        context: context,
                        song: item,
                        isCurrent: isCurrent,
                        onTap: () => player.playSong(item, queue),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongRow({
    required BuildContext context,
    required Song song,
    required bool isCurrent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isCurrent ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            width: 44,
            height: 44,
            child: CachedNetworkImage(
              imageUrl: song.thumbnailUrl.isNotEmpty ? song.thumbnailUrl : song.coverUrl,
              fit: BoxFit.cover,
              errorWidget: (c, u, e) => Container(
                color: AppColors.darkSurfaceVariant,
                child: const Icon(Icons.music_note, color: AppColors.textTertiary, size: 20),
              ),
            ),
          ),
        ),
        title: Text(
          song.title,
          style: AppTypography.bodyLarge.copyWith(
            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: AppTypography.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isCurrent
            ? const Icon(Icons.equalizer, color: AppColors.primary, size: 22)
            : const Icon(Icons.drag_handle_rounded, color: AppColors.textTertiary, size: 20),
        onTap: onTap,
      ),
    );
  }
}
