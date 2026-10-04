import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../app/theme/colors.dart';
import 'apple_player_screen.dart';

class FloatingDockAndMiniPlayer extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingDockAndMiniPlayer({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  void _openFullPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => const ApplePlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final song = player.currentSong;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Mini Player Pill
          if (song != null)
            GestureDetector(
              onTap: () => _openFullPlayer(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            song.coverUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                              ),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        if (player.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111827)),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(
                              player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: const Color(0xFF111827),
                              size: 26,
                            ),
                            onPressed: player.playPause,
                          ),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, color: Color(0xFF111827), size: 26),
                          onPressed: player.next,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Liquid Glass Apple Floating Dock
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home Capsule Button
                    GestureDetector(
                      onTap: () => onTabSelected(0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: activeIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: activeIndex == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.home_filled, size: 20, color: Color(0xFF111827)),
                            SizedBox(width: 6),
                            Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                          ],
                        ),
                      ),
                    ),

                    // Mic Icon
                    IconButton(
                      icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF374151), size: 22),
                      onPressed: () {},
                    ),

                    // Library Note Card Icon
                    IconButton(
                      icon: Icon(
                        activeIndex == 2 ? Icons.library_music_rounded : Icons.library_music_outlined,
                        color: const Color(0xFF374151),
                        size: 22,
                      ),
                      onPressed: () => onTabSelected(2),
                    ),

                    // Floating Search Round Button
                    GestureDetector(
                      onTap: () => onTabSelected(1),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeIndex == 1 ? const Color(0xFF1E202B) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: activeIndex == 1 ? Colors.white : const Color(0xFF111827),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
