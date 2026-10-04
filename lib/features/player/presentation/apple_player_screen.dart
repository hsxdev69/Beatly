import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../shared/models/song.dart';
import '../../queue/presentation/queue_sheet.dart';

class ApplePlayerScreen extends StatefulWidget {
  const ApplePlayerScreen({super.key});

  @override
  State<ApplePlayerScreen> createState() => _ApplePlayerScreenState();
}

class _ApplePlayerScreenState extends State<ApplePlayerScreen> {
  bool _showLyrics = false;

  String _formatTime(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _openQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const QueueSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final song = player.currentSong;

    if (song == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("No track playing")));
    }

    final totalMs = player.duration.inMilliseconds.toDouble();
    final currentMs = player.position.inMilliseconds.toDouble().clamp(0.0, totalMs > 0 ? totalMs : 1.0);
    final isLiked = player.isFavorite(song.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Full Album Cover Image with Scrim
          Image.network(
            song.coverUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stackTrace) => Container(color: const Color(0xFF1E202B)),
          ),

          // Gradient scrim dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Player Foreground Content
          SafeArea(
            child: Column(
              children: [
                // Top Down Handle & Action Icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.queue_music_rounded, color: Colors.white, size: 24),
                            onPressed: () => _openQueue(context),
                          ),
                          IconButton(
                            icon: Icon(
                              _showLyrics ? Icons.music_note_rounded : Icons.lyrics_rounded,
                              color: _showLyrics ? const Color(0xFF60A5FA) : Colors.white,
                              size: 26,
                            ),
                            onPressed: () => setState(() => _showLyrics = !_showLyrics),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Lyrics or Main Artwork
                if (_showLyrics)
                  Expanded(
                    flex: 8,
                    child: _buildSynchronizedLyricsView(song, player.position),
                  )
                else
                  const SizedBox(height: 10),

                // Song Title, Artist & Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Three Dots frosted glass button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      // Heart frosted glass button
                      GestureDetector(
                        onTap: () => player.toggleFavorite(song.id),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isLiked ? const Color(0xFFF43F5E) : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Sleek iOS Scrubber Slider Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.24),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                        ),
                        child: Slider(
                          min: 0.0,
                          max: totalMs > 0 ? totalMs : 1.0,
                          value: currentMs,
                          onChanged: (val) => player.seek(Duration(milliseconds: val.toInt())),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(player.position),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              _formatTime(player.duration > Duration.zero ? player.duration : (song.duration ?? Duration.zero)),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (player.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12, left: 30, right: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      player.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),

                // Apple Big White Controls: |<<   ▶/❚❚   >>|
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fast_rewind_rounded, size: 48, color: Colors.white),
                        onPressed: player.prev,
                      ),
                      GestureDetector(
                        onTap: player.playPause,
                        child: player.isLoading
                            ? const SizedBox(
                                width: 56,
                                height: 56,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : Icon(
                                player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.fast_forward_rounded, size: 48, color: Colors.white),
                        onPressed: player.next,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynchronizedLyricsView(Song song, Duration currentPosition) {
    final lyrics = song.lyrics;
    if (lyrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lyrics_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              "Loading synchronized lyrics...",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      itemCount: lyrics.length,
      itemBuilder: (context, idx) {
        final line = lyrics[idx];
        final isActive = currentPosition >= line.time &&
            (idx == lyrics.length - 1 || currentPosition < lyrics[idx + 1].time);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            line.text,
            style: TextStyle(
              fontSize: isActive ? 24 : 18,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
              height: 1.3,
            ),
          ),
        );
      },
    );
  }
}
