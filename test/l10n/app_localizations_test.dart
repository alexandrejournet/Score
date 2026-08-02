import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppLocalizations', () {
    group('English', () {
      late AppLocalizations l10n;

      setUp(() {
        l10n = AppLocalizations(const Locale('en'));
      });

      test('appTitle returns SCORE', () {
        expect(l10n.appTitle, 'SCORE');
      });

      test('basic keys return English values', () {
        expect(l10n.dashboard, 'Dashboard');
        expect(l10n.games, 'Games');
        expect(l10n.players, 'Players');
        expect(l10n.settings, 'Settings');
        expect(l10n.newGame, 'New game');
        expect(l10n.launchGame, 'Launch game');
        expect(l10n.inProgress, 'In Progress');
        expect(l10n.recentHistory, 'Recent History');
        expect(l10n.cancel, 'Cancel');
        expect(l10n.add, 'Add');
        expect(l10n.remove, 'Remove');
        expect(l10n.finishGame, 'Finish game');
        expect(l10n.results, 'Results');
        expect(l10n.ranking, 'Ranking');
        expect(l10n.replay, 'Replay');
        expect(l10n.quit, 'Quit');
        expect(l10n.history, 'History');
        expect(l10n.darkMode, 'Dark mode');
        expect(l10n.statistics, 'Statistics');
        expect(l10n.groups, 'Groups');
        expect(l10n.myGames, 'My games');
        expect(l10n.bank, 'Game bank');
      });

      test('plural forms work correctly', () {
        expect(l10n.playersCount(0), 'No players');
        expect(l10n.playersCount(1), '1 player');
        expect(l10n.playersCount(5), '5 players');

        expect(l10n.gamesCount(0), 'No games');
        expect(l10n.gamesCount(1), '1 game');
        expect(l10n.gamesCount(3), '3 games');

        expect(l10n.groupsCount(0), 'No groups');
        expect(l10n.groupsCount(1), '1 group');
        expect(l10n.groupsCount(2), '2 groups');
      });

      test('playerRange returns correct format', () {
        expect(l10n.playerRange(2, 4), '2-4 players');
        expect(l10n.playerRange(3, 99), '3-99 players');
      });
    });

    group('French', () {
      late AppLocalizations l10n;

      setUp(() {
        l10n = AppLocalizations(const Locale('fr'));
      });

      test('basic keys return French values', () {
        expect(l10n.dashboard, 'Dashboard');
        expect(l10n.games, 'Jeux');
        expect(l10n.players, 'Joueurs');
        expect(l10n.settings, 'Réglages');
        expect(l10n.newGame, 'Nouvelle partie');
        expect(l10n.launchGame, 'Lancer la partie');
        expect(l10n.inProgress, 'En cours');
        expect(l10n.recentHistory, 'Parties récentes');
        expect(l10n.cancel, 'Annuler');
        expect(l10n.add, 'Ajouter');
        expect(l10n.remove, 'Retirer');
        expect(l10n.finishGame, 'Terminer la partie');
        expect(l10n.results, 'Résultats');
        expect(l10n.ranking, 'Classement');
        expect(l10n.replay, 'Rejouer');
        expect(l10n.quit, 'Quitter');
        expect(l10n.history, 'Historique');
        expect(l10n.darkMode, 'Thème sombre');
        expect(l10n.statistics, 'Statistiques');
        expect(l10n.groups, 'Groupes');
        expect(l10n.myGames, 'Mes jeux');
        expect(l10n.bank, 'Banque de jeux');
      });

      test('plural forms work correctly', () {
        expect(l10n.playersCount(0), 'Aucun joueur');
        expect(l10n.playersCount(1), '1 joueur');
        expect(l10n.playersCount(5), '5 joueurs');

        expect(l10n.gamesCount(0), 'Aucun jeu');
        expect(l10n.gamesCount(1), '1 jeu');
        expect(l10n.gamesCount(3), '3 jeux');

        expect(l10n.groupsCount(0), 'Aucun groupe');
        expect(l10n.groupsCount(1), '1 groupe');
        expect(l10n.groupsCount(2), '2 groupes');
      });

      test('playerRange returns correct format', () {
        expect(l10n.playerRange(2, 4), '2-4 joueurs');
      });

      test('scoring-related keys', () {
        expect(l10n.rules, 'Règles');
        expect(l10n.remainingKeys, 'Clés restantes');
        expect(l10n.total, 'Total');
        expect(l10n.pts, 'pts');
        expect(l10n.tie, 'Égalité !');
        expect(l10n.noLeader, 'Aucun');
      });
    });

    test('delegate supports en and fr', () {
      const delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('en')), true);
      expect(delegate.isSupported(const Locale('fr')), true);
      expect(delegate.isSupported(const Locale('de')), false);
      expect(delegate.isSupported(const Locale('es')), false);
    });
  });
}
