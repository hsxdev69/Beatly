import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/music_repository.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final repo = context.read<MusicRepository>();
    final allSongs = [...repo.getFeaturedCarouselSongs(), ...repo.getForgottenFavorites(), ...repo.getTop100Chart()];
    final likedSongs = allSongs.where((s) => player.isFavorite(s.id)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E202B),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        children: [
          // Top Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Library', style: AppTypography.headerLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history_rounded, size: 24, color: Color(0xFF2C3040)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.trending_up_rounded, size: 24, color: Color(0xFF2C3040)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.group_rounded, size: 24, color: Color(0xFF2C3040)),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips: Playlists, Songs, Albums, Artists, Local
          SizedBox(
            height: 38,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _buildLibFilterChip('Playlists', true),
                _buildLibFilterChip('Songs', false),
                _buildLibFilterChip('Albums', false),
                _buildLibFilterChip('Artists', false),
                _buildLibFilterChip('Local', false),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Date added sort pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.pillLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Date added', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.pillLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.keyboard_arrow_up_rounded, size: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2-Column Grid: Liked, Downloaded, Exported, Cached, My top 50, My bottom 50, Local
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildLibraryActionTile(Icons.favorite_rounded, 'Liked (${likedSongs.length})')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLibraryActionTile(Icons.check_circle_outline_rounded, 'Downloaded')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildLibraryActionTile(Icons.file_download_outlined, 'Exported')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLibraryActionTile(Icons.cached_rounded, 'Cached')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildLibraryActionTile(Icons.trending_up_rounded, 'My top 50')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLibraryActionTile(Icons.trending_down_rounded, 'My bottom 50')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildLibraryActionTile(Icons.folder_open_rounded, 'Local')),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // Playlists section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Playlists', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E202B))),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('hello', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('1 song', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibFilterChip(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : const Color(0xFFE9ECF4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF3B4054),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildLibraryActionTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E202B), size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E202B)),
          ),
        ],
      ),
    );
  }
}
