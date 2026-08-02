import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/models/player.dart';
import 'package:flutter/material.dart';

void main() {
  group('Player', () {
    test('creates with required fields', () {
      const player = Player(id: 'p1', name: 'Alice');
      expect(player.id, 'p1');
      expect(player.name, 'Alice');
      expect(player.avatar, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      const player = Player(id: 'p1', name: 'Alice', color: Color(0xFF000000));
      final updated = player.copyWith(name: 'Bob');
      expect(updated.id, 'p1');
      expect(updated.name, 'Bob');
      expect(updated.color, const Color(0xFF000000));
    });

    test('toJson and fromJson roundtrip', () {
      const player = Player(id: 'p1', name: 'Alice', avatar: 'avatar.png', color: Color(0xFF3498DB));

      final json = player.toJson();
      final restored = Player.fromJson(json);

      expect(restored.id, player.id);
      expect(restored.name, player.name);
      expect(restored.avatar, player.avatar);
    });
  });
}
