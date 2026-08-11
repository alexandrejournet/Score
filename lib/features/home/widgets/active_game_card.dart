import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/game_played.dart';
import '../../../core/models/player.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class ActiveGameCard extends ConsumerWidget {
  final GamePlayed gamePlayed;

  const ActiveGameCard({super.key, required this.gamePlayed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(allGamesProvider);
    final players = ref.watch(allPlayersProvider);
    final game = games.where((g) => g.id == gamePlayed.gameId).firstOrNull;
    final gameColor = game?.color ?? AppColors.primary;

    final gamePlayers = gamePlayed.playerIds
        .map((id) => players.where((p) => p.id == id).firstOrNull)
        .where((p) => p != null)
        .cast<Player>()
        .toList();

    gamePlayers.sort((a, b) {
      final scoreB = gamePlayed.scores[b.id] ?? 0;
      final scoreA = gamePlayed.scores[a.id] ?? 0;
      final cmp = scoreB.compareTo(scoreA);
      return game?.lowerScoreWins == true ? -cmp : cmp;
    });

    final leader = gamePlayers.isNotEmpty ? gamePlayers.first : null;
    final leaderScore = leader != null ? gamePlayed.scores[leader.id] ?? 0 : 0;

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.pushNamed('game-session', extra: gamePlayed.id),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (game?.icon != null) ...[
                          Text(game!.icon!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            game?.name ?? 'Partie',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (gamePlayed.status == GameStatus.paused)
                          Container(
                            margin: const EdgeInsets.only(left: AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryLight.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(l10n.pause,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.tertiaryContainer,
                                    )),
                          ),
                      ],
                    ),
                    const Spacer(),
                    _PlayerAvatars(
                      players: gamePlayers,
                      color: gameColor,
                      maxDisplay: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: gameColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                    color: gameColor,
                    size: 28,
                  ),
                ),
                if (leader != null && leaderScore > 0) ...[
                    const Spacer(),
                    Text(l10n.leader, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: leader.color.withValues(alpha: 0.2),
                          child: Text(
                            leader.name[0].toUpperCase(),
                            style: TextStyle(
                                fontSize: 8, fontWeight: FontWeight.w700, color: leader.color),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(leader.name,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.onSurface)),
                        const SizedBox(width: 4),
                        Text('$leaderScore',
                            style: GoogleFonts.bricolageGrotesque(
                                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ] else ...[
                    const Spacer(),
                    Text(l10n.leader,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline)),
                    const SizedBox(height: 2),
                    Text(l10n.noLeader,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.outlineVariant)),
                  ],
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _PlayerAvatars extends StatelessWidget {
  final List<Player> players;
  final Color color;
  final int maxDisplay;

  const _PlayerAvatars({
    required this.players,
    required this.color,
    this.maxDisplay = 5,
  });

  @override
  Widget build(BuildContext context) {
    final display = players.take(maxDisplay).toList();
    final overflow = players.length - maxDisplay;

    final totalDisplayed = display.length + (overflow > 0 ? 1 : 0);
    final neededWidth = totalDisplayed > 0
        ? (totalDisplayed - 1) * 18.0 + 32.0
        : 0.0;

    return SizedBox(
      height: 36,
      width: neededWidth,
      child: Stack(
        children: [
          ...display.asMap().entries.map((entry) {
            final player = entry.value;
            return Positioned(
              left: (entry.key * 18).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: player.color,
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: (display.length * 18).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
