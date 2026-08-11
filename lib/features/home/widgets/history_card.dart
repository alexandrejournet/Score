import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/game_played.dart';
import '../../../core/models/player.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class HistoryCard extends ConsumerWidget {
  final GamePlayed gamePlayed;

  const HistoryCard({super.key, required this.gamePlayed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final games = ref.watch(allGamesProvider);
    final players = ref.watch(allPlayersProvider);

    final game = games.where((g) => g.id == gamePlayed.gameId).firstOrNull;
    final gameColor = game?.color ?? AppColors.primary;

    return Dismissible(
      key: Key('history-${gamePlayed.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: replay
          final newId = startGame(ref, gamePlayed.gameId, gamePlayed.playerIds,
              advancedScoring: gamePlayed.advancedScoringEnabled);
          context.pushNamed('game-session', extra: newId);
          return false; // don't dismiss
        } else {
          // Swipe left: delete
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(l10n.confirmDeleteHistory),
              content: Text(l10n.confirmDeleteHistoryMsg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                    foregroundColor: Theme.of(ctx).colorScheme.onError,
                  ),
                  child: Text(l10n.delete),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            removeHistoryEntry(ref, gamePlayed.id);
            return true;
          }
          return false;
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.replay, color: AppColors.secondary),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: Card(
        color: AppColors.surfaceContainerLow,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.sm,
        ),
        child: InkWell(
          onTap: () {
            context.pushNamed('results', extra: gamePlayed.id);
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: gameColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      game?.icon ?? '🎲',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game?.name ?? 'Partie',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _playerAvatars(gamePlayed.playerIds, players, gameColor),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.playersCount(gamePlayed.playerIds.length),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('dd/MM/yy').format(gamePlayed.date),
                      style: theme.textTheme.labelSmall,
                    ),
                    if (gamePlayed.duration != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(gamePlayed.duration!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.outlineVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _playerAvatars(
    List<String> playerIds,
    List<Player> players,
    Color color,
  ) {
    final maxDisplay = 5;
    final display = playerIds.take(maxDisplay).toList();
    final overflow = playerIds.length - maxDisplay;

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
            final player = players.where((p) => p.id == entry.value).firstOrNull;
            return Positioned(
              left: (entry.key * 18).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: player?.color ?? color,
                  child: Text(
                    player?.name.isNotEmpty == true ? player!.name[0].toUpperCase() : '?',
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

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h${minutes.toString().padLeft(2, '0')}';
    return '${minutes}min';
  }
}
