import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/game_played.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/update_service.dart';
import '../../../core/ui/update_dialog.dart';
import 'widgets/active_game_card.dart';
import 'widgets/game_tab_bar.dart';
import 'widgets/history_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;
  bool _showAllInProgress = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    await Future.delayed(const Duration(seconds: 2));
    final updateInfo = await UpdateService.checkForUpdate(channel: 'alpha');
    if (updateInfo != null && updateInfo.hasUpdate && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => UpdateDialog(updateInfo: updateInfo, l10n: l10n),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(selectedTabProvider);
    final l10n = AppLocalizations.of(context);
    final activeGames = ref.watch(activeGamesProvider);

    final filteredActive = tab == 'all'
        ? activeGames
        : activeGames.where((g) => g.gameId == tab).toList();

    final displayedActive = _showAllInProgress
        ? filteredActive
        : filteredActive.take(2).toList();

    final finishedGames = ref.watch(finishedGamesProvider);
    final filteredFinished = tab == 'all'
        ? finishedGames
        : finishedGames.where((g) => g.gameId == tab).toList();

    final allForSearch = [...filteredActive, ...filteredFinished];
    final searchResults = _searchQuery.isEmpty
        ? null
        : allForSearch.where((gp) {
            final games = ref.read(allGamesProvider);
            final players = ref.read(allPlayersProvider);
            final game = games.where((g) => g.id == gp.gameId).firstOrNull;
            final gameName = game?.name.toLowerCase() ?? '';
            final playerNames = gp.playerIds
                .map((pid) =>
                    players.where((p) => p.id == pid).firstOrNull?.name.toLowerCase() ?? '')
                .join(' ');
            final query = _searchQuery.toLowerCase();
            return gameName.contains(query) || playerNames.contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  border: InputBorder.none,
                  hintStyle:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
                onSubmitted: (_) => setState(() => _showSearch = false),
              )
            : Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: _showSearch && searchResults != null
          ? _buildSearchResults(context, searchResults)
          : _buildNormalView(context, displayedActive, filteredFinished, filteredActive),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('new-game'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(l10n.newGame),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, List<GamePlayed> results) {
    final l10n = AppLocalizations.of(context);
    return results.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppColors.outlineVariant),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.noResults,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 100, top: AppSpacing.sm),
            itemCount: results.length,
            itemBuilder: (context, index) => HistoryCard(gamePlayed: results[index]),
          );
  }

  Widget _buildNormalView(
    BuildContext context,
    List<GamePlayed> displayedActive,
    List<GamePlayed> filteredFinished,
    List<GamePlayed> allActive,
  ) {
    final l10n = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    if (isWide) {
      return _buildWideView(context, l10n, displayedActive, filteredFinished, allActive);
    }

    return _buildNarrowView(context, l10n, displayedActive, filteredFinished, allActive);
  }

  Widget _buildWideView(
    BuildContext context,
    AppLocalizations l10n,
    List<GamePlayed> displayedActive,
    List<GamePlayed> filteredFinished,
    List<GamePlayed> allActive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GameTabBar(),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildColumn(context, l10n, displayedActive, allActive, isActive: true),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _buildColumn(context, l10n, filteredFinished, allActive, isActive: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColumn(
    BuildContext context,
    AppLocalizations l10n,
    List<GamePlayed> items,
    List<GamePlayed> allActive, {
    required bool isActive,
  }) {
    if (isActive) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (items.isNotEmpty) ...[
            _SectionHeader(
              title: l10n.inProgress,
              action: allActive.length > 2
                  ? TextButton(
                      onPressed: () => setState(() => _showAllInProgress = !_showAllInProgress),
                      child: Text(_showAllInProgress ? l10n.viewLess : l10n.viewAll),
                    )
                  : null,
            ),
            ...items.map((gp) => ActiveGameCard(gamePlayed: gp)),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl * 3),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.sports_esports_outlined, size: 48, color: AppColors.outlineVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.noGames, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
                  ],
                ),
              ),
            ),
        ],
      );
    } else {
      return items.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl * 3),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.history, size: 48, color: AppColors.outlineVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.noGames, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                _SectionHeader(title: l10n.recentHistory),
                ...items.map((gp) => HistoryCard(gamePlayed: gp)),
              ],
            );
    }
  }

  Widget _buildNarrowView(
    BuildContext context,
    AppLocalizations l10n,
    List<GamePlayed> displayedActive,
    List<GamePlayed> filteredFinished,
    List<GamePlayed> allActive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GameTabBar(),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              if (displayedActive.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.inProgress,
                  action: allActive.length > 2
                      ? TextButton(
                          onPressed: () => setState(() => _showAllInProgress = !_showAllInProgress),
                          child: Text(_showAllInProgress ? l10n.viewLess : l10n.viewAll),
                        )
                      : null,
                ),
                ...displayedActive.map((gp) => ActiveGameCard(gamePlayed: gp)),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (filteredFinished.isNotEmpty) ...[
                _SectionHeader(title: l10n.recentHistory),
                ...filteredFinished.map((gp) => HistoryCard(gamePlayed: gp)),
              ],
              if (displayedActive.isEmpty && filteredFinished.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl * 3),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.sports_esports_outlined, size: 64, color: AppColors.outlineVariant),
                        const SizedBox(height: AppSpacing.md),
                        Text(l10n.noGames,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.outline)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(l10n.startFirstGame,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.outlineVariant)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const Spacer(),
          ?action,
        ],
      ),
    );
  }
}
