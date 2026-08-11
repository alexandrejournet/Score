import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/player.dart';
import '../../../core/models/game.dart';
import '../../../core/providers/app_providers.dart';

class ResultsScreen extends ConsumerWidget {
  final String gamePlayedId;

  const ResultsScreen({super.key, required this.gamePlayedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(gamePlayedRepositoryProvider);
    final gamePlayed = repo.getById(gamePlayedId);

    if (gamePlayed == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.results)),
        body: Center(child: Text(l10n.sessionNotFound)),
      );
    }

    final games = ref.watch(allGamesProvider);
    final players = ref.watch(allPlayersProvider);
    final game = games.where((g) => g.id == gamePlayed.gameId).firstOrNull;

    final sortedPlayers = gamePlayed.playerIds
        .map((id) => players.where((p) => p.id == id).firstOrNull)
        .where((p) => p != null)
        .cast<Player>()
        .toList();

    sortedPlayers.sort((a, b) {
      final scoreB = gamePlayed.scores[b.id] ?? 0;
      final scoreA = gamePlayed.scores[a.id] ?? 0;
      return game?.lowerScoreWins == true
          ? scoreA.compareTo(scoreB)
          : scoreB.compareTo(scoreA);
    });

    final winner = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;
    final isTie = sortedPlayers.length >= 2 &&
        (gamePlayed.scores[sortedPlayers[0].id] ==
            gamePlayed.scores[sortedPlayers[1].id]);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.results),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              removeHistoryEntry(ref, gamePlayedId);
              context.pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Text(
                  game?.icon ?? '🎲',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  game?.name ?? l10n.game,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  DateFormat('dd MMMM yyyy').format(gamePlayed.date),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (gamePlayed.duration != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.duration} : ${_formatDuration(gamePlayed.duration!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (winner != null && !isTie) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: AppColors.tertiaryLight,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    winner.name,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '${gamePlayed.scores[winner.id]} ${l10n.pts}',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isTie)
            Center(
              child: Column(
                children: [
                  Icon(Icons.handshake, size: 48, color: AppColors.tertiaryLight),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.tie,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.ranking, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.md),
          ...sortedPlayers.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final player = entry.value;
            final score = gamePlayed.scores[player.id] ?? 0;
            final catScores = gamePlayed.categoryScores[player.id];
            final effectiveCategories = game != null &&
                    game.scoreType == ScoreType.categories &&
                    catScores != null &&
                    catScores.isNotEmpty
                ? game.categories
                : null;

            final rankColors = [
              AppColors.tertiaryLight,
              AppColors.outlineVariant,
              AppColors.tertiaryContainer,
            ];
            final rankColor = rank <= 3 ? rankColors[rank - 1] : AppColors.surfaceContainerHigh;

            return _PlayerResultCard(
              rank: rank,
              rankColor: rankColor,
              player: player,
              score: score,
              categoryScores: effectiveCategories != null ? catScores : null,
              categoryMultipliers: effectiveCategories != null ? gamePlayed.categoryMultipliers[player.id] : null,
              categories: effectiveCategories,
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newId = startGame(ref, gamePlayed.gameId, gamePlayed.playerIds, advancedScoring: gamePlayed.advancedScoringEnabled);
                      context.go('/dashboard');
                      context.pushNamed('game-session', extra: newId);
                    },
                    icon: const Icon(Icons.replay),
                    label: Text(l10n.replay),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(l10n.quit),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h${minutes.toString().padLeft(2, '0')}';
    return '$minutes min';
  }
}

class _PlayerResultCard extends StatefulWidget {
  final int rank;
  final Color rankColor;
  final Player player;
  final int score;
  final Map<String, int>? categoryScores;
  final Map<String, int>? categoryMultipliers;
  final List<ScoringCategory>? categories;

  const _PlayerResultCard({
    required this.rank,
    required this.rankColor,
    required this.player,
    required this.score,
    this.categoryScores,
    this.categoryMultipliers,
    this.categories,
  });

  @override
  State<_PlayerResultCard> createState() => _PlayerResultCardState();
}

class _PlayerResultCardState extends State<_PlayerResultCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasCategories = widget.categoryScores != null && widget.categories != null;

    return Card(
      color: AppColors.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          InkWell(
            onTap: hasCategories ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.rankColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '#${widget.rank}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: widget.rankColor,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: widget.player.color.withValues(alpha: 0.2),
                    child: Text(
                      widget.player.name[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: widget.player.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.player.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (hasCategories)
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: AppColors.outline,
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${widget.score}',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(l10n.pts, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
          if (_expanded && hasCategories) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
              child: Column(
                children: widget.categories!.map((cat) {
                  final val = widget.categoryScores![cat.label] ?? 0;
                  final mult = widget.categoryMultipliers?[cat.label] ?? 1;
                  final hasMult = cat.hasMultiplier;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cat.label,
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text(
                          hasMult ? '$val × $mult = ${val * mult}' : '$val',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.secondary,
                                )),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
