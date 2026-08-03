import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/data/repositories/game_repository.dart';
import 'package:score/core/models/game.dart';

void main() {
  group('GameRepository', () {
    late GameRepository repo;

    setUp(() {
      repo = GameRepository();
    });

    test('initializes with default games', () {
      expect(repo.builtIn.length, 6);
      expect(repo.builtIn.map((g) => g.id), containsAll(['flip7', 'mille-sabords', 'akropolis', 'chateau-combo', 'symbiose', 'skyjo']));
    });

    test('all returns built-in + custom games', () {
      repo.addCustom(const Game(id: 'custom1', name: 'Custom'));
      expect(repo.all.length, 7);
    });

    test('myGames returns all by default', () {
      expect(repo.myGames.length, 6);
    });

    test('bank returns empty by default (all games are in my games)', () {
      expect(repo.bank, isEmpty);
    });

    test('bank returns games not in my games', () {
      repo.removeFromMyGames('flip7');
      expect(repo.bank.length, 1);
      expect(repo.bank.first.id, 'flip7');
    });

    test('addToMyGames and removeFromMyGames', () {
      repo.removeFromMyGames('flip7');
      expect(repo.isInMyGames('flip7'), false);
      expect(repo.myGames.length, 5);

      repo.addToMyGames('flip7');
      expect(repo.isInMyGames('flip7'), true);
      expect(repo.myGames.length, 6);
    });

    test('getById returns correct game', () {
      final game = repo.getById('flip7');
      expect(game, isNotNull);
      expect(game!.name, 'Flip 7');
    });

    test('getById returns null for unknown id', () {
      expect(repo.getById('unknown'), isNull);
    });

    test('toggleFavorite changes favorite status', () {
      final game = repo.getById('flip7')!;
      expect(game.isFavorite, false);

      repo.toggleFavorite('flip7');
      expect(repo.getById('flip7')!.isFavorite, true);

      repo.toggleFavorite('flip7');
      expect(repo.getById('flip7')!.isFavorite, false);
    });

    test('addCustom adds to custom list', () {
      const custom = Game(id: 'my-game', name: 'My Game', isCustom: true);
      repo.addCustom(custom);
      expect(repo.custom.length, 1);
      expect(repo.getById('my-game'), isNotNull);
    });

    test('remove removes game', () {
      repo.addCustom(const Game(id: 'temp', name: 'Temp'));
      expect(repo.getById('temp'), isNotNull);

      repo.remove('temp');
      expect(repo.getById('temp'), isNull);
    });

    test('constructor with custom games and myGameIds', () {
      final customRepo = GameRepository(
        customGames: [const Game(id: 'c1', name: 'Custom')],
        myGameIds: {'flip7', 'c1'},
      );

      expect(customRepo.myGames.length, 2);
      expect(customRepo.bank.length, 5);
    });
  });
}
