import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../models/group.dart';
import '../models/game_played.dart';
import '../data/repositories/game_repository.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/group_repository.dart';
import '../data/repositories/game_played_repository.dart';

import '../services/persistence_service.dart';

const _uuid = Uuid();

final themeModeProvider = StateProvider<ThemeMode>((ref) => PersistenceService.loadThemeMode());
final hapticEnabledProvider = StateProvider<bool>((ref) => PersistenceService.loadHapticEnabled());
final gameDataVersionProvider = StateProvider<int>((ref) => 0);

void bumpGameVersion(WidgetRef ref) {
  ref.read(gameDataVersionProvider.notifier).state++;
}

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepository(
    customGames: PersistenceService.loadCustomGames(),
    myGameIds: PersistenceService.loadMyGameIds(),
  ),
);
final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => PlayerRepository(players: PersistenceService.loadPlayers()),
);
final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => GroupRepository(groups: PersistenceService.loadGroups()),
);
final gamePlayedRepositoryProvider = Provider<GamePlayedRepository>(
  (ref) => GamePlayedRepository(gamePlayed: PersistenceService.loadGamePlayed()),
);

final allGamesProvider = Provider<List<Game>>((ref) {
  ref.watch(gameDataVersionProvider);
  return ref.read(gameRepositoryProvider).all;
});

final myGamesProvider = Provider<List<Game>>((ref) {
  ref.watch(gameDataVersionProvider);
  return ref.read(gameRepositoryProvider).myGames;
});

final gameBankProvider = Provider<List<Game>>((ref) {
  ref.watch(gameDataVersionProvider);
  return ref.read(gameRepositoryProvider).bank;
});

final allPlayersProvider = Provider<List<Player>>((ref) {
  ref.watch(gameDataVersionProvider);
  return ref.read(playerRepositoryProvider).all;
});

final allGroupsProvider = Provider<List<Group>>((ref) {
  ref.watch(gameDataVersionProvider);
  return ref.read(groupRepositoryProvider).all;
});

final activeGamesProvider = Provider<List<GamePlayed>>((ref) {
  ref.watch(gameDataVersionProvider);
  return ref.read(gamePlayedRepositoryProvider).active;
});

final finishedGamesProvider = Provider<List<GamePlayed>>((ref) {
  ref.watch(gameDataVersionProvider);
  return ref.read(gamePlayedRepositoryProvider).finished;
});

final selectedTabProvider = StateProvider<String>((ref) => 'all');

final gamesByTabProvider = Provider<List<GamePlayed>>((ref) {
  final tab = ref.watch(selectedTabProvider);
  ref.watch(gameDataVersionProvider);
  final all = ref.read(gamePlayedRepositoryProvider).all;
  if (tab == 'all') return all;
  return all.where((g) => g.gameId == tab).toList();
});

void _saveData(WidgetRef ref) {
  final repo = ref.read(gameRepositoryProvider);
  PersistenceService.saveAll(
    customGames: repo.custom,
    players: ref.read(playerRepositoryProvider).all,
    groups: ref.read(groupRepositoryProvider).all,
    gamePlayed: ref.read(gamePlayedRepositoryProvider).all,
    myGameIds: repo.myGames.map((g) => g.id).toSet(),
  );
}

void addGame(WidgetRef ref, Game game) {
  ref.read(gameRepositoryProvider).addCustom(game);
  ref.invalidate(allGamesProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

void addPlayer(WidgetRef ref, Player player) {
  ref.read(playerRepositoryProvider).add(player);
  ref.invalidate(allPlayersProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

void addGroup(WidgetRef ref, Group group) {
  ref.read(groupRepositoryProvider).add(group);
  ref.invalidate(allGroupsProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

String startGame(WidgetRef ref, String gameId, List<String> playerIds, {bool advancedScoring = false}) {
  final game = ref.read(gameRepositoryProvider).getById(gameId);
  final categoryScores = <String, Map<String, int>>{};
  final categoryMultipliers = <String, Map<String, int>>{};

  if (game != null && game.scoreType == ScoreType.categories) {
    for (final pid in playerIds) {
      categoryScores[pid] = {};
      categoryMultipliers[pid] = {};
      for (final cat in game.categories) {
        categoryScores[pid]![cat.label] = cat.defaultValue ?? 0;
        categoryMultipliers[pid]![cat.label] = cat.hasMultiplier ? 1 : 1;
      }
    }
  }

  final gamePlayed = GamePlayed(
    id: _uuid.v4(),
    gameId: gameId,
    status: GameStatus.inProgress,
    playerIds: playerIds,
    scores: {for (var id in playerIds) id: 0},
    categoryScores: categoryScores,
    categoryMultipliers: categoryMultipliers,
    advancedScoringEnabled: advancedScoring,
  );
  ref.read(gamePlayedRepositoryProvider).add(gamePlayed);
  ref.invalidate(activeGamesProvider);
  ref.invalidate(gamesByTabProvider);
  bumpGameVersion(ref);
  _saveData(ref);
  return gamePlayed.id;
}

void updateScore(WidgetRef ref, String gamePlayedId, String playerId, int delta) {
  final repo = ref.read(gamePlayedRepositoryProvider);
  final game = repo.getById(gamePlayedId);
  if (game == null) return;

  final newScores = Map<String, int>.from(game.scores);
  newScores[playerId] = (newScores[playerId] ?? 0) + delta;

  final entry = ScoreEntry(
    timestamp: DateTime.now(),
    scores: Map<String, int>.from(newScores),
  );

  repo.update(
    gamePlayedId,
    game.copyWith(
      scores: newScores,
      history: [...game.history, entry],
    ),
  );
  ref.invalidate(activeGamesProvider);
  ref.invalidate(gamesByTabProvider);
  bumpGameVersion(ref);
  _saveData(ref);

  final games = ref.read(allGamesProvider);
  final g = games.where((g) => g.id == game.gameId).firstOrNull;
  final endScore = g?.endScore;
  if (endScore != null && newScores.values.any((s) => s >= endScore)) {
    finishGame(ref, gamePlayedId);
  }
}

void finishGame(WidgetRef ref, String gamePlayedId) {
  final repo = ref.read(gamePlayedRepositoryProvider);
  final game = repo.getById(gamePlayedId);
  if (game == null) return;

  final finishTime = DateTime.now();

  String? winner;
  int highestScore = -1;
  game.scores.forEach((playerId, score) {
    if (score > highestScore) {
      highestScore = score;
      winner = playerId;
    } else if (score == highestScore) {
      winner = null;
    }
  });

  repo.update(
    gamePlayedId,
    game.copyWith(
      status: GameStatus.finished,
      duration: finishTime.difference(game.date),
      winnerId: winner,
    ),
  );
  ref.invalidate(activeGamesProvider);
  ref.invalidate(gamesByTabProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

bool validateSkyjoRound(
  WidgetRef ref,
  String gamePlayedId,
  Map<String, int> roundScores,
  String finisherId,
) {
  final repo = ref.read(gamePlayedRepositoryProvider);
  final gamePlayed = repo.getById(gamePlayedId);
  if (gamePlayed == null) return false;

  final lowest = roundScores.values.reduce((a, b) => a < b ? a : b);
  final appliedScores = Map<String, int>.from(roundScores);
  if (gamePlayedId.isNotEmpty && finisherId.isNotEmpty) {
    final finisherScore = appliedScores[finisherId];
    if (finisherScore != null && finisherScore > lowest) {
      appliedScores[finisherId] = finisherScore * 2;
    }
  }

  final totals = Map<String, int>.from(gamePlayed.scores);
  for (final entry in appliedScores.entries) {
    totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
  }

  final rounds = [
    ...gamePlayed.rounds,
    RoundScore(
      date: DateTime.now(),
      scores: appliedScores,
      finisherId: finisherId,
    ),
  ];
  final history = [
    ...gamePlayed.history,
    ScoreEntry(timestamp: DateTime.now(), scores: Map<String, int>.from(totals)),
  ];
  final reachedLimit = totals.values.any((score) => score >= 100);
  String? winnerId;
  if (reachedLimit) {
    winnerId = totals.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
  }

  repo.update(
    gamePlayedId,
    gamePlayed.copyWith(
      scores: totals,
      rounds: rounds,
      history: history,
      status: reachedLimit ? GameStatus.finished : GameStatus.inProgress,
      winnerId: winnerId,
    ),
  );
  ref.invalidate(activeGamesProvider);
  ref.invalidate(finishedGamesProvider);
  ref.invalidate(gamesByTabProvider);
  bumpGameVersion(ref);
  _saveData(ref);
  return reachedLimit;
}

void removeHistoryEntry(WidgetRef ref, String gamePlayedId) {
  ref.read(gamePlayedRepositoryProvider).remove(gamePlayedId);
  ref.invalidate(gamesByTabProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

void deletePlayer(WidgetRef ref, String id) {
  ref.read(playerRepositoryProvider).remove(id);
  ref.invalidate(allPlayersProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

void deleteGame(WidgetRef ref, String id) {
  ref.read(gameRepositoryProvider).remove(id);
  ref.invalidate(allGamesProvider);
  ref.invalidate(gamesByTabProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

void deleteGroup(WidgetRef ref, String id) {
  ref.read(groupRepositoryProvider).remove(id);
  ref.invalidate(allGroupsProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

void addToMyGames(WidgetRef ref, String id) {
  ref.read(gameRepositoryProvider).addToMyGames(id);
  ref.invalidate(allGamesProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

void removeFromMyGames(WidgetRef ref, String id) {
  ref.read(gameRepositoryProvider).removeFromMyGames(id);
  ref.invalidate(allGamesProvider);
  bumpGameVersion(ref);
  _saveData(ref);
}

Future<void> saveTheme(WidgetRef ref, ThemeMode mode) async {
  await PersistenceService.saveThemeMode(mode);
}
