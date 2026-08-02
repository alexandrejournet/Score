import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/game_played.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/update_service.dart';
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
    final updateInfo = await UpdateService.checkForUpdate();
    if (updateInfo != null && updateInfo.hasUpdate && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => _UpdateDialog(updateInfo: updateInfo, l10n: l10n),
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

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final AppLocalizations l10n;

  const _UpdateDialog({required this.updateInfo, required this.l10n});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          const Icon(Icons.system_update, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(widget.l10n.updateAvailable),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.l10n.updateMessage),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${widget.updateInfo.currentVersion} → ${widget.updateInfo.latestVersion}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (widget.updateInfo.isPrerelease) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Pre-release',
                  style: TextStyle(fontSize: 12, color: AppColors.tertiaryContainer)),
            ),
          ],
          if (widget.updateInfo.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(widget.updateInfo.releaseNotes,
                style: Theme.of(context).textTheme.bodySmall),
          ],
          if (_downloading) ...[
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: AppSpacing.sm),
            Text('${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        if (!_downloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(widget.l10n.later),
          ),
        if (!_downloading)
          FilledButton(
            onPressed: _startDownload,
            child: Text(widget.l10n.update),
          ),
      ],
    );
  }

  void _startDownload() {
    setState(() {
      _downloading = true;
      _error = null;
    });

    UpdateService.downloadAndInstall(
      widget.updateInfo,
      (progress) => setState(() => _progress = progress),
      (error) => setState(() {
        _error = error;
        _downloading = false;
      }),
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
