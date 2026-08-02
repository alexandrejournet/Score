enum GameStatus { inProgress, paused, finished }

class ScoreEntry {
  final DateTime timestamp;
  final Map<String, int> scores;
  final Map<String, Map<String, int>>? categoryScores;
  final Map<String, Map<String, int>>? categoryMultipliers;

  const ScoreEntry({
    required this.timestamp,
    required this.scores,
    this.categoryScores,
    this.categoryMultipliers,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'scores': scores,
        if (categoryScores != null)
          'categoryScores': categoryScores!.map(
            (k, v) => MapEntry(k, v),
          ),
        if (categoryMultipliers != null)
          'categoryMultipliers': categoryMultipliers!.map(
            (k, v) => MapEntry(k, v),
          ),
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        scores: Map<String, int>.from(json['scores'] as Map),
        categoryScores: json['categoryScores'] != null
            ? (json['categoryScores'] as Map).map(
                (k, v) => MapEntry(k as String, Map<String, int>.from(v as Map)),
              )
            : null,
        categoryMultipliers: json['categoryMultipliers'] != null
            ? (json['categoryMultipliers'] as Map).map(
                (k, v) => MapEntry(k as String, Map<String, int>.from(v as Map)),
              )
            : null,
      );
}

class GamePlayed {
  final String id;
  final String gameId;
  final GameStatus status;
  final DateTime date;
  final Duration? duration;
  final List<String> playerIds;
  final Map<String, int> scores;
  final Map<String, Map<String, int>> categoryScores;
  final Map<String, Map<String, int>> categoryMultipliers;
  final String? winnerId;
  final List<ScoreEntry> history;

  GamePlayed({
    required this.id,
    required this.gameId,
    this.status = GameStatus.inProgress,
    DateTime? date,
    this.duration,
    this.playerIds = const [],
    this.scores = const {},
    this.categoryScores = const {},
    this.categoryMultipliers = const {},
    this.winnerId,
    this.history = const [],
  }) : date = date ?? DateTime.now();

  GamePlayed copyWith({
    String? id,
    String? gameId,
    GameStatus? status,
    DateTime? date,
    Duration? duration,
    List<String>? playerIds,
    Map<String, int>? scores,
    Map<String, Map<String, int>>? categoryScores,
    Map<String, Map<String, int>>? categoryMultipliers,
    String? winnerId,
    List<ScoreEntry>? history,
  }) {
    return GamePlayed(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      status: status ?? this.status,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      playerIds: playerIds ?? this.playerIds,
      scores: scores ?? this.scores,
      categoryScores: categoryScores ?? this.categoryScores,
      categoryMultipliers: categoryMultipliers ?? this.categoryMultipliers,
      winnerId: winnerId ?? this.winnerId,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'status': status.name,
        'date': date.toIso8601String(),
        'duration': duration?.inSeconds,
        'playerIds': playerIds,
        'scores': scores,
        'categoryScores': categoryScores.map(
          (k, v) => MapEntry(k, v),
        ),
        'categoryMultipliers': categoryMultipliers.map(
          (k, v) => MapEntry(k, v),
        ),
        'winnerId': winnerId,
        'history': history.map((e) => e.toJson()).toList(),
      };

  factory GamePlayed.fromJson(Map<String, dynamic> json) => GamePlayed(
        id: json['id'] as String,
        gameId: json['gameId'] as String,
        status: GameStatus.values.byName(json['status'] as String),
        date: DateTime.parse(json['date'] as String),
        duration: json['duration'] != null
            ? Duration(seconds: json['duration'] as int)
            : null,
        playerIds: List<String>.from(json['playerIds'] as List),
        scores: Map<String, int>.from(json['scores'] as Map),
        categoryScores: json['categoryScores'] != null
            ? (json['categoryScores'] as Map).map(
                (k, v) => MapEntry(k as String, Map<String, int>.from(v as Map)),
              )
            : {},
        categoryMultipliers: json['categoryMultipliers'] != null
            ? (json['categoryMultipliers'] as Map).map(
                (k, v) => MapEntry(k as String, Map<String, int>.from(v as Map)),
              )
            : {},
        winnerId: json['winnerId'] as String?,
        history: (json['history'] as List)
            .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
