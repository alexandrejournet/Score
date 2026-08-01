import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/group.dart';

const _uuid = Uuid();

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  final _nameController = TextEditingController();
  final Set<String> _selectedPlayerIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(allGroupsProvider);
    final players = ref.watch(allPlayersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groups)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: l10n.groupName),
                ),
                if (players.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.players, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: players.map((player) => FilterChip(
                          avatar: CircleAvatar(
                            radius: 10,
                            backgroundColor: player.color.withValues(alpha: 0.2),
                            child: Text(
                              player.name.isNotEmpty
                                  ? player.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: player.color,
                              ),
                            ),
                          ),
                          label: Text(player.name),
                          selected: _selectedPlayerIds.contains(player.id),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPlayerIds.add(player.id);
                              } else {
                                _selectedPlayerIds.remove(player.id);
                              }
                            });
                          },
                        )).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedPlayerIds.isNotEmpty &&
                            _nameController.text.trim().isNotEmpty
                        ? _addGroup
                        : null,
                    child: Text(l10n.create),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: Text(
                      l10n.groupsCount(0),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.outline,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                    ),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: const Icon(Icons.group),
                          title: Text(group.name),
                          subtitle: Text(
                            l10n.playersCount(group.playerIds.length),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => deleteGroup(ref, group.id),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addGroup() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedPlayerIds.isEmpty) return;

    final group = Group(
      id: _uuid.v4(),
      name: name,
      playerIds: _selectedPlayerIds.toList(),
    );
    addGroup(ref, group);
    _nameController.clear();
    setState(() => _selectedPlayerIds.clear());
  }
}
