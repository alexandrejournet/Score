import '../../models/game_played.dart';

class GamePlayedRepository {
  final List<GamePlayed> _games = [];

  List<GamePlayed> get all => List.unmodifiable(_games);

  GamePlayedRepository({List<GamePlayed>? gamePlayed}) {
    if (gamePlayed != null) {
      _games.addAll(gamePlayed);
      _games.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  List<GamePlayed> get active => _games
      .where((g) => g.status == GameStatus.inProgress || g.status == GameStatus.paused)
      .toList();

  List<GamePlayed> get finished =>
      _games.where((g) => g.status == GameStatus.finished).toList();

  GamePlayed? getById(String id) {
    try {
      return _games.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<GamePlayed> getByGameId(String gameId) {
    return _games.where((g) => g.gameId == gameId).toList();
  }

  void add(GamePlayed game) {
    _games.insert(0, game);
  }

  void update(String id, GamePlayed updated) {
    final idx = _games.indexWhere((g) => g.id == id);
    if (idx >= 0) {
      _games[idx] = updated;
    }
  }

  void remove(String id) {
    _games.removeWhere((g) => g.id == id);
  }
}
