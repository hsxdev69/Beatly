import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/music_repository.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../shared/models/song.dart';
import '../../../../app/theme/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isLoading = false;

  Future<void> _onSearch(String query, MusicRepository repo) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final results = await repo.searchSongs(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final player = context.watch<AudioPlayerService>();
    final defaultCharts = repo.getTop100Chart();
    final displayedList = _searchResults.isNotEmpty ? _searchResults : defaultCharts;

    return ListView(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      children: [
        // Search YouTube Music input bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.pillLight,
              borderRadius: BorderRadius.circular(26),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF374151), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _onSearch(val, repo),
                    decoration: const InputDecoration(
                      hintText: 'Search YouTube Music...',
                      hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF374151)),
                  )
                else
                  const Icon(Icons.public_rounded, color: Color(0xFF374151), size: 22),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Apple Music Top 100 Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _searchResults.isNotEmpty ? 'Search Results' : 'Apple Music Top 100',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E202B)),
              ),
              const SizedBox(height: 2),
              const Text('System Default', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Ranked list container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: List.generate(displayedList.length, (idx) {
              final song = displayedList[idx];
              return InkWell(
                onTap: () => player.playSong(song, displayedList),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(song.coverUrl, width: 46, height: 46, fit: BoxFit.cover),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF1E202B)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${song.artist} • ${song.plays ?? "350k plays"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 18),

        // Pagination Pill: < 1 of 6 >
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pillLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded, size: 20, color: Color(0xFF374151)),
                SizedBox(width: 8),
                Text('1 of 6', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E202B))),
                SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF374151)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Trending Artists
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Trending Artists', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF1E202B))),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 140,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: [
              _buildArtistCard('1', 'Taylor Swift', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300'),
              _buildArtistCard('2', 'The Weeknd', 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=300'),
              _buildArtistCard('3', 'Morgan Wallen', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArtistCard(String rank, String name, String imageUrl) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                rank,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
