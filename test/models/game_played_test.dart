import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/models/game_played.dart';

void main() {
  group('GamePlayed', () {
    test('creates with defaults', () {
      final gp = GamePlayed(id: 'gp1', gameId: 'g1');
      expect(gp.id, 'gp1');
      expect(gp.gameId, 'g1');
      expect(gp.status, GameStatus.inProgress);
      expect(gp.playerIds, isEmpty);
      expect(gp.scores, isEmpty);
      expect(gp.categoryScores, isEmpty);
      expect(gp.categoryMultipliers, isEmpty);
      expect(gp.winnerId, isNull);
      expect(gp.history, isEmpty);
      expect(gp.duration, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final gp = GamePlayed(
        id: 'gp1',
        gameId: 'g1',
        playerIds: ['p1', 'p2'],
        scores: {'p1': 10, 'p2': 20},
      );

      final updated = gp.copyWith(status: GameStatus.finished, winnerId: 'p2');
      expect(updated.id, 'gp1');
      expect(updated.gameId, 'g1');
      expect(updated.status, GameStatus.finished);
      expect(updated.winnerId, 'p2');
      expect(updated.playerIds, ['p1', 'p2']);
      expect(updated.scores, {'p1': 10, 'p2': 20});
    });

    test('toJson and fromJson roundtrip', () {
      final gp = GamePlayed(
        id: 'gp1',
        gameId: 'g1',
        status: GameStatus.finished,
        playerIds: ['p1', 'p2'],
        scores: {'p1': 15, 'p2': 25},
        categoryScores: {
          'p1': {'cat1': 10, 'cat2': 5},
          'p2': {'cat1': 20, 'cat2': 5},
        },
        categoryMultipliers: {
          'p1': {'cat1': 1, 'cat2': 2},
          'p2': {'cat1': 1, 'cat2': 1},
        },
        winnerId: 'p2',
        duration: Duration(minutes: 30),
        history: [
          ScoreEntry(timestamp: DateTime(2026, 1, 1), scores: {'p1': 5, 'p2': 10}),
        ],
      );

      final json = gp.toJson();
      final restored = GamePlayed.fromJson(json);

      expect(restored.id, gp.id);
      expect(restored.gameId, gp.gameId);
      expect(restored.status, GameStatus.finished);
      expect(restored.playerIds, gp.playerIds);
      expect(restored.scores, gp.scores);
      expect(restored.categoryScores, gp.categoryScores);
      expect(restored.categoryMultipliers, gp.categoryMultipliers);
      expect(restored.winnerId, gp.winnerId);
      expect(restored.duration, gp.duration);
      expect(restored.history.length, 1);
    });
  });

  group('ScoreEntry', () {
    test('toJson and fromJson roundtrip', () {
      final entry = ScoreEntry(
        timestamp: DateTime(2026, 1, 1, 12, 0),
        scores: {'p1': 10, 'p2': 20},
        categoryScores: {'p1': {'cat1': 5}},
        categoryMultipliers: {'p1': {'cat1': 2}},
      );

      final json = entry.toJson();
      final restored = ScoreEntry.fromJson(json);

      expect(restored.timestamp, entry.timestamp);
      expect(restored.scores, entry.scores);
      expect(restored.categoryScores, entry.categoryScores);
      expect(restored.categoryMultipliers, entry.categoryMultipliers);
    });
  });
}
