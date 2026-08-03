import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/models/game.dart';
import '../../core/l10n/app_localizations.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;
  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: game.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      game.icon ?? '🎲',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  game.name,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 16, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      l10n.playerRange(game.minPlayers, game.maxPlayers),
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.outline),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.scoreboard_outlined, size: 16, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      _scoreTypeLabel(game.scoreType, l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (game.rules != null && game.rules!.isNotEmpty) ...[
            Text(l10n.rules, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  game.rules!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (game.scoreType == ScoreType.categories && game.categories.isNotEmpty) ...[
            Text(l10n.scoring, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: game.categories.asMap().entries.map((entry) {
                    final cat = entry.value;
                    final isLast = entry.key == game.categories.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.label, style: theme.textTheme.bodyLarge),
                                if (cat.description != null)
                                  Text(cat.description!,
                                      style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ),
                          if (cat.hasMultiplier)
                            Icon(Icons.grid_view, size: 16, color: AppColors.outline),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.pushNamed('new-game'),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.launchGame),
            ),
          ),
        ),
      ),
    );
  }

  String _scoreTypeLabel(ScoreType type, AppLocalizations l10n) {
    switch (type) {
      case ScoreType.points:
        return 'Points';
      case ScoreType.time:
        return 'Temps';
      case ScoreType.categories:
        return l10n.gridLabel;
      case ScoreType.rounds:
        return l10n.roundNumber;
      case ScoreType.custom:
        return 'Custom';
    }
  }
}
