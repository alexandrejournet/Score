import 'dart:ui';
import 'package:flutter/material.dart';

enum ScoreType { points, time, custom, categories, rounds }

class ScoringCategory {
  final String label;
  final String? description;
  final int? maxValue;
  final int? defaultValue;
  final bool hasMultiplier;

  const ScoringCategory({
    required this.label,
    this.description,
    this.maxValue,
    this.defaultValue = 0,
    this.hasMultiplier = false,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'description': description,
        'maxValue': maxValue,
        'defaultValue': defaultValue,
        'hasMultiplier': hasMultiplier,
      };

  factory ScoringCategory.fromJson(Map<String, dynamic> json) => ScoringCategory(
        label: json['label'] as String,
        description: json['description'] as String?,
        maxValue: json['maxValue'] as int?,
        defaultValue: json['defaultValue'] as int? ?? 0,
        hasMultiplier: json['hasMultiplier'] as bool? ?? false,
      );
}

class Game {
  final String id;
  final String name;
  final ScoreType scoreType;
  final int minPlayers;
  final int maxPlayers;
  final String? icon;
  final Color color;
  final String? image;
  final bool isFavorite;
  final bool isCustom;
  final bool allowMultiSelect;
  final List<ScoringCategory> categories;
  final String? rules;
  final int? endScore;
  final bool lowerScoreWins;
  final bool doubleFinisherIfNotLowest;
  final bool hasAdvancedScoring;

  const Game({
    required this.id,
    required this.name,
    this.scoreType = ScoreType.points,
    this.minPlayers = 1,
    this.maxPlayers = 99,
    this.icon,
    this.color = const Color(0xFF2E3A59),
    this.image,
    this.isFavorite = false,
    this.isCustom = false,
    this.allowMultiSelect = false,
    this.categories = const [],
    this.rules,
    this.endScore,
    this.lowerScoreWins = false,
    this.doubleFinisherIfNotLowest = false,
    this.hasAdvancedScoring = false,
  });

  Game copyWith({
    String? id,
    String? name,
    ScoreType? scoreType,
    int? minPlayers,
    int? maxPlayers,
    String? icon,
    Color? color,
    String? image,
    bool? isFavorite,
    bool? isCustom,
    bool? allowMultiSelect,
    List<ScoringCategory>? categories,
    String? rules,
    int? endScore,
    bool? lowerScoreWins,
    bool? doubleFinisherIfNotLowest,
    bool? hasAdvancedScoring,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      scoreType: scoreType ?? this.scoreType,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
      allowMultiSelect: allowMultiSelect ?? this.allowMultiSelect,
      categories: categories ?? this.categories,
      rules: rules ?? this.rules,
      endScore: endScore ?? this.endScore,
      lowerScoreWins: lowerScoreWins ?? this.lowerScoreWins,
      doubleFinisherIfNotLowest: doubleFinisherIfNotLowest ?? this.doubleFinisherIfNotLowest,
      hasAdvancedScoring: hasAdvancedScoring ?? this.hasAdvancedScoring,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scoreType': scoreType.name,
        'minPlayers': minPlayers,
        'maxPlayers': maxPlayers,
        'icon': icon,
        'color': color.toARGB32(),
        'image': image,
        'isFavorite': isFavorite,
        'isCustom': isCustom,
        'allowMultiSelect': allowMultiSelect,
        'categories': categories.map((c) => c.toJson()).toList(),
        'rules': rules,
        'endScore': endScore,
        'lowerScoreWins': lowerScoreWins,
        'doubleFinisherIfNotLowest': doubleFinisherIfNotLowest,
        'hasAdvancedScoring': hasAdvancedScoring,
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as String,
        name: json['name'] as String,
        scoreType: ScoreType.values.byName(json['scoreType'] as String),
        minPlayers: json['minPlayers'] as int? ?? 1,
        maxPlayers: json['maxPlayers'] as int? ?? 99,
        icon: json['icon'] as String?,
        color: Color(json['color'] as int),
        image: json['image'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
        isCustom: json['isCustom'] as bool? ?? false,
        allowMultiSelect: json['allowMultiSelect'] as bool? ?? false,
        categories: json['categories'] != null
            ? (json['categories'] as List)
                .map((c) => ScoringCategory.fromJson(c as Map<String, dynamic>))
                .toList()
            : [],
        rules: json['rules'] as String?,
        endScore: json['endScore'] as int?,
        lowerScoreWins: json['lowerScoreWins'] as bool? ?? false,
        doubleFinisherIfNotLowest: json['doubleFinisherIfNotLowest'] as bool? ?? false,
        hasAdvancedScoring: json['hasAdvancedScoring'] as bool? ?? false,
      );
}
