import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/models/game.dart';
import 'package:flutter/material.dart';

void main() {
  group('Game', () {
    test('creates with required fields', () {
      const game = Game(id: 'test', name: 'Test Game');
      expect(game.id, 'test');
      expect(game.name, 'Test Game');
      expect(game.scoreType, ScoreType.points);
      expect(game.minPlayers, 1);
      expect(game.maxPlayers, 99);
      expect(game.isFavorite, false);
      expect(game.isCustom, false);
      expect(game.allowMultiSelect, false);
      expect(game.categories, isEmpty);
    });

    test('copyWith preserves unchanged fields', () {
      const game = Game(id: 'test', name: 'Test', color: Color(0xFF000000));
      final updated = game.copyWith(name: 'Updated');
      expect(updated.id, 'test');
      expect(updated.name, 'Updated');
      expect(updated.color, const Color(0xFF000000));
    });

    test('toJson and fromJson roundtrip', () {
      const game = Game(
        id: 'test',
        name: 'Test Game',
        scoreType: ScoreType.categories,
        minPlayers: 2,
        maxPlayers: 6,
        icon: '🎲',
        color: Color(0xFF3498DB),
        isFavorite: true,
        isCustom: true,
        allowMultiSelect: true,
        categories: [
          ScoringCategory(label: 'Score', description: 'Points', maxValue: 100, hasMultiplier: true),
        ],
        rules: 'Test rules',
      );

      final json = game.toJson();
      final restored = Game.fromJson(json);

      expect(restored.id, game.id);
      expect(restored.name, game.name);
      expect(restored.scoreType, game.scoreType);
      expect(restored.minPlayers, game.minPlayers);
      expect(restored.maxPlayers, game.maxPlayers);
      expect(restored.icon, game.icon);
      expect(restored.isFavorite, game.isFavorite);
      expect(restored.isCustom, game.isCustom);
      expect(restored.allowMultiSelect, game.allowMultiSelect);
      expect(restored.categories.length, 1);
      expect(restored.categories.first.label, 'Score');
      expect(restored.categories.first.hasMultiplier, true);
      expect(restored.rules, game.rules);
    });

    test('default values are correct', () {
      const game = Game(id: 'test', name: 'Test');
      expect(game.scoreType, ScoreType.points);
      expect(game.minPlayers, 1);
      expect(game.maxPlayers, 99);
      expect(game.isFavorite, false);
      expect(game.isCustom, false);
      expect(game.allowMultiSelect, false);
      expect(game.categories, isEmpty);
      expect(game.rules, isNull);
      expect(game.icon, isNull);
      expect(game.image, isNull);
    });
  });

  group('ScoringCategory', () {
    test('creates with defaults', () {
      const cat = ScoringCategory(label: 'Test');
      expect(cat.label, 'Test');
      expect(cat.description, isNull);
      expect(cat.maxValue, isNull);
      expect(cat.defaultValue, 0);
      expect(cat.hasMultiplier, false);
    });

    test('toJson and fromJson roundtrip', () {
      const cat = ScoringCategory(
        label: 'Plazas',
        description: 'Blue districts',
        maxValue: 99,
        defaultValue: 5,
        hasMultiplier: true,
      );

      final json = cat.toJson();
      final restored = ScoringCategory.fromJson(json);

      expect(restored.label, cat.label);
      expect(restored.description, cat.description);
      expect(restored.maxValue, cat.maxValue);
      expect(restored.defaultValue, cat.defaultValue);
      expect(restored.hasMultiplier, cat.hasMultiplier);
    });
  });
}
