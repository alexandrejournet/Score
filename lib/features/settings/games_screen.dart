import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myGames = ref.watch(myGamesProvider);
    final bank = ref.watch(gameBankProvider);

    final filteredMy = _searchQuery.isEmpty
        ? myGames
        : myGames.where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    final filteredBank = _searchQuery.isEmpty
        ? bank
        : bank.where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.games)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.sm,
                AppSpacing.marginMobile, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.gamesSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.sm,
                AppSpacing.marginMobile, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                if (filteredMy.isNotEmpty) ...[
                  Text(l10n.myGames, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...filteredMy.map((game) => _GameTile(
                        game: game,
                        isInMyGames: true,
                        onTap: () => context.pushNamed('game-detail', extra: game),
                        onToggle: () => removeFromMyGames(ref, game.id),
                      )),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (filteredBank.isNotEmpty) ...[
                  Text(l10n.bank, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...filteredBank.map((game) => _GameTile(
                        game: game,
                        isInMyGames: false,
                        onTap: () => context.pushNamed('game-detail', extra: game),
                        onToggle: () => addToMyGames(ref, game.id),
                      )),
                ],
                if (filteredMy.isEmpty && filteredBank.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl * 3),
                      child: Text(l10n.gamesCount(0),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final dynamic game;
  final bool isInMyGames;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _GameTile({
    required this.game,
    required this.isInMyGames,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: game.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(game.icon ?? '🎲', style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(game.name),
        subtitle: Text(l10n.playerRange(game.minPlayers, game.maxPlayers)),
        trailing: isInMyGames
            ? IconButton(
                icon: const Icon(Icons.check_circle, color: AppColors.secondary),
                onPressed: onToggle,
              )
            : IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onToggle,
              ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onTap: onTap,
      ),
    );
  }
}
