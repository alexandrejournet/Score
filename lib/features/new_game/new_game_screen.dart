import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/player.dart';

const _uuid = Uuid();

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  String? _selectedGameId;
  final Set<String> _selectedPlayerIds = {};
  String? _selectedGroupId;
  bool _advancedScoring = false;
  final _playerNameController = TextEditingController();

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(myGamesProvider);
    final players = ref.watch(allPlayersProvider);
    final groups = ref.watch(allGroupsProvider);
    final selectedGame = games.where((g) => g.id == _selectedGameId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newGame),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          Text(l10n.game, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: games.map((game) => ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (game.icon != null) ...[
                        Text(game.icon!),
                        const SizedBox(width: 6),
                      ],
                      Text(game.name),
                    ],
                  ),
                  selected: _selectedGameId == game.id,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGameId = selected ? game.id : null;
                      _selectedPlayerIds.clear();
                      _selectedGroupId = null;
                    });
                  },
                )).toList(),
          ),
          if (selectedGame != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.playerRange(selectedGame.minPlayers, selectedGame.maxPlayers),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            if (selectedGame.hasAdvancedScoring) ...[
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: Text(l10n.advancedScoring),
                subtitle: Text(l10n.advancedScoringDescription),
                value: _advancedScoring,
                onChanged: (v) => setState(() => _advancedScoring = v),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(l10n.group, style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.pushNamed('settings-groups'),
                icon: const Icon(Icons.add, size: 16),
                label: Text(l10n.create),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (groups.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: Text(l10n.none),
                  selected: _selectedGroupId == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedGroupId = null;
                      _selectedPlayerIds.clear();
                    });
                  },
                ),
                ...groups.map((group) => ChoiceChip(
                      label: Text(group.name),
                      selected: _selectedGroupId == group.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGroupId = selected ? group.id : null;
                          _selectedPlayerIds.clear();
                          if (selected) {
                            _selectedPlayerIds.addAll(group.playerIds);
                          }
                        });
                      },
                    )),
              ],
            )
          else
            Text(
              l10n.createGroupHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.outline,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.players, style: Theme.of(context).textTheme.labelLarge),
          if (selectedGame != null)
            Text(
              '${_selectedPlayerIds.length} / ${selectedGame.maxPlayers}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          const SizedBox(height: AppSpacing.sm),
          if (selectedGame == null)
            Text(
              l10n.selectGameFirst,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.outline,
                    fontStyle: FontStyle.italic,
                  ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: players.map((player) {
                final isSelected = _selectedPlayerIds.contains(player.id);
                final isFull = _selectedPlayerIds.length >= selectedGame.maxPlayers && !isSelected;
                return FilterChip(
                  avatar: CircleAvatar(
                    radius: 12,
                    backgroundColor: player.color.withValues(alpha: 0.2),
                    child: Text(
                      player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: player.color,
                      ),
                    ),
                  ),
                  label: Text(player.name),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.onPrimary : null,
                  ),
                  selected: isSelected,
                  onSelected: isFull
                      ? null
                      : (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPlayerIds.add(player.id);
                            } else {
                              _selectedPlayerIds.remove(player.id);
                            }
                          });
                        },
                );
              }).toList(),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.addPlayer, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _playerNameController,
                  decoration: InputDecoration(
                    hintText: l10n.playerName,
                  ),
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
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedGameId != null &&
                      _selectedPlayerIds.length >= (selectedGame?.minPlayers ?? 1)
                  ? _startGame
                  : null,
              child: Text(l10n.launchGame),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isEmpty) return;

    final player = Player(
      id: _uuid.v4(),
      name: name,
      color: AppColors.playerColors[_selectedPlayerIds.length % AppColors.playerColors.length],
    );
    addPlayer(ref, player);
    setState(() {
      _selectedPlayerIds.add(player.id);
    });
    _playerNameController.clear();
  }

  void _startGame() {
    if (_selectedGameId == null) return;

    final gameId = _selectedGameId!;
    final playerIds = _selectedPlayerIds.toList();

    if (_selectedGroupId != null && playerIds.isNotEmpty) {
      final group = ref.read(allGroupsProvider).where((g) => g.id == _selectedGroupId).firstOrNull;
      final groupRepo = ref.read(groupRepositoryProvider);
      if (group != null) {
        final mergedIds = {...group.playerIds, ...playerIds}.toList();
        groupRepo.update(group.id, group.copyWith(playerIds: mergedIds));
      }
    }

    final gamePlayedId = startGame(ref, gameId, playerIds, advancedScoring: _advancedScoring);
    context.pushNamed('game-session', extra: gamePlayedId);
  }
}
