import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class RemoteGame {
  final String name;
  final String downloadUrl;
  Game? _cached;

  RemoteGame({required this.name, required this.downloadUrl});

  Future<Game?> load() async {
    if (_cached != null) return _cached;
    try {
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      _cached = Game.fromJson(json);
      return _cached;
    } catch (_) {
      return null;
    }
  }
}

class RemoteGamesService {
  static const _owner = 'alexandrejournet';
  static const _repo = 'score-games';
  static const _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/contents/';

  static List<RemoteGame>? _cachedList;

  static Future<List<RemoteGame>> fetchGames({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedList != null) return _cachedList!;

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) return [];

      final files = jsonDecode(response.body) as List;
      final games = <RemoteGame>[];

      for (final f in files) {
        final name = f['name'] as String;
        if (!name.endsWith('.json')) continue;
        final downloadUrl = f['download_url'] as String?;
        if (downloadUrl == null) continue;
        games.add(RemoteGame(
          name: name.replaceAll('.json', ''),
          downloadUrl: downloadUrl,
        ));
      }

      _cachedList = games;
      return games;
    } catch (_) {
      return _cachedList ?? [];
    }
  }

  static void clearCache() {
    _cachedList = null;
  }
}
