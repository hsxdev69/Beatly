import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../app/theme/dimensions.dart';
import '../../../core/network/music_repository.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../shared/models/song.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/song_list_item.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isLoading = false;
  List<Song> _results = [];
  final List<String> _history = [
    'The Weeknd',
    'Coldplay',
    'Billie Eilish',
    'Taylor Swift',
    'Arijit Singh',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query, MusicRepository repo) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim(), repo);
    });
  }

  Future<void> _performSearch(String query, MusicRepository repo) async {
    setState(() => _isLoading = true);
    if (!_history.contains(query)) {
      _history.insert(0, query);
      if (_history.length > 10) _history.removeLast();
    }

    try {
      final songs = await repo.searchSongs(query);
      if (mounted) {
        setState(() {
          _results = songs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final player = context.watch<AudioPlayerService>();
    final currentSong = player.currentSong;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: GlassContainer(
                height: 52,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                color: AppColors.darkSurfaceVariant.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => _onQueryChanged(val, repo),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Search songs, artists, albums...',
                          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onQueryChanged('', repo);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: 8,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const ShimmerBox(width: 54, height: 54),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerBox(
                                    width: MediaQuery.of(context).size.width * 0.6,
                                    height: 14,
                                  ),
                                  const SizedBox(height: 8),
                                  ShimmerBox(
                                    width: MediaQuery.of(context).size.width * 0.35,
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _results.isNotEmpty
                      ? ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: AppDimensions.bottomNavTotalSpace),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final song = _results[index];
                            final isPlaying = currentSong?.id == song.id;

                            return SongListItem(
                              song: song,
                              isPlaying: isPlaying,
                              onTap: () => player.playSong(song, _results),
                              onFavoriteToggle: () => player.toggleFavorite(song.id),
                              onAddToQueue: () => player.addToQueue(song),
                            );
                          },
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Recent Searches', style: AppTypography.titleMedium),
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _history.map((term) {
                                  return GestureDetector(
                                    onTap: () {
                                      _searchController.text = term;
                                      _performSearch(term, repo);
                                    },
                                    child: Chip(
                                      backgroundColor: AppColors.darkSurfaceVariant,
                                      side: const BorderSide(color: AppColors.darkGlassBorder),
                                      label: Text(term, style: AppTypography.bodySmall),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
