class Group {
  final String id;
  final String name;
  final List<String> playerIds;

  const Group({
    required this.id,
    required this.name,
    this.playerIds = const [],
  });

  Group copyWith({
    String? id,
    String? name,
    List<String>? playerIds,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      playerIds: playerIds ?? this.playerIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'playerIds': playerIds,
      };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        playerIds: List<String>.from(json['playerIds'] as List),
      );
}
