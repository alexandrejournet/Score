import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('fr')];

  String get appTitle => 'SCORE';

  String get dashboard => _t('Dashboard', 'Dashboard');
  String get games => _t('Games', 'Jeux');
  String get players => _t('Players', 'Joueurs');
  String get settings => _t('Settings', 'Réglages');
  String get settingsSubtitle => _t(
        'Customize your gaming experience and manage your tabletop data.',
        'Personnalisez votre expérience de jeu et gérez vos données.',
      );
  String get general => _t('General', 'Général');
  String get data => _t('Data', 'Données');
  String get groups => _t('Groups', 'Groupes');
  String get statistics => _t('Statistics', 'Statistiques');
  String get darkMode => _t('Dark mode', 'Thème sombre');
  String get newGame => _t('New game', 'Nouvelle partie');
  String get launchGame => _t('Launch game', 'Lancer la partie');
  String get inProgress => _t('In Progress', 'En cours');
  String get recentHistory => _t('Recent History', 'Parties récentes');
  String get viewAll => _t('View all', 'Voir tout');
  String get viewLess => _t('View less', 'Voir moins');
  String get search => _t('Search...', 'Rechercher...');
  String get noResults => _t('No results', 'Aucun résultat');
  String get noGames => _t('No games', 'Aucune partie');
  String get startFirstGame => _t('Start your first game!', 'Lancez votre première partie !');
  String get game => _t('Game', 'Jeu');
  String get group => _t('Group', 'Groupe');
  String get create => _t('Create', 'Créer');
  String get none => _t('None', 'Aucun');
  String get addPlayer => _t('Add player', 'Ajouter un joueur');
  String get playerName => _t('Player name', 'Nom du joueur');
  String get cancel => _t('Cancel', 'Annuler');
  String get add => _t('Add', 'Ajouter');
  String get remove => _t('Remove', 'Retirer');
  String get resume => _t('Resume', 'Reprendre');
  String get pause => _t('Pause', 'Pause');
  String get finishGame => _t('Finish game', 'Terminer la partie');
  String get results => _t('Results', 'Résultats');
  String get ranking => _t('Ranking', 'Classement');
  String get leader => _t('Leader', 'Leader');
  String get noLeader => _t('None', 'Aucun');
  String get duration => _t('Duration', 'Durée');
  String get replay => _t('Replay', 'Rejouer');
  String get quit => _t('Quit', 'Quitter');
  String get history => _t('History', 'Historique');
  String get currentScore => _t('Current score', 'Score actuel');
  String get addPoints => _t('Add...', 'Ajouter...');
  String get undoLast => _t('Undo last', 'Annuler dernier');
  String get noChanges => _t('No changes', 'Aucun changement');
  String get select => _t('Select', 'Sélection');
  String get play => _t('Play', 'Jouer');
  String get total => _t('Total', 'Total');
  String get pts => _t('pts', 'pts');
  String get remainingKeys => _t('Keys remaining', 'Clés restantes');
  String get tryAnotherTerm => _t('Try another term', 'Essayez un autre terme');
  String get partiesPlayed => _t('Games played', 'Parties jouées');
  String get playTime => _t('Play time', 'Temps de jeu');
  String get mostPlayedGames => _t('Most played games', 'Jeux les plus joués');
  String get playersStats => _t('Players', 'Joueurs');
  String get partieWord => _t('game(s)', 'partie(s)');
  String get victoryWord => _t('win(s)', 'victoire(s)');
  String get gridLabel => _t('Grid', 'Grille');
  String get selectGameFirst => _t('Select a game first', "Sélectionnez d'abord un jeu");
  String get createGroupHint =>
      _t('Create a group in Settings to pre-fill players', 'Créez un groupe depuis les réglages pour pré-remplir les joueurs');
  String get sessionNotFound => _t('Game not found', 'Partie introuvable');
  String get noPlayStats => _t('Play a few games to see your stats!', 'Jouez quelques parties pour voir vos stats !');
  String get gameName => _t('Game name', 'Nom du jeu');
  String get groupName => _t('Group name', 'Nom du groupe');
  String get tie => _t('Tie!', 'Égalité !');
  String get rules => _t('Rules', 'Règles');
  String get scoring => _t('Scoring', 'Scoring');
  String get myGames => _t('My games', 'Mes jeux');
  String get bank => _t('Game bank', 'Banque de jeux');
  String get gamesSubtitle => _t('Browse and manage your game collection.', 'Parcourez et gérez votre collection de jeux.');
  String get playersSubtitle => _t('Create and manage your tabletop players.', 'Créez et gérez vos joueurs de jeux de société.');
  String get updateAvailable => _t('Update available', 'Mise à jour disponible');
  String get updateMessage => _t('A new version is available. Would you like to update?', 'Une nouvelle version est disponible. Voulez-vous mettre à jour ?');
  String get update => _t('Update', 'Mettre à jour');
  String get later => _t('Later', 'Plus tard');
  String get roundScore => _t('Round score', 'Score de la manche');
  String get cumulativeScore => _t('Cumulative score', 'Score cumulé');
  String get validateRound => _t('Validate round', 'Valider la manche');
  String get roundEndedBy => _t('Round ended by', 'Fin de manche déclenchée par');
  String get noFinisher => _t('Select who ended the round', 'Sélectionnez le joueur qui a terminé la manche');
  String get roundHistory => _t('Round history', 'Historique des manches');
  String get roundNumber => _t('Round', 'Manche');
  String get gameOver => _t('Game over', 'Fin de partie');
  String get winner => _t('Winner', 'Vainqueur');
  String get version => 'SCORE v1.0.0';

  String get advancedScoring => _t('Advanced scoring', 'Variantes avancées');
  String get advancedScoringDescription => _t(
        'Enable conditional ×2 multipliers for each district',
        'Activer les multiplicateurs ×2 conditionnels pour chaque quartier',
      );
  String get checkForUpdates => _t('Check for updates', 'Vérifier les mises à jour');
  String get checkingForUpdates => _t('Checking...', 'Vérification...');
  String get upToDate => _t('You are up to date!', 'Vous êtes à jour !');
  String get updateCheckFailed => _t('Could not check for updates', 'Impossible de vérifier les mises à jour');
  String get createGame => _t('Create a game', 'Créer un jeu');
  String get remote => _t('Game bank', 'Banque de jeux');
  String get noRemoteGames => _t('No remote games found', 'Aucun jeu distant trouvé');
  String get scoreTypeLabel => _t('Score type', 'Type de score');
  String get points => _t('Points', 'Points');
  String get categories => _t('Categories', 'Catégories');
  String get minPlayers => _t('Min', 'Min');
  String get maxPlayers => _t('Max', 'Max');
  String get colorLabel => _t('Color', 'Couleur');
  String get icon => _t('Icon', 'Icône');
  String get confirmDeletePlayer => _t('Delete this player?', 'Supprimer ce joueur ?');
  String get confirmDeletePlayerMsg => _t('This action cannot be undone. All their scores and history will be lost.', 'Cette action est irréversible. Tous ses scores et son historique seront perdus.');
  String get confirmDeleteGroup => _t('Delete this group?', 'Supprimer ce groupe ?');
  String get confirmDeleteGroupMsg => _t('The group will be deleted but players will be kept.', 'Le groupe sera supprimé mais les joueurs seront conservés.');
  String get confirmDeleteGame => _t('Delete this game?', 'Supprimer ce jeu ?');
  String get confirmDeleteGameMsg => _t('The custom game will be permanently removed.', 'Le jeu personnalisé sera définitivement supprimé.');
  String get confirmDeleteHistory => _t('Delete this entry?', 'Supprimer cette entrée ?');
  String get confirmDeleteHistoryMsg => _t('This history entry will be permanently removed.', 'Cette entrée d\'historique sera définitivement supprimée.');
  String get delete => _t('Delete', 'Supprimer');

  String playerRange(int min, int max) {
    final range = '$min-$max';
    if (locale.languageCode == 'fr') return '$range joueurs';
    return '$range players';
  }

  String playersCount(int count) {
    if (locale.languageCode == 'fr') {
      if (count == 0) return 'Aucun joueur';
      if (count == 1) return '1 joueur';
      return '$count joueurs';
    }
    if (count == 0) return 'No players';
    if (count == 1) return '1 player';
    return '$count players';
  }

  String gamesCount(int count) {
    if (locale.languageCode == 'fr') {
      if (count == 0) return 'Aucun jeu';
      if (count == 1) return '1 jeu';
      return '$count jeux';
    }
    if (count == 0) return 'No games';
    if (count == 1) return '1 game';
    return '$count games';
  }

  String groupsCount(int count) {
    if (locale.languageCode == 'fr') {
      if (count == 0) return 'Aucun groupe';
      if (count == 1) return '1 groupe';
      return '$count groupes';
    }
    if (count == 0) return 'No groups';
    if (count == 1) return '1 group';
    return '$count groups';
  }

  String _t(String en, String fr) {
    return locale.languageCode == 'fr' ? fr : en;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
