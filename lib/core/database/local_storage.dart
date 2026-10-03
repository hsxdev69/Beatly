import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/song.dart';

class LocalStorage {
  static const String _keyFavorites = 'echo_favorites';
  static const String _keyHistory = 'echo_history';
  static const String _keyPlayerStyle = 'echo_player_style'; // 'apple' or 'material'

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  Set<String> getFavoriteIds() {
    final list = _prefs.getStringList(_keyFavorites) ?? ['khalasi', 'gtavi', 'vaaroon'];
    return list.toSet();
  }

  Future<void> toggleFavorite(String songId) async {
    final favs = getFavoriteIds();
    if (favs.contains(songId)) {
      favs.remove(songId);
    } else {
      favs.add(songId);
    }
    await _prefs.setStringList(_keyFavorites, favs.toList());
  }

  List<Song> getRecentlyPlayed() {
    final jsonStr = _prefs.getString(_keyHistory);
    if (jsonStr == null) return [];
    try {
      final List list = json.decode(jsonStr);
      return list.map((item) => Song.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addRecentlyPlayed(Song song) async {
    final list = getRecentlyPlayed();
    list.removeWhere((s) => s.id == song.id);
    list.insert(0, song);
    if (list.length > 50) list.removeLast();
    await _prefs.setString(_keyHistory, json.encode(list.map((s) => s.toJson()).toList()));
  }

  String getPlayerStyle() {
    return _prefs.getString(_keyPlayerStyle) ?? 'apple';
  }

  Future<void> setPlayerStyle(String style) async {
    await _prefs.setString(_keyPlayerStyle, style);
  }
}
