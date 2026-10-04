import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../app/theme/dimensions.dart';
import '../../../core/network/music_repository.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/song_grid_card.dart';
import '../../../shared/widgets/song_list_item.dart';
import '../../settings/presentation/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMoodIndex = 0;
  final List<String> _moods = [
    'All',
    'Energize',
    'Relax',
    'Workout',
    'Focus',
    'Party',
    'Chill',
    'Romance',
  ];

  void _onMoodSelected(int index, MusicRepository repo, AudioPlayerService player) {
    setState(() => _selectedMoodIndex = index);
    if (index > 0) {
      final mood = _moods[index];
      repo.searchSongs('$mood music hits').then((songs) {
        if (mounted && songs.isNotEmpty) {
          player.playSong(songs.first, songs);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final player = context.watch<AudioPlayerService>();

    final quickPicks = repo.getFeaturedCarouselSongs();
    final trending = repo.getTop100Chart();
    final recommendations = repo.getForgottenFavorites();
    final currentSong = player.currentSong;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Bar with Echo Music brand title & Settings button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                          child: const Center(
                            child: Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Echo Music',
                          style: AppTypography.displayLarge,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 24),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Speed Dial / Mood Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _moods.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8.0),
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    final isSelected = _selectedMoodIndex == index;

                    return GestureDetector(
                      onTap: () => _onMoodSelected(index, repo, player),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.darkGlassBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            mood,
                            style: AppTypography.labelLarge.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section 1: Quick Picks (Horizontal Carousel)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Quick Picks',
                    subtitle: 'START RADIO FROM A SONG',
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 215,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: quickPicks.length,
                      itemBuilder: (context, index) {
                        final song = quickPicks[index];
                        final isPlaying = currentSong?.id == song.id;

                        return SongGridCard(
                          song: song,
                          isPlaying: isPlaying,
                          onTap: () => player.playSong(song, quickPicks),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Section 2: Trending & Popular Hits
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Trending Worldwide',
                      subtitle: 'TOP GLOBAL CHARTS',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 215,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: trending.length,
                        itemBuilder: (context, index) {
                          final song = trending[index];
                          final isPlaying = currentSong?.id == song.id;

                          return SongGridCard(
                            song: song,
                            isPlaying: isPlaying,
                            onTap: () => player.playSong(song, trending),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section 3: Recommended & Favorites List
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: SectionHeader(
                  title: 'Recommended For You',
                  subtitle: 'DISCOVER SIMILAR SOUNDS',
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = recommendations[index];
                  final isPlaying = currentSong?.id == song.id;

                  return SongListItem(
                    song: song,
                    isPlaying: isPlaying,
                    onTap: () => player.playSong(song, recommendations),
                    onFavoriteToggle: () => player.toggleFavorite(song.id),
                    onAddToQueue: () => player.addToQueue(song),
                  );
                },
                childCount: recommendations.length,
              ),
            ),

            // Extra space above floating player dock
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.bottomNavTotalSpace),
            ),
          ],
        ),
      ),
    );
  }
}
