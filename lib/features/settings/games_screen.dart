import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/remote_games_service.dart';

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
  }

  Future<void> _loadRemote() async {
    if (_remoteGames != null && _remoteGames!.isNotEmpty) return;
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
                _TabChip(label: l10n.bank, selected: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
                const SizedBox(width: AppSpacing.sm),
                _TabChip(label: l10n.remote, selected: _tabIndex == 2, onTap: () { setState(() => _tabIndex = 2); _loadRemote(); }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _buildTabContent(l10n, filteredMy, filteredBank),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AppLocalizations l10n, List<dynamic> filteredMy, List<dynamic> filteredBank) {
    if (_tabIndex == 2) return _buildRemoteTab(l10n);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      children: [
        if (_tabIndex == 0) ...[
          if (filteredMy.isNotEmpty) ...[
            ...filteredMy.map((game) => _GameTile(
                  game: game,
                  isInMyGames: true,
                  onTap: () => context.pushNamed('game-detail', extra: game),
                  onToggle: () => removeFromMyGames(ref, game.id),
                )),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl * 3),
                child: Text(l10n.gamesCount(0),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
              ),
            ),
        ] else ...[
          if (filteredBank.isNotEmpty) ...[
            ...filteredBank.map((game) => _GameTile(
                  game: game,
                  isInMyGames: false,
                  onTap: () => context.pushNamed('game-detail', extra: game),
                  onToggle: () => addToMyGames(ref, game.id),
                )),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl * 3),
                child: Text(l10n.gamesCount(0),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildRemoteTab(AppLocalizations l10n) {
    final myGameIds = ref.watch(myGamesProvider).map((g) => g.id).toSet();
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
      itemBuilder: (context, index) {
        final rg = filtered[index];
        final alreadyAdded = customIds.any((id) => id.contains(rg.name.toLowerCase().replaceAll(' ', '-')));
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('🎲', style: TextStyle(fontSize: 20))),
            ),
            title: Text(rg.name.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ')),
            subtitle: const Text('Remote'),
            trailing: alreadyAdded
                ? const Icon(Icons.check_circle, color: AppColors.secondary)
                : TextButton(
                    onPressed: () => _addRemoteGame(rg),
                    child: Text(l10n.add),
                  ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        );
      },
    );
  }

  Future<void> _addRemoteGame(RemoteGame rg) async {
    final game = await rg.load();
    if (game == null || !mounted) return;

    final existingIds = ref.read(allGamesProvider).where((g) => g.isCustom).map((g) => g.id).toSet();
    final baseId = game.id;
    String newId = baseId;
    int counter = 1;
    while (existingIds.contains(newId)) {
      newId = '$baseId-$counter';
      counter++;
    }

    final newGame = game.copyWith(id: newId, isCustom: true);
    addGame(ref, newGame);
    addToMyGames(ref, newGame.id);
    setState(() {});
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
