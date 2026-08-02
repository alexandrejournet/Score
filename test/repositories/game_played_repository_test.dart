import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/data/repositories/game_played_repository.dart';
import 'package:score/core/models/game_played.dart';

void main() {
  group('GamePlayedRepository', () {
    late GamePlayedRepository repo;

    setUp(() {
      repo = GamePlayedRepository();
    });

    test('starts empty', () {
      expect(repo.all, isEmpty);
      expect(repo.active, isEmpty);
      expect(repo.finished, isEmpty);
    });

    test('add inserts at beginning', () {
      repo.add(GamePlayed(id: 'gp1', gameId: 'g1'));
      repo.add(GamePlayed(id: 'gp2', gameId: 'g1'));

      expect(repo.all.length, 2);
      expect(repo.all.first.id, 'gp2');
    });

    test('active returns in-progress and paused games', () {
      repo.add(GamePlayed(id: 'gp1', gameId: 'g1', status: GameStatus.inProgress));
      repo.add(GamePlayed(id: 'gp2', gameId: 'g1', status: GameStatus.finished));
      repo.add(GamePlayed(id: 'gp3', gameId: 'g1', status: GameStatus.paused));

      expect(repo.active.length, 2);
      expect(repo.active.map((g) => g.id), containsAll(['gp1', 'gp3']));
    });

    test('finished returns finished games', () {
      repo.add(GamePlayed(id: 'gp1', gameId: 'g1', status: GameStatus.inProgress));
      repo.add(GamePlayed(id: 'gp2', gameId: 'g1', status: GameStatus.finished));

      expect(repo.finished.length, 1);
      expect(repo.finished.first.id, 'gp2');
    });

    test('getById returns correct game', () {
      repo.add(GamePlayed(id: 'gp1', gameId: 'g1'));
      repo.add(GamePlayed(id: 'gp2', gameId: 'g2'));

      final gp = repo.getById('gp2');
      expect(gp, isNotNull);
      expect(gp!.gameId, 'g2');
    });

    test('getById returns null for unknown id', () {
      expect(repo.getById('unknown'), isNull);
    });

    test('getByGameId returns games for specific game', () {
      repo.add(GamePlayed(id: 'gp1', gameId: 'g1'));
      repo.add(GamePlayed(id: 'gp2', gameId: 'g2'));
      repo.add(GamePlayed(id: 'gp3', gameId: 'g1'));

      final results = repo.getByGameId('g1');
      expect(results.length, 2);
    });

    test('update modifies game', () {
      repo.add(GamePlayed(id: 'gp1', gameId: 'g1', status: GameStatus.inProgress));
      repo.update('gp1', GamePlayed(id: 'gp1', gameId: 'g1', status: GameStatus.finished));

      expect(repo.getById('gp1')!.status, GameStatus.finished);
    });

    test('remove deletes game', () {
      repo.add(GamePlayed(id: 'gp1', gameId: 'g1'));
      repo.add(GamePlayed(id: 'gp2', gameId: 'g1'));

      repo.remove('gp1');
      expect(repo.all.length, 1);
      expect(repo.getById('gp1'), isNull);
    });

    test('constructor with initial games sorts by date descending', () {
      final repoWithGames = GamePlayedRepository(
        gamePlayed: [
          GamePlayed(id: 'gp1', gameId: 'g1', date: DateTime(2026, 1, 1)),
          GamePlayed(id: 'gp2', gameId: 'g1', date: DateTime(2026, 6, 1)),
          GamePlayed(id: 'gp3', gameId: 'g1', date: DateTime(2026, 3, 1)),
        ],
      );

      expect(repoWithGames.all.first.id, 'gp2');
    });
  });
}
