import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/game_played.dart';
import '../../../core/models/player.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SkyjoGameScreen extends ConsumerStatefulWidget {
  final String gamePlayedId;

  const SkyjoGameScreen({super.key, required this.gamePlayedId});

  @override
  ConsumerState<SkyjoGameScreen> createState() => _SkyjoGameScreenState();
}

class _SkyjoGameScreenState extends ConsumerState<SkyjoGameScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String? _finisherId;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.watch(gameDataVersionProvider);
    final gamePlayed = ref.read(gamePlayedRepositoryProvider).getById(widget.gamePlayedId);
    final players = ref.watch(allPlayersProvider);

    if (gamePlayed == null) {
      return Scaffold(body: Center(child: Text(l10n.sessionNotFound)));
    }

    final gamePlayers = gamePlayed.playerIds
        .map((id) => players.where((player) => player.id == id).firstOrNull)
        .whereType<Player>()
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skyjo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.roundHistory,
            onPressed: () => _showRoundHistory(context, gamePlayed, gamePlayers),
          ),
        ],
      ),
      body: Column(
        children: [
          _RoundSummary(round: gamePlayed.rounds.length + 1, players: gamePlayers, scores: gamePlayed.scores),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              children: [
                Text(l10n.roundScore, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                ...gamePlayers.map((player) => _scoreRow(context, player)),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.roundEndedBy, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: gamePlayers.map((player) {
                    return ChoiceChip(
                      label: Text(player.name),
                      selected: _finisherId == player.id,
                      onSelected: (_) => setState(() => _finisherId = player.id),
                    );
                  }).toList(),
                ),
                if (_finisherId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(l10n.noFinisher,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.error)),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finisherId == null ? null : () => _validateRound(gamePlayed),
                  child: Text(l10n.validateRound),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreRow(BuildContext context, Player player) {
    final controller = _controllers.putIfAbsent(player.id, () => TextEditingController());
    final total = ref.read(gamePlayedRepositoryProvider).getById(widget.gamePlayedId)?.scores[player.id] ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: player.color,
              child: Text(player.avatar ?? player.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(player.name, style: Theme.of(context).textTheme.bodyLarge)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${AppLocalizations.of(context).cumulativeScore}: $total',
                    style: Theme.of(context).textTheme.labelSmall),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    decoration: const InputDecoration(hintText: '0'),
                    style: GoogleFonts.bricolageGrotesque(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _validateRound(GamePlayed gamePlayed) {
    final roundScores = <String, int>{};
    for (final playerId in gamePlayed.playerIds) {
      roundScores[playerId] = int.tryParse(_controllers[playerId]?.text ?? '') ?? 0;
    }
    final gameOver = validateSkyjoRound(ref, widget.gamePlayedId, roundScores, _finisherId!);
    if (!mounted) return;
    if (gameOver) {
      context.pushNamed('results', extra: widget.gamePlayedId);
    } else {
      setState(() {
        _finisherId = null;
        for (final controller in _controllers.values) {
          controller.clear();
        }
      });
    }
  }

  void _showRoundHistory(BuildContext context, GamePlayed gamePlayed, List<Player> players) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        shrinkWrap: true,
        children: [
          Text(l10n.roundHistory, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          ...gamePlayed.rounds.asMap().entries.map((entry) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.roundNumber} ${entry.key + 1}', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    ...entry.value.scores.entries.map((score) {
                      final player = players.where((p) => p.id == score.key).firstOrNull;
                      return Row(
                        children: [
                          Expanded(child: Text(player?.name ?? '?')),
                          Text('${score.value} ${l10n.pts}'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RoundSummary extends StatelessWidget {
  final int round;
  final List<Player> players;
  final Map<String, int> scores;

  const _RoundSummary({required this.round, required this.players, required this.scores});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text('${l10n.roundNumber} $round', style: Theme.of(context).textTheme.labelLarge),
          const Spacer(),
          ...players.take(4).map((player) => Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Text('${player.name}: ${scores[player.id] ?? 0}', style: Theme.of(context).textTheme.labelSmall),
              )),
        ],
      ),
    );
  }
}
