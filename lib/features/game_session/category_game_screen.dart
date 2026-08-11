import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/game_played.dart';
import '../../../core/models/game.dart';
import '../../../core/models/player.dart';
import '../../../core/providers/app_providers.dart';

class CategoryGameScreen extends ConsumerStatefulWidget {
  final String gamePlayedId;

  const CategoryGameScreen({super.key, required this.gamePlayedId});

  @override
  ConsumerState<CategoryGameScreen> createState() => _CategoryGameScreenState();
}

class _CategoryGameScreenState extends ConsumerState<CategoryGameScreen> {
  late Map<String, Map<String, TextEditingController>> _countControllers;
  late Map<String, Map<String, TextEditingController>> _multControllers;
  late Map<String, Map<String, int>> _localCounts;
  late Map<String, Map<String, int>> _localMultipliers;
  late Map<String, Map<String, bool>> _conditionToggled;
  bool _advancedScoring = false;
  Player? _activePlayer;
  late List<ScoringCategory> _categories;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    _initFromState();
  }

  void _initFromState() {
    final repo = ref.read(gamePlayedRepositoryProvider);
    final gp = repo.getById(widget.gamePlayedId);
    final games = ref.read(allGamesProvider);
    final game = games.where((g) => g.id == gp?.gameId).firstOrNull;
    if (gp == null || game == null) return;

    _advancedScoring = gp.advancedScoringEnabled;
    _categories = game.categories;
    _countControllers = {};
    _multControllers = {};
    _localCounts = {};
    _localMultipliers = {};
    _conditionToggled = {};

    for (final cat in _categories) {
      _localCounts[cat.label] = {};
      _localMultipliers[cat.label] = {};
      _conditionToggled[cat.label] = {};
      _countControllers[cat.label] = {};
      _multControllers[cat.label] = {};
      for (final pid in gp.playerIds) {
        final existing = gp.categoryScores[pid]?[cat.label] ?? cat.defaultValue ?? 0;
        final existingMult = gp.categoryMultipliers[pid]?[cat.label] ?? 1;
        _localCounts[cat.label]![pid] = existing;
        _localMultipliers[cat.label]![pid] = existingMult;
        _conditionToggled[cat.label]![pid] = existingMult == 2 && _advancedScoring;
        _countControllers[cat.label]![pid] =
            TextEditingController(text: existing > 0 ? '$existing' : '');
        _multControllers[cat.label]![pid] =
            TextEditingController(text: cat.hasMultiplier && !_advancedScoring ? '$existingMult' : '');
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    for (final m in _countControllers.values) {
      for (final c in m.values) {
        c.dispose();
      }
    }
    for (final m in _multControllers.values) {
      for (final c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(gamePlayedRepositoryProvider);
    final gp = repo.getById(widget.gamePlayedId);
    if (gp == null) return Scaffold(body: Center(child: Text(l10n.sessionNotFound)));

    final games = ref.watch(allGamesProvider);
    final players = ref.watch(allPlayersProvider);
    final game = games.where((g) => g.id == gp.gameId).firstOrNull;
    if (game == null) return Scaffold(body: Center(child: Text(l10n.sessionNotFound)));

    final gamePlayers = gp.playerIds
        .map((id) => players.where((p) => p.id == id).firstOrNull)
        .where((p) => p != null)
        .cast<Player>()
        .toList();

    if (_activePlayer == null && gamePlayers.isNotEmpty) {
      _activePlayer = gamePlayers.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
        actions: [
          if (gp.status == GameStatus.paused)
            TextButton.icon(
              onPressed: () {
                ref.read(gamePlayedRepositoryProvider).update(
                      widget.gamePlayedId,
                      gp.copyWith(status: GameStatus.inProgress),
                    );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.resume),
            )
          else
            TextButton.icon(
              onPressed: () {
                ref.read(gamePlayedRepositoryProvider).update(
                      widget.gamePlayedId,
                      gp.copyWith(status: GameStatus.paused),
                    );
                if (context.canPop()) context.pop();
              },
              icon: const Icon(Icons.pause),
              label: Text(l10n.pause),
            ),
        ],
      ),
      body: Column(
        children: [
          _PlayerSelector(
            players: gamePlayers,
            activePlayer: _activePlayer,
            onSelect: (p) => setState(() => _activePlayer = p),
            getTotal: (pid) => _computeTotal(pid),
          ),
          Expanded(
            child: _activePlayer != null
                ? _CategoryInputs(
                    player: _activePlayer!,
                    categories: _categories,
                    countControllers: _countControllers,
                    multControllers: _multControllers,
                    localCounts: _localCounts,
                    localMultipliers: _localMultipliers,
                    advancedScoring: _advancedScoring,
                    conditionToggled: _conditionToggled,
                    onChanged: () {
                      setState(() {});
                      _saveProgress();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          if (_activePlayer != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Total ', style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    '${_computeTotal(_activePlayer!.id)}',
                    style: GoogleFonts.bricolageGrotesque(
                        fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  Text(l10n.pts, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _saveProgress();
                    finishGame(ref, widget.gamePlayedId);
                    context.pushNamed('results', extra: widget.gamePlayedId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                  ),
                  child: Text(l10n.finishGame),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _computeTotal(String playerId) {
    int total = 0;
    for (final cat in _categories) {
      final count = _localCounts[cat.label]?[playerId] ?? 0;
      final mult = _localMultipliers[cat.label]?[playerId] ?? 1;
      total += count * mult;
    }
    return total;
  }

  void _saveProgress() {
    final repo = ref.read(gamePlayedRepositoryProvider);
    final gp = repo.getById(widget.gamePlayedId);
    if (gp == null) return;

    final Map<String, Map<String, int>> newCategoryScores = {};
    final Map<String, Map<String, int>> newMultipliers = {};
    final Map<String, int> newTotals = {};

    for (final pid in gp.playerIds) {
      newCategoryScores[pid] = {};
      newMultipliers[pid] = {};
      int total = 0;
      for (final cat in _categories) {
        final count = _localCounts[cat.label]?[pid] ?? 0;
        final mult = _localMultipliers[cat.label]?[pid] ?? 1;
        newCategoryScores[pid]![cat.label] = count;
        newMultipliers[pid]![cat.label] = mult;
        total += count * mult;
      }
      newTotals[pid] = total;
    }

    final entry = ScoreEntry(
      timestamp: DateTime.now(),
      scores: Map<String, int>.from(newTotals),
      categoryScores: Map<String, Map<String, int>>.from(
        newCategoryScores.map((k, v) => MapEntry(k, Map<String, int>.from(v))),
      ),
      categoryMultipliers: Map<String, Map<String, int>>.from(
        newMultipliers.map((k, v) => MapEntry(k, Map<String, int>.from(v))),
      ),
    );

    repo.update(
      widget.gamePlayedId,
      gp.copyWith(
        scores: newTotals,
        categoryScores: newCategoryScores,
        categoryMultipliers: newMultipliers,
        history: [...gp.history, entry],
      ),
    );
    ref.invalidate(activeGamesProvider);
    bumpGameVersion(ref);
  }
}

class _PlayerSelector extends StatelessWidget {
  final List<Player> players;
  final Player? activePlayer;
  final void Function(Player) onSelect;
  final int Function(String) getTotal;

  const _PlayerSelector({
    required this.players,
    required this.activePlayer,
    required this.onSelect,
    required this.getTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
        child: Row(
          children: players.map((p) {
            final isActive = p.id == activePlayer?.id;
            final total = getTotal(p.id);
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onSelect(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: p.color.withValues(alpha: 0.3),
                            child: Text(
                              p.avatar ?? p.name[0].toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? AppColors.onPrimary : p.color),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.name,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: isActive ? AppColors.onPrimary : AppColors.onSurface,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$total',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isActive ? AppColors.onPrimary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryInputs extends StatelessWidget {
  final Player player;
  final List<ScoringCategory> categories;
  final Map<String, Map<String, TextEditingController>> countControllers;
  final Map<String, Map<String, TextEditingController>> multControllers;
  final Map<String, Map<String, int>> localCounts;
  final Map<String, Map<String, int>> localMultipliers;
  final bool advancedScoring;
  final Map<String, Map<String, bool>> conditionToggled;
  final VoidCallback onChanged;

  const _CategoryInputs({
    required this.player,
    required this.categories,
    required this.countControllers,
    required this.multControllers,
    required this.localCounts,
    required this.localMultipliers,
    required this.advancedScoring,
    required this.conditionToggled,
    required this.onChanged,
  });

  String _conditionFor(String catLabel) {
    switch (catLabel) {
      case 'Plazas': return '×2 si > 10';
      case 'Jardins': return '×2 si lac adjacent';
      case 'Caserne': return '×2 si 3+ côtés libres';
      case 'Temple': return '×2 si niveau 2+';
      case 'Marché': return '×2 si adjacent à étoile';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    int grandTotal = 0;

    final gridPattern = RegExp(r'^Carte (\d),(\d)$');
    final gridCategories = <ScoringCategory>[];
    final otherCategories = <ScoringCategory>[];
    int maxRow = 0, maxCol = 0;

    for (final cat in categories) {
      final match = gridPattern.firstMatch(cat.label);
      if (match != null) {
        gridCategories.add(cat);
        maxRow = max(maxRow, int.parse(match.group(1)!));
        maxCol = max(maxCol, int.parse(match.group(2)!));
      } else {
        otherCategories.add(cat);
      }
    }

    for (final cat in categories) {
      final count = localCounts[cat.label]?[player.id] ?? 0;
      final mult = localMultipliers[cat.label]?[player.id] ?? 1;
      grandTotal += count * mult;
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      children: [
        if (gridCategories.isNotEmpty) ...[
          _GridInputs(
            player: player,
            categories: gridCategories,
            countControllers: countControllers,
            localCounts: localCounts,
            rows: maxRow,
            cols: maxCol,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ...otherCategories.map((cat) => _buildRow(context, cat, grandTotal)),
      ],
    );
  }

  Widget _buildRow(BuildContext context, ScoringCategory cat, int grandTotal) {
    final l10n = AppLocalizations.of(context);
    final count = localCounts[cat.label]?[player.id] ?? 0;
    final mult = localMultipliers[cat.label]?[player.id] ?? 1;
    final subTotal = count * mult;
    final isKey = cat.label.toLowerCase().contains('clé');

    if (isKey) {
      return Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.vpn_key, size: 18, color: AppColors.outline),
              const SizedBox(width: AppSpacing.sm),
              Text(cat.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurface)),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 56,
                child: TextField(
                  controller: countControllers[cat.label]?[player.id],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    hintText: '0',
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (_) {
                    final v = int.tryParse(countControllers[cat.label]?[player.id]?.text ?? '') ?? 0;
                    localCounts[cat.label]![player.id] = v;
                    onChanged();
                  },
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.outlineVariant),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$subTotal',
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              Text(l10n.pts, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(cat.label,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.onSurface)),
                ),
                Text(
                  '$subTotal',
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                Text(l10n.pts, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            if (cat.description != null)
              Text(cat.description!, style: Theme.of(context).textTheme.labelSmall),
            if (advancedScoring && _conditionFor(cat.label).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Text(
                      _conditionFor(cat.label),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Switch(
                      value: conditionToggled[cat.label]?[player.id] ?? false,
                      onChanged: (v) {
                        conditionToggled[cat.label]![player.id] = v;
                        localMultipliers[cat.label]![player.id] = v ? 2 : 1;
                        final ctrl = multControllers[cat.label]?[player.id];
                        if (ctrl != null) {
                          ctrl.text = v ? '2' : '';
                        }
                        onChanged();
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                SizedBox(
                  width: 56,
                  child: TextField(
                    controller: countControllers[cat.label]?[player.id],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.bricolageGrotesque(
                        fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: AppColors.outlineVariant),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      isDense: true,
                      prefixIcon: countControllers[cat.label]?[player.id]?.text.isEmpty ?? true
                          ? Icon(
                              isKey ? Icons.vpn_key : Icons.star_border,
                              size: 16,
                              color: AppColors.outlineVariant,
                            )
                          : null,
                      prefixIconConstraints: const BoxConstraints(minWidth: 20),
                    ),
                    onChanged: (_) {
                      final v = int.tryParse(
                              countControllers[cat.label]?[player.id]?.text ?? '') ??
                          0;
                      localCounts[cat.label]![player.id] = v;
                      onChanged();
                    },
                  ),
                ),
                if (cat.hasMultiplier) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('×',
                        style: GoogleFonts.bricolageGrotesque(
                            fontSize: 20, color: AppColors.outline)),
                  ),
                  SizedBox(
                    width: 56,
                    child: TextField(
                      controller: multControllers[cat.label]?[player.id],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.bricolageGrotesque(
                          fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.secondary),
                      decoration: InputDecoration(
                        hintText: '1',
                        hintStyle: TextStyle(color: AppColors.outlineVariant),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        isDense: true,
                        prefixIcon: multControllers[cat.label]?[player.id]?.text.isEmpty ?? true
                            ? const Icon(Icons.grid_view, size: 16, color: AppColors.outlineVariant)
                            : null,
                        prefixIconConstraints: const BoxConstraints(minWidth: 20),
                      ),
                      onChanged: (_) {
                        final v = int.tryParse(
                                multControllers[cat.label]?[player.id]?.text ?? '') ??
                            1;
                        localMultipliers[cat.label]![player.id] = v.clamp(1, 99);
                        onChanged();
                      },
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.arrow_forward, size: 16, color: AppColors.outlineVariant),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$subTotal',
                  style: GoogleFonts.bricolageGrotesque(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}

class _GridInputs extends StatelessWidget {
  final Player player;
  final List<ScoringCategory> categories;
  final Map<String, Map<String, TextEditingController>> countControllers;
  final Map<String, Map<String, int>> localCounts;
  final int rows;
  final int cols;
  final VoidCallback onChanged;

  const _GridInputs({
    required this.player,
    required this.categories,
    required this.countControllers,
    required this.localCounts,
    required this.rows,
    required this.cols,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 1; r <= rows; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                for (var c = 1; c <= cols; c++) ...[
                  if (c > 1) const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _buildCell(context, r, c)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    final label = 'Carte $row,$col';
    final value = localCounts[label]?[player.id] ?? 0;
    final controller = countControllers[label]?[player.id];

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          expands: true,
          maxLines: null,
          style: GoogleFonts.bricolageGrotesque(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: value > 0 ? AppColors.primary : AppColors.outlineVariant),
          decoration: const InputDecoration(
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (_) {
            final v = int.tryParse(controller?.text ?? '') ?? 0;
            localCounts[label]![player.id] = v;
            onChanged();
          },
        ),
      ),
    );
  }
}
