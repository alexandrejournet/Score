import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/data/repositories/player_repository.dart';
import 'package:score/core/models/player.dart';

void main() {
  group('PlayerRepository', () {
    late PlayerRepository repo;

    setUp(() {
      repo = PlayerRepository();
    });

    test('starts empty', () {
      expect(repo.all, isEmpty);
    });

    test('add adds a player', () {
      repo.add(const Player(id: 'p1', name: 'Alice'));
      expect(repo.all.length, 1);
      expect(repo.all.first.name, 'Alice');
    });

    test('getById returns correct player', () {
      repo.add(const Player(id: 'p1', name: 'Alice'));
      repo.add(const Player(id: 'p2', name: 'Bob'));

      final player = repo.getById('p2');
      expect(player, isNotNull);
      expect(player!.name, 'Bob');
    });

    test('getById returns null for unknown id', () {
      expect(repo.getById('unknown'), isNull);
    });

    test('update modifies player', () {
      repo.add(const Player(id: 'p1', name: 'Alice'));
      repo.update('p1', const Player(id: 'p1', name: 'Alicia'));

      expect(repo.getById('p1')!.name, 'Alicia');
    });

    test('remove deletes player', () {
      repo.add(const Player(id: 'p1', name: 'Alice'));
      repo.add(const Player(id: 'p2', name: 'Bob'));

      repo.remove('p1');
      expect(repo.all.length, 1);
      expect(repo.getById('p1'), isNull);
    });

    test('constructor with initial players', () {
      final repoWithPlayers = PlayerRepository(
        players: [
          const Player(id: 'p1', name: 'Alice'),
          const Player(id: 'p2', name: 'Bob'),
        ],
      );

      expect(repoWithPlayers.all.length, 2);
    });
  });
}
