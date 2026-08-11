import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/remote_games_service.dart';
import '../../../core/models/game.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _tabIndex = 0;
  List<RemoteGame>? _remoteGames;
  bool _loadingRemote = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRemote();
  }

  Future<void> _loadRemote() async {
    if (_remoteGames != null && _remoteGames!.isNotEmpty) return;
    if (_loadingRemote) return;
    setState(() => _loadingRemote = true);
    final games = await RemoteGamesService.fetchGames();
    if (mounted) {
      setState(() {
        _remoteGames = games;
        _loadingRemote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myGames = ref.watch(myGamesProvider);

    final filteredMy = _searchQuery.isEmpty
        ? myGames
        : myGames.where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

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
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            child: Row(
              children: [
                _TabChip(label: l10n.myGames, selected: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                const SizedBox(width: AppSpacing.sm),
                _TabChip(label: l10n.remote, selected: _tabIndex == 1, onTap: () { setState(() => _tabIndex = 1); _loadRemote(); }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _tabIndex == 0 ? _buildMyGames(l10n, filteredMy) : _buildRemoteTab(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildMyGames(AppLocalizations l10n, List<dynamic> filteredMy) {
    if (filteredMy.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl * 3),
          child: Text(l10n.gamesCount(0),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      itemCount: filteredMy.length,
      itemBuilder: (context, index) {
        final game = filteredMy[index];
        final isBuiltIn = !game.isCustom;
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: Container(
              width: 40, height: 40,
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
            trailing: isBuiltIn
                ? IconButton(
                    icon: const Icon(Icons.check_circle, color: AppColors.secondary),
                    onPressed: () => removeFromMyGames(ref, game.id),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => deleteGame(ref, game.id),
                  ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            onTap: () => context.pushNamed('game-detail', extra: game),
          ),
        );
      },
    );
  }

  Widget _buildRemoteTab(AppLocalizations l10n) {
    final customIds = ref.watch(allGamesProvider).where((g) => g.isCustom).map((g) => g.id).toSet();

    if (_loadingRemote) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_remoteGames == null || _remoteGames!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.noRemoteGames,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
          ],
        ),
      );
    }

    final filtered = _searchQuery.isEmpty
        ? _remoteGames!
        : _remoteGames!.where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _RemoteGameTile(
        remoteGame: filtered[index],
        alreadyAdded: (game) => customIds.contains(game.id) || ref.read(myGamesProvider).any((g) => g.id == game.id),
        onAdd: (game) {
          final existingIds = ref.read(allGamesProvider).where((g) => g.isCustom).map((g) => g.id).toSet();
          String newId = game.id;
          int counter = 1;
          while (existingIds.contains(newId)) {
            newId = '${game.id}-$counter';
            counter++;
          }
          final newGame = game.copyWith(id: newId, isCustom: true);
          addGame(ref, newGame);
          addToMyGames(ref, newGame.id);
        },
      ),
    );
  }
}

class _RemoteGameTile extends StatefulWidget {
  final RemoteGame remoteGame;
  final bool Function(Game) alreadyAdded;
  final void Function(Game) onAdd;

  const _RemoteGameTile({required this.remoteGame, required this.alreadyAdded, required this.onAdd});

  @override
  State<_RemoteGameTile> createState() => _RemoteGameTileState();
}

class _RemoteGameTileState extends State<_RemoteGameTile> {
  Game? _game;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    if (_loading) return;
    setState(() => _loading = true);
    final game = await widget.remoteGame.load();
    if (mounted) {
      setState(() {
        _game = game;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final added = _game != null && widget.alreadyAdded(_game!);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: (_game?.color ?? AppColors.primary).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(_game?.icon ?? '🎲', style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(_game?.name ?? widget.remoteGame.name.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ')),
        subtitle: _game != null
            ? Text(l10n.playerRange(_game!.minPlayers, _game!.maxPlayers))
            : const Text('...'),
        trailing: added
            ? const Icon(Icons.check_circle, color: AppColors.secondary)
            : TextButton(
                onPressed: _game != null ? () => widget.onAdd(_game!) : null,
                child: Text(l10n.add),
              ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? AppColors.onPrimary : AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        )),
      ),
    );
  }
}
