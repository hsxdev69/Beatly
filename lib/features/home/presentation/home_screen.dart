import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/music_repository.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../shared/models/song.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMood = 'Feel good';
  final List<String> _moods = ['Feel good', 'Romance', 'Relax', 'Party', 'Energize'];

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final player = context.watch<AudioPlayerService>();

    final featured = repo.getFeaturedCarouselSongs();
    final forgotten = repo.getForgottenFavorites();
    final charts = repo.getTop100Chart();

    return ListView(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      children: [
        // Top Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Echo Music', style: AppTypography.headerLarge),
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

        // Mood & Activity Chips Row
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = mood == _selectedMood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.pillLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mood,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF3B4054),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // Hero Carousel
        SizedBox(
          height: 310,
          child: PageView(
            controller: PageController(viewportFraction: 0.86),
            children: [
              _buildHeroCard(
                song: featured[0],
                badge: 'KHALASI',
                sub: 'ACHINT X ADITYA GADHVI',
                onTap: () => player.playSong(featured[0], featured),
              ),
              _buildHeroCard(
                song: featured[1],
                badge: 'FAKIRA',
                sub: 'SANAM PURI X VISHAL-SHEKHAR',
                onTap: () => player.playSong(featured[1], featured),
              ),
              _buildHeroCard(
                song: featured[2],
                badge: 'GTA VI: THE ALBUM',
                sub: 'MORGAN WALLEN',
                onTap: () => player.playSong(featured[2], featured),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // FORGOTTEN FAVORITES
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FORGOTTEN FAVORITES', style: AppTypography.sectionTitle),
              OutlinedButton(
                onPressed: () => player.playSong(forgotten[0], forgotten),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(68, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: const BorderSide(color: Color(0xFFD0D5E4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Play all', style: TextStyle(fontSize: 12, color: Color(0xFF2B2F40))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: forgotten.map((s) => _buildSongTile(s, player, forgotten)).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // STATION / LISTEN TOGETHER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF5A6076))),
                  Text('LISTEN TOGETHER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Color(0xFF1E202B))),
                ],
              ),
              OutlinedButton(
                onPressed: () => player.playSong(charts[0], charts),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(68, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: const BorderSide(color: Color(0xFFD0D5E4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Play all', style: TextStyle(fontSize: 12, color: Color(0xFF2B2F40))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: charts.take(3).map((s) => _buildSongTile(s, player, charts)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard({
    required Song song,
    required String badge,
    required String sub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(
            image: NetworkImage(song.coverUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongTile(Song song, AudioPlayerService player, List<Song> contextQueue) {
    final isCurrent = player.currentSong?.id == song.id;
    return InkWell(
      onTap: () => player.playSong(song, contextQueue),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(song.coverUrl, width: 48, height: 48, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: isCurrent ? AppColors.accentIndigo : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.songSubtitle,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF71778E), size: 20),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
