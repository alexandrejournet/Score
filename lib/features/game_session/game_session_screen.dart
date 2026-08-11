import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/game_played.dart';
import '../../../core/models/game.dart';
import '../../../core/models/player.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/ui/haptic_util.dart';
import '../../../core/ui/pulse_score.dart';
import 'category_game_screen.dart';
import 'skyjo_game_screen.dart';

Future<void> _showScoreDialog(
  BuildContext context,
  WidgetRef ref,
  String gamePlayedId,
  Player player,
) async {
  final repo = ref.read(gamePlayedRepositoryProvider);
  final gp = repo.getById(gamePlayedId);
  if (gp == null) return;

  final currentScore = gp.scores[player.id] ?? 0;

  final result = await showDialog<Map<String, int>>(
    context: context,
    builder: (ctx) => _ScoreDialog(player: player, currentScore: currentScore),
  );

  if (result == null) return;

  final newScore = result['new'] as int;
  final newScores = Map<String, int>.from(gp.scores);
  newScores[player.id] = newScore;

  final entry = ScoreEntry(
    timestamp: DateTime.now(),
    scores: Map<String, int>.from(newScores),
  );

  repo.update(gamePlayedId, gp.copyWith(scores: newScores, history: [...gp.history, entry]));
  ref.invalidate(activeGamesProvider);
  bumpGameVersion(ref);

  hapticLight(ref);

  _checkEndGameForScores(ref, gamePlayedId, gp, newScores);
}

void _checkEndGameForScores(WidgetRef ref, String gamePlayedId, GamePlayed gp, Map<String, int> newScores) {
  final games = ref.read(allGamesProvider);
  final game = games.where((g) => g.id == gp.gameId).firstOrNull;
  final endScore = game?.endScore;
  if (endScore == null) return;

  final reached = newScores.values.any((s) => s >= endScore);
  if (reached) {
    finishGame(ref, gamePlayedId);
  }
}

class _ScoreDialog extends StatefulWidget {
  final Player player;
  final int currentScore;
  const _ScoreDialog({required this.player, required this.currentScore});

  @override
  State<_ScoreDialog> createState() => _ScoreDialogState();
}

class _ScoreDialogState extends State<_ScoreDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_controller.text) ?? 0;

  void _submit() {
    if (_value != 0) {
      Navigator.of(context).pop({'add': _value, 'new': widget.currentScore + _value});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: widget.player.color.withValues(alpha: 0.2),
            child: Text(widget.player.avatar ?? widget.player.name[0].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w700, color: widget.player.color)),
          ),
          const SizedBox(width: 12),
          Text(widget.player.name),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.currentScore, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text('${widget.currentScore}',
              style: GoogleFonts.bricolageGrotesque(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.bricolageGrotesque(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            decoration: InputDecoration(hintText: l10n.addPoints),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuickButton(label: '-5', onTap: () { _controller.text = '-5'; setState(() {}); }),
              const SizedBox(width: AppSpacing.sm),
              _QuickButton(label: '-1', onTap: () { _controller.text = '-1'; setState(() {}); }),
              const SizedBox(width: AppSpacing.sm),
              _QuickButton(label: '+1', onTap: () { _controller.text = '1'; setState(() {}); }),
              const SizedBox(width: AppSpacing.sm),
              _QuickButton(label: '+5', onTap: () { _controller.text = '5'; setState(() {}); }),
              const SizedBox(width: AppSpacing.sm),
              _QuickButton(label: '+10', onTap: () { _controller.text = '10'; setState(() {}); }),
              const SizedBox(width: AppSpacing.sm),
              _QuickButton(label: '+25', onTap: () { _controller.text = '25'; setState(() {}); }),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: _value != 0 ? _submit : null,
          child: Text(_value != 0
              ? '${_value > 0 ? l10n.add : l10n.remove} ${_value > 0 ? "+" : ""}$_value'
              : l10n.add),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary)),
      ),
    );
  }
}

void _showRanking(BuildContext context, WidgetRef ref, String gamePlayedId, GamePlayed gp) {
  final players = ref.read(allPlayersProvider);
  final l10n = AppLocalizations.of(context);

  final ranked = gp.playerIds
      .map((id) => players.where((p) => p.id == id).firstOrNull)
      .where((p) => p != null)
      .cast<Player>()
      .toList();

  ranked.sort((a, b) {
    final scoreB = gp.scores[b.id] ?? 0;
    final scoreA = gp.scores[a.id] ?? 0;
    return scoreB.compareTo(scoreA);
  });

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.ranking, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            ...ranked.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final player = entry.value;
              final score = gp.scores[player.id] ?? 0;

              final rankColors = [
                AppColors.tertiaryLight,
                AppColors.outlineVariant,
                AppColors.tertiaryContainer,
              ];
              final rankColor = rank <= 3 ? rankColors[rank - 1] : AppColors.surfaceContainerHigh;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('#$rank',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: rankColor)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: player.color.withValues(alpha: 0.2),
                        child: Text(player.avatar ?? player.name[0].toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.w700, color: player.color)),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(player.name, style: Theme.of(context).textTheme.bodyLarge)),
                      Text('$score',
                          style: GoogleFonts.bricolageGrotesque(
                              fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      const SizedBox(width: 4),
                      Text(l10n.pts, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

void _showAddPlayerDialog(BuildContext context, WidgetRef ref, String gamePlayedId, GamePlayed gp) {
  final l10n = AppLocalizations.of(context);
  final allPlayers = ref.read(allPlayersProvider);
  final availablePlayers = allPlayers.where((p) => !gp.playerIds.contains(p.id)).toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return _AddPlayerSheet(
        l10n: l10n,
        availablePlayers: availablePlayers,
        allPlayersCount: allPlayers.length,
        onAddExisting: (playerId) {
          _addPlayerToGame(ref, gamePlayedId, gp, playerId);
          Navigator.of(ctx).pop();
        },
        onCreateAndAdd: (player) {
          addPlayer(ref, player);
          _addPlayerToGame(ref, gamePlayedId, gp, player.id);
          Navigator.of(ctx).pop();
        },
      );
    },
  );
}

class _AddPlayerSheet extends StatefulWidget {
  final AppLocalizations l10n;
  final List<Player> availablePlayers;
  final int allPlayersCount;
  final void Function(String playerId) onAddExisting;
  final void Function(Player player) onCreateAndAdd;

  const _AddPlayerSheet({
    required this.l10n,
    required this.availablePlayers,
    required this.allPlayersCount,
    required this.onAddExisting,
    required this.onCreateAndAdd,
  });

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.marginMobile,
        right: AppSpacing.marginMobile,
        top: AppSpacing.marginMobile,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.marginMobile,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.l10n.addPlayer, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          if (widget.availablePlayers.isNotEmpty) ...[
            Text(widget.l10n.players, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: widget.availablePlayers.map((player) {
                return ActionChip(
                  avatar: CircleAvatar(
                    radius: 12,
                    backgroundColor: player.color.withValues(alpha: 0.2),
                    child: Text(player.avatar ?? player.name[0].toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: player.color)),
                  ),
                  label: Text(player.name),
                  onPressed: () => widget.onAddExisting(player.id),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(widget.l10n.create, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: widget.l10n.playerName),
                  autofocus: widget.availablePlayers.isEmpty,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  final player = Player(
                    id: const Uuid().v4(),
                    name: name,
                    color: AppColors.playerColors[
                        widget.allPlayersCount % AppColors.playerColors.length],
                  );
                  widget.onCreateAndAdd(player);
                },
                icon: const Icon(Icons.check),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _addPlayerToGame(WidgetRef ref, String gamePlayedId, GamePlayed gp, String playerId) {
  final repo = ref.read(gamePlayedRepositoryProvider);
  final newPlayerIds = [...gp.playerIds, playerId];
  final newScores = Map<String, int>.from(gp.scores);
  newScores[playerId] = 0;
  final newCategoryScores = Map<String, Map<String, int>>.from(gp.categoryScores);
  newCategoryScores[playerId] = {};
  final newCategoryMultipliers = Map<String, Map<String, int>>.from(gp.categoryMultipliers);
  newCategoryMultipliers[playerId] = {};

  repo.update(
    gamePlayedId,
    gp.copyWith(
      playerIds: newPlayerIds,
      scores: newScores,
      categoryScores: newCategoryScores,
      categoryMultipliers: newCategoryMultipliers,
    ),
  );
  ref.invalidate(activeGamesProvider);
  bumpGameVersion(ref);
}

void _showHistory(BuildContext context, WidgetRef ref, String gamePlayedId, GamePlayed gp) {
  final players = ref.read(allPlayersProvider);
  final reversedHistory = gp.history.reversed.toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Text(l10n.history, style: Theme.of(context).textTheme.headlineMedium),
                    const Spacer(),
                    if (gp.history.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          final repo = ref.read(gamePlayedRepositoryProvider);
                          final restoredScores = gp.history.length > 1
                              ? gp.history[gp.history.length - 2].scores
                              : <String, int>{};
                          repo.update(
                            gamePlayedId,
                            gp.copyWith(
                              history: gp.history.sublist(0, gp.history.length - 1),
                              scores: restoredScores,
                            ),
                          );
                          ref.invalidate(activeGamesProvider);
                          bumpGameVersion(ref);
                          Navigator.of(ctx).pop();
                        },
                        icon: const Icon(Icons.undo, size: 18),
                        label: Text(l10n.undoLast),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: reversedHistory.isEmpty
                    ? Center(
                        child: Text(l10n.noChanges,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                        itemCount: reversedHistory.length,
                        itemBuilder: (ctx, index) {
                          final entry = reversedHistory[index];
                          final entryIndex = gp.history.length - 1 - index;
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('#${entryIndex + 1}',
                                          style: Theme.of(context).textTheme.labelLarge),
                                      const Spacer(),
                                      Text(
                                        _timeFormat.format(entry.timestamp),
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  ...entry.scores.entries.map((e) {
                                    final player = players.where((p) => p.id == e.key).firstOrNull;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundColor: (player?.color ?? AppColors.primary)
                                                .withValues(alpha: 0.2),
                                            child: Text(
                                              player?.name.isNotEmpty == true
                                                  ? (player!.avatar ?? player.name[0].toUpperCase())
                                                  : '?',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                  color: player?.color ?? AppColors.primary),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(player?.name ?? '?',
                                              style: Theme.of(context).textTheme.bodyMedium),
                                          const Spacer(),
                                          Text('${e.value}',
                                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                    color: AppColors.primary,
                                                  )),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

final _timeFormat = _TimeFormatter();

class _TimeFormatter {
  String format(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

class GameSessionScreen extends ConsumerStatefulWidget {
  final String gamePlayedId;
  const GameSessionScreen({super.key, required this.gamePlayedId});

  @override
  ConsumerState<GameSessionScreen> createState() => _GameSessionScreenState();
}

class _GameSessionScreenState extends ConsumerState<GameSessionScreen> {
  final Set<String> _selectedPlayerIds = {};
  bool _multiSelectMode = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(gameDataVersionProvider);
    final repo = ref.read(gamePlayedRepositoryProvider);
    final gamePlayed = repo.getById(widget.gamePlayedId);

    if (gamePlayed == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.game)),
        body: Center(child: Text(l10n.sessionNotFound)),
      );
    }

    final games = ref.watch(allGamesProvider);
    final game = games.where((g) => g.id == gamePlayed.gameId).firstOrNull;

    if (game != null && game.scoreType == ScoreType.categories && game.categories.isNotEmpty) {
      return CategoryGameScreen(gamePlayedId: widget.gamePlayedId);
    }
    if (game != null && game.scoreType == ScoreType.rounds) {
      return SkyjoGameScreen(gamePlayedId: widget.gamePlayedId);
    }

    final players = ref.watch(allPlayersProvider);
    final sortedPlayers = gamePlayed.playerIds
        .map((id) => players.where((p) => p.id == id).firstOrNull)
        .where((p) => p != null)
        .cast<Player>()
        .toList();

    sortedPlayers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final showMultiSelect = game?.allowMultiSelect ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(game?.name ?? l10n.game),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: l10n.ranking,
            onPressed: () => _showRanking(context, ref, widget.gamePlayedId, gamePlayed),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.history,
            onPressed: () => _showHistory(context, ref, widget.gamePlayedId, gamePlayed),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: l10n.addPlayer,
            onPressed: () => _showAddPlayerDialog(context, ref, widget.gamePlayedId, gamePlayed),
          ),
          if (showMultiSelect)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _multiSelectMode = !_multiSelectMode;
                  if (!_multiSelectMode) _selectedPlayerIds.clear();
                });
              },
              icon: Icon(_multiSelectMode ? Icons.close : Icons.checklist),
              label: Text(_multiSelectMode ? l10n.cancel : l10n.select),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: sortedPlayers.length,
              itemBuilder: (context, index) {
                final player = sortedPlayers[index];
                final score = gamePlayed.scores[player.id] ?? 0;
                final isSelected = _selectedPlayerIds.contains(player.id);

                return Card(
                  color: _multiSelectMode && isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceContainerLow,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: _multiSelectMode && isSelected
                        ? BorderSide(color: AppColors.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: _multiSelectMode
                        ? () => setState(() {
                              if (isSelected) {
                                _selectedPlayerIds.remove(player.id);
                              } else {
                                _selectedPlayerIds.add(player.id);
                              }
                            })
                        : null,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          if (_multiSelectMode) ...[
                            Checkbox(
                              value: isSelected,
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selectedPlayerIds.add(player.id);
                                } else {
                                  _selectedPlayerIds.remove(player.id);
                                }
                              }),
                              activeColor: AppColors.primary,
                            ),
                          ],
                          const SizedBox(width: AppSpacing.md),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: player.color.withValues(alpha: 0.2),
                            child: Text(player.name.isNotEmpty ? player.avatar ?? player.name[0].toUpperCase() : '?',
                                style: TextStyle(fontWeight: FontWeight.w700, color: player.color)),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(player.name, style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          if (!_multiSelectMode) ...[
                            const SizedBox(width: AppSpacing.md),
                            SizedBox(
                              width: 120,
                              child: GestureDetector(
                                onTap: () => _showScoreDialog(context, ref, widget.gamePlayedId, player),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.outlineVariant, width: 1),
                                  ),
                                  child: PulseScore(
                                      value: score,
                                      fontSize: 28,
                                      color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_multiSelectMode && _selectedPlayerIds.isNotEmpty)
            _MultiSelectBar(
              ref: ref,
              gamePlayedId: widget.gamePlayedId,
              gamePlayed: gamePlayed,
              selectedPlayerIds: _selectedPlayerIds.toList(),
              onApplied: () => setState(() {
                _selectedPlayerIds.clear();
                _multiSelectMode = false;
              }),
            ),
          if (!_multiSelectMode)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      finishGame(ref, widget.gamePlayedId);
                      context.pushNamed('results', extra: widget.gamePlayedId);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.onSecondary),
                    child: Text(l10n.finishGame),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MultiSelectBar extends StatefulWidget {
  final WidgetRef ref;
  final String gamePlayedId;
  final GamePlayed gamePlayed;
  final List<String> selectedPlayerIds;
  final VoidCallback onApplied;

  const _MultiSelectBar({
    required this.ref,
    required this.gamePlayedId,
    required this.gamePlayed,
    required this.selectedPlayerIds,
    required this.onApplied,
  });

  @override
  State<_MultiSelectBar> createState() => _MultiSelectBarState();
}

class _MultiSelectBarState extends State<_MultiSelectBar> {
  final _controller = TextEditingController(text: '0');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_controller.text) ?? 0;

  void _applyToAll(int delta) {
    final repo = widget.ref.read(gamePlayedRepositoryProvider);
    final gp = repo.getById(widget.gamePlayedId);
    if (gp == null) return;

    final newScores = Map<String, int>.from(gp.scores);
    for (final pid in widget.selectedPlayerIds) {
      newScores[pid] = (newScores[pid] ?? 0) + delta;
    }

    final entry = ScoreEntry(
      timestamp: DateTime.now(),
      scores: Map<String, int>.from(newScores),
    );

    repo.update(widget.gamePlayedId, gp.copyWith(scores: newScores, history: [...gp.history, entry]));
    widget.ref.invalidate(activeGamesProvider);
    bumpGameVersion(widget.ref);

    hapticLight(widget.ref);

    _checkEndGameForScores(widget.ref, widget.gamePlayedId, gp, newScores);

    widget.onApplied();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.playersCount(widget.selectedPlayerIds.length),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 96,
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 20, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    isDense: true),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  child: IconButton(
                    onPressed: () => _applyToAll(-_value.abs()),
                    icon: const Icon(Icons.remove_circle, size: 32),
                    color: AppColors.errorMuted,
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    onPressed: () => _applyToAll(_value.abs()),
                    icon: const Icon(Icons.add_circle, size: 32),
                    color: AppColors.secondary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
