import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/app_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(allGamesProvider);
    final players = ref.watch(allPlayersProvider);
    final finished = ref.watch(finishedGamesProvider);

    final totalParties = finished.length;
    final totalHours = finished
        .where((g) => g.duration != null)
        .fold<Duration>(Duration.zero, (sum, g) => sum + g.duration!);

    final gameCounts = <String, int>{};
    final playerWins = <String, int>{};
    final playerGames = <String, int>{};

    for (final gp in finished) {
      final game = games.where((g) => g.id == gp.gameId).firstOrNull;
      gameCounts[game?.name ?? 'Inconnu'] =
          (gameCounts[game?.name ?? 'Inconnu'] ?? 0) + 1;

      for (final pid in gp.playerIds) {
        playerGames[pid] = (playerGames[pid] ?? 0) + 1;
      }
      if (gp.winnerId != null) {
        playerWins[gp.winnerId!] = (playerWins[gp.winnerId!] ?? 0) + 1;
      }
    }

    final sortedGames = gameCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sortedPlayers = playerGames.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: finished.isEmpty
          ? Center(
              child: Text(
                l10n.noPlayStats,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.outline,
                    ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                _StatCard(
                  icon: Icons.sports_esports,
                  label: l10n.partiesPlayed,
                  value: '$totalParties',
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                _StatCard(
                  icon: Icons.timer,
                  label: l10n.playTime,
                  value: _formatDuration(totalHours),
                  color: AppColors.secondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (gameCounts.isNotEmpty) ...[
                  Text(l10n.mostPlayedGames,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...sortedGames.take(5).map((e) => _RankRow(
                        label: e.key,
                        value: '${e.value} ${l10n.partieWord}',
                        color: AppColors.primary,
                      )),
                ],
                if (playerWins.isNotEmpty && sortedPlayers.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.playersStats,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...sortedPlayers.take(10).map((e) {
                    final player =
                        players.where((p) => p.id == e.key).firstOrNull;
                    final wins = playerWins[e.key] ?? 0;
                    return _RankRow(
                      label: player?.name ?? 'Inconnu',
                      value:
                          '${e.value} ${l10n.partieWord} · $wins ${l10n.victoryWord}',
                      color: AppColors.secondary,
                    );
                  }),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    return '$minutes min';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
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

class _RankRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RankRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
