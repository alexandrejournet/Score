import '../../models/player.dart';

class PlayerRepository {
  final List<Player> _players = [];

  List<Player> get all => List.unmodifiable(_players);

  PlayerRepository({List<Player>? players}) {
    if (players != null) _players.addAll(players);
  }

  Player? getById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Player player) {
    _players.add(player);
  }

  void update(String id, Player updated) {
    final idx = _players.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _players[idx] = updated;
    }
  }

  void remove(String id) {
    _players.removeWhere((p) => p.id == id);
  }
}
