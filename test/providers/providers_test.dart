import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/providers/app_providers.dart';

void main() {
  group('Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('allGamesProvider returns 4 default games', () {
      final games = container.read(allGamesProvider);
      expect(games.length, 4);
    });

    test('allPlayersProvider starts empty', () {
      final players = container.read(allPlayersProvider);
      expect(players, isEmpty);
    });

    test('allGroupsProvider starts empty', () {
      final groups = container.read(allGroupsProvider);
      expect(groups, isEmpty);
    });

    test('activeGamesProvider starts empty', () {
      final active = container.read(activeGamesProvider);
      expect(active, isEmpty);
    });

    test('finishedGamesProvider starts empty', () {
      final finished = container.read(finishedGamesProvider);
      expect(finished, isEmpty);
    });

    test('selectedTabProvider defaults to all', () {
      final tab = container.read(selectedTabProvider);
      expect(tab, 'all');
    });

    test('themeModeProvider defaults to light', () {
      final theme = container.read(themeModeProvider);
      expect(theme, ThemeMode.light);
    });
  });
}
