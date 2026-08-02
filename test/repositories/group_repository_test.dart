import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/data/repositories/group_repository.dart';
import 'package:score/core/models/group.dart';

void main() {
  group('GroupRepository', () {
    late GroupRepository repo;

    setUp(() {
      repo = GroupRepository();
    });

    test('starts empty', () {
      expect(repo.all, isEmpty);
    });

    test('add adds a group', () {
      repo.add(const Group(id: 'g1', name: 'Family', playerIds: ['p1', 'p2']));
      expect(repo.all.length, 1);
    });

    test('getById returns correct group', () {
      repo.add(const Group(id: 'g1', name: 'Family'));
      repo.add(const Group(id: 'g2', name: 'Friends'));

      final group = repo.getById('g2');
      expect(group, isNotNull);
      expect(group!.name, 'Friends');
    });

    test('getById returns null for unknown id', () {
      expect(repo.getById('unknown'), isNull);
    });

    test('update modifies group', () {
      repo.add(const Group(id: 'g1', name: 'Family'));
      repo.update('g1', const Group(id: 'g1', name: 'Updated'));

      expect(repo.getById('g1')!.name, 'Updated');
    });

    test('remove deletes group', () {
      repo.add(const Group(id: 'g1', name: 'Family'));
      repo.add(const Group(id: 'g2', name: 'Friends'));

      repo.remove('g1');
      expect(repo.all.length, 1);
      expect(repo.getById('g1'), isNull);
    });
  });
}
