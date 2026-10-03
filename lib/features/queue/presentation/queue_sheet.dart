import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../app/theme/colors.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerService>();
    final queue = player.queue;
    final current = player.currentSong;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF141622),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Now Playing Queue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.accentIndigo, borderRadius: BorderRadius.circular(10)),
                      child: Text('${queue.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.shuffle_rounded, color: player.isShuffle ? AppColors.accentIndigo : Colors.white54),
                  onPressed: player.toggleShuffle,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: queue.isEmpty
                ? const Center(child: Text("Queue is empty", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (ctx, idx) {
                      final item = queue[idx];
                      final isCurrent = current?.id == item.id;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.coverUrl, width: 44, height: 44, fit: BoxFit.cover),
                        ),
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrent ? AppColors.accentIndigo : Colors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          item.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                        ),
                        trailing: isCurrent
                            ? const Icon(Icons.graphic_eq_rounded, color: AppColors.accentIndigo)
                            : null,
                        onTap: () => player.playSong(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
