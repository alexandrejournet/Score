import 'package:flutter/material.dart';
import '../../models/game.dart';

final defaultGames = [
  Game(
    id: 'flip7',
    name: 'Flip 7',
    minPlayers: 2,
    maxPlayers: 99,
    color: const Color(0xFFE74C3C),
    icon: '🃏',
    scoreType: ScoreType.points,
    rules: 'Piochez des cartes une par une. Si vous piochez un doublon, vous perdez tout. Score = total des cartes piochées.',
  ),
  Game(
    id: 'mille-sabords',
    name: 'Mille Sabords',
    minPlayers: 2,
    maxPlayers: 6,
    color: const Color(0xFF1A5276),
    icon: '🏴‍☠️',
    scoreType: ScoreType.points,
    allowMultiSelect: true,
    rules: 'Jeu de dés. Ajoutez ou retirez des points à un ou plusieurs joueurs à la fois.',
  ),
  Game(
    id: 'akropolis',
    name: 'Akropolis',
    minPlayers: 2,
    maxPlayers: 4,
    color: const Color(0xFFD4A574),
    icon: '🏛️',
    scoreType: ScoreType.categories,
    categories: const [
      ScoringCategory(label: 'Plazas', description: 'Quartiers bleus', maxValue: 99, hasMultiplier: true),
      ScoringCategory(label: 'Jardins', description: 'Quartiers verts', maxValue: 99, hasMultiplier: true),
      ScoringCategory(label: 'Caserne', description: 'Quartiers rouges', maxValue: 99, hasMultiplier: true),
      ScoringCategory(label: 'Temple', description: 'Quartiers violets', maxValue: 99, hasMultiplier: true),
      ScoringCategory(label: 'Marché', description: 'Quartiers jaunes', maxValue: 99, hasMultiplier: true),
      ScoringCategory(label: 'Bonus architectes', description: 'Tuiles spéciales', maxValue: 50),
    ],
    rules: 'Construisez votre cité en 3D. Chaque quartier score selon sa hauteur et sa position.',
    hasAdvancedScoring: true,
  ),
  Game(
    id: 'chateau-combo',
    name: 'Château Combo',
    minPlayers: 2,
    maxPlayers: 5,
    color: const Color(0xFF8E44AD),
    icon: '🏰',
    scoreType: ScoreType.categories,
    categories: const [
      ScoringCategory(label: 'Carte 1,1'),
      ScoringCategory(label: 'Carte 1,2'),
      ScoringCategory(label: 'Carte 1,3'),
      ScoringCategory(label: 'Carte 2,1'),
      ScoringCategory(label: 'Carte 2,2'),
      ScoringCategory(label: 'Carte 2,3'),
      ScoringCategory(label: 'Carte 3,1'),
      ScoringCategory(label: 'Carte 3,2'),
      ScoringCategory(label: 'Carte 3,3'),
      ScoringCategory(label: 'Clés restantes', description: 'Nombre de clés'),
    ],
    rules: 'Draftez des cartes pour remplir une grille 3×3. Score = somme des PV des cartes + clés restantes.',
  ),
  Game(
    id: 'symbiose',
    name: 'Symbiose',
    minPlayers: 2,
    maxPlayers: 4,
    color: const Color(0xFF43A047),
    icon: '🐸',
    scoreType: ScoreType.categories,
    categories: const [
      ScoringCategory(label: 'Carte 1,1'),
      ScoringCategory(label: 'Carte 1,2'),
      ScoringCategory(label: 'Carte 1,3'),
      ScoringCategory(label: 'Carte 1,4'),
      ScoringCategory(label: 'Carte 2,1'),
      ScoringCategory(label: 'Carte 2,2'),
      ScoringCategory(label: 'Carte 2,3'),
      ScoringCategory(label: 'Carte 2,4'),
    ],
    rules: 'Construisez votre mare et composez un écosystème équilibré. Le score final correspond à la somme des points des 8 cartes.',
  ),
  Game(
    id: 'skyjo',
    name: 'Skyjo',
    minPlayers: 2,
    maxPlayers: 8,
    color: const Color(0xFF1565C0),
    icon: '🃏',
    scoreType: ScoreType.rounds,
    endScore: 100,
    lowerScoreWins: true,
    doubleFinisherIfNotLowest: true,
    rules: 'Additionnez les scores de chaque manche. La partie se termine dès qu’un joueur atteint 100 points ou plus. Le joueur avec le plus petit score gagne.',
  ),
];

class GameRepository {
  final List<Game> _games = [];
  final List<Game> _customGames = [];
  final Set<String> _myGameIds = {};

  List<Game> get all => [..._games, ..._customGames];
  List<Game> get builtIn => List.unmodifiable(_games);
  List<Game> get custom => List.unmodifiable(_customGames);
  List<Game> get myGames => all.where((g) => _myGameIds.contains(g.id)).toList();
  List<Game> get bank => builtIn.where((g) => !_myGameIds.contains(g.id)).toList();
  List<Game> get favorites => all.where((g) => g.isFavorite).toList();
  bool isInMyGames(String id) => _myGameIds.contains(id);

  GameRepository({List<Game>? customGames, Set<String>? myGameIds}) {
    _games.addAll(defaultGames);
    if (customGames != null) _customGames.addAll(customGames);
    if (myGameIds != null) {
      _myGameIds.addAll(myGameIds);
    } else {
      _myGameIds.addAll(defaultGames.map((g) => g.id));
    }
  }

  void addToMyGames(String id) {
    _myGameIds.add(id);
  }

  void removeFromMyGames(String id) {
    _myGameIds.remove(id);
  }

  Game? getById(String id) {
    try {
      return all.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void addCustom(Game game) {
    _customGames.add(game);
  }

  void update(String id, Game updated) {
    final builtInIdx = _games.indexWhere((g) => g.id == id);
    if (builtInIdx >= 0) {
      _games[builtInIdx] = updated;
      return;
    }
    final customIdx = _customGames.indexWhere((g) => g.id == id);
    if (customIdx >= 0) {
      _customGames[customIdx] = updated;
    }
  }

  void remove(String id) {
    _games.removeWhere((g) => g.id == id);
    _customGames.removeWhere((g) => g.id == id);
  }

  void toggleFavorite(String id) {
    final game = getById(id);
    if (game != null) {
      update(id, game.copyWith(isFavorite: !game.isFavorite));
    }
  }
}
