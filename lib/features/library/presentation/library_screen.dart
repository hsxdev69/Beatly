import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../app/theme/dimensions.dart';
import '../../../core/network/music_repository.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../shared/widgets/song_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        title: const Text('New Playlist', style: AppTypography.titleLarge),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final player = context.watch<AudioPlayerService>();

    final allSongs = [
      ...repo.getFeaturedCarouselSongs(),
      ...repo.getTop100Chart(),
      ...repo.getForgottenFavorites(),
    ];
    final favorites = allSongs.where((s) => player.isFavorite(s.id)).toList();
    final currentSong = player.currentSong;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your Library', style: AppTypography.displayLarge),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: AppColors.textPrimary, size: 28),
                    onPressed: () => _showCreatePlaylistDialog(context),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3.0,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.titleMedium.copyWith(fontSize: 14),
              tabs: const [
                Tab(text: 'Favorites'),
                Tab(text: 'Playlists'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Favorites
                  favorites.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: 12),
                              const Text('No favorite songs yet', style: AppTypography.titleMedium),
                              const SizedBox(height: 4),
                              Text('Tap heart on any song to save it here', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8, bottom: AppDimensions.bottomNavTotalSpace),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final song = favorites[index];
                            final isPlaying = currentSong?.id == song.id;

                            return SongListItem(
                              song: song,
                              isPlaying: isPlaying,
                              onTap: () => player.playSong(song, favorites),
                              onFavoriteToggle: () => player.toggleFavorite(song.id),
                              onAddToQueue: () => player.addToQueue(song),
                            );
                          },
                        ),

                  // Tab 2: Playlists
                  ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Liked songs collection card
                      GestureDetector(
                        onTap: () {
                          if (favorites.isNotEmpty) {
                            player.playSong(favorites.first, favorites);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.darkGlassBorder),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFED5564), Color(0xFFFF7281)],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Liked Songs', style: AppTypography.titleLarge),
                                    const SizedBox(height: 4),
                                    Text('${favorites.length} songs', style: AppTypography.bodySmall),
                                  ],
                                ),
                              ),
                              const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 36),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
