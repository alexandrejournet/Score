import 'dart:ui';
import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  final String? avatar;
  final Color color;

  const Player({
    required this.id,
    required this.name,
    this.avatar,
    this.color = const Color(0xFF2E3A59),
  });

  Player copyWith({
    String? id,
    String? name,
    String? avatar,
    Color? color,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'color': color.toARGB32(),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
        color: Color(json['color'] as int),
      );
}
