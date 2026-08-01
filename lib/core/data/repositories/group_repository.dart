import '../../models/group.dart';

class GroupRepository {
  final List<Group> _groups = [];

  List<Group> get all => List.unmodifiable(_groups);

  GroupRepository({List<Group>? groups}) {
    if (groups != null) _groups.addAll(groups);
  }

  Group? getById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Group group) {
    _groups.add(group);
  }

  void update(String id, Group updated) {
    final idx = _groups.indexWhere((g) => g.id == id);
    if (idx >= 0) {
      _groups[idx] = updated;
    }
  }

  void remove(String id) {
    _groups.removeWhere((g) => g.id == id);
  }
}
