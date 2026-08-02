import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/models/group.dart';

void main() {
  group('Group', () {
    test('creates with required fields', () {
      const group = Group(id: 'g1', name: 'Family');
      expect(group.id, 'g1');
      expect(group.name, 'Family');
      expect(group.playerIds, isEmpty);
    });

    test('copyWith preserves unchanged fields', () {
      const group = Group(id: 'g1', name: 'Family', playerIds: ['p1', 'p2']);
      final updated = group.copyWith(name: 'Friends');
      expect(updated.id, 'g1');
      expect(updated.name, 'Friends');
      expect(updated.playerIds, ['p1', 'p2']);
    });

    test('toJson and fromJson roundtrip', () {
      const group = Group(id: 'g1', name: 'Family', playerIds: ['p1', 'p2', 'p3']);

      final json = group.toJson();
      final restored = Group.fromJson(json);

      expect(restored.id, group.id);
      expect(restored.name, group.name);
      expect(restored.playerIds, group.playerIds);
    });
  });
}
