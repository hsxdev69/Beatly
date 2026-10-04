import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../app/theme/dimensions.dart';
import '../../../core/network/music_repository.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/section_header.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  final List<Map<String, dynamic>> _genres = const [
    {'name': 'Pop', 'color': Color(0xFFE91E63), 'icon': Icons.music_note},
    {'name': 'Hip-Hop', 'color': Color(0xFFFF9800), 'icon': Icons.album},
    {'name': 'Rock', 'color': Color(0xFFF44336), 'icon': Icons.electric_bolt},
    {'name': 'Electronic', 'color': Color(0xFF00BCD4), 'icon': Icons.surround_sound},
    {'name': 'R&B / Soul', 'color': Color(0xFF9C27B0), 'icon': Icons.nightlife},
    {'name': 'Indie', 'color': Color(0xFF4CAF50), 'icon': Icons.radio},
    {'name': 'Classical', 'color': Color(0xFF795548), 'icon': Icons.piano},
    {'name': 'Bollywood', 'color': Color(0xFFED5564), 'icon': Icons.graphic_eq_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final player = context.watch<AudioPlayerService>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                child: Text('Explore & Charts', style: AppTypography.displayLarge),
              ),
            ),

            // Listen Together Banner (Echo Music signature collaborative feature)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  color: AppColors.primary.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(Icons.group_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Listen Together', style: AppTypography.titleLarge),
                            SizedBox(height: 4),
                            Text(
                              'Stream music in real-time sync with friends',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),

            // Moods & Genres Section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: SectionHeader(
                  title: 'Moods & Genres',
                  subtitle: 'BROWSE BY CATEGORY',
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final genre = _genres[index];
                    final color = genre['color'] as Color;

                    return GestureDetector(
                      onTap: () {
                        repo.searchSongs('${genre['name']} hits').then((songs) {
                          if (songs.isNotEmpty) {
                            player.playSong(songs.first, songs);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.8),
                              color.withValues(alpha: 0.4),
                            ],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Text(
                              genre['name'] as String,
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Icon(
                                genre['icon'] as IconData,
                                color: Colors.white.withValues(alpha: 0.35),
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _genres.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.bottomNavTotalSpace),
            ),
          ],
        ),
      ),
    );
  }
}
