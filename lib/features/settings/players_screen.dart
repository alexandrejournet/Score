import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/player.dart';

const _uuid = Uuid();

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = AppColors.playerColors[0];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(allPlayersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.players)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.sm,
                AppSpacing.marginMobile, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.playersSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: l10n.playerName),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: players.isEmpty
                ? Center(
                    child: Text(
                      l10n.playersCount(0),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.outline,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                    ),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: player.color.withValues(alpha: 0.2),
                            child: Text(
                              player.name.isNotEmpty
                                  ? player.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: player.color,
                              ),
                            ),
                          ),
                          title: Text(player.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => deletePlayer(ref, player.id),
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

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final player = Player(
      id: _uuid.v4(),
      name: name,
      color: _selectedColor,
    );
    addPlayer(ref, player);
    _nameController.clear();
    _selectedColor = AppColors.playerColors[
        (ref.read(allPlayersProvider).length) % AppColors.playerColors.length];
  }
}
