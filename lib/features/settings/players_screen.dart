import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/player.dart';
import '../../../core/ui/confirm_dialog.dart';

const _uuid = Uuid();

class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = AppColors.playerColors[0];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(allPlayersProvider);
    final sortedPlayers = [...players]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.players)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.sm,
                AppSpacing.marginMobile, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.playersSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: l10n.playerName),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedPlayers.isEmpty
                ? Center(
                    child: Text(
                      l10n.playersCount(0),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.outline,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                    ),
                    itemCount: sortedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = sortedPlayers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: player.color.withValues(alpha: 0.2),
                            child: Text(
                              player.avatar ?? (player.name.isNotEmpty
                                  ? player.name[0].toUpperCase()
                                  : '?'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: player.color,
                              ),
                            ),
                          ),
                          title: Text(player.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: l10n.confirmDeletePlayer,
                                message: l10n.confirmDeletePlayerMsg,
                                confirmLabel: l10n.delete,
                                cancelLabel: l10n.cancel,
                              );
                              if (confirmed) deletePlayer(ref, player.id);
                            },
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onTap: () => _showEditPlayerDialog(context, ref, player),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final player = Player(
      id: _uuid.v4(),
      name: name,
      color: _selectedColor,
    );
    addPlayer(ref, player);
    _nameController.clear();
    _selectedColor = AppColors.playerColors[
        (ref.read(allPlayersProvider).length) % AppColors.playerColors.length];
  }

  void _showEditPlayerDialog(BuildContext context, WidgetRef ref, Player player) {
    final nameCtrl = TextEditingController(text: player.name);
    Color selectedColor = player.color;
    String avatar = player.avatar ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Modifier le joueur'),
          content: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 16),
              const Text('Avatar (emoji)', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: ['🧑','👩','🧔','👶','👴','👵','🦸','🧙','🐱','🐶','🦊','🐸','🐻','🐼','🦁','🐯'].map((e) => GestureDetector(
                  onTap: () => setDialogState(() => avatar = avatar == e ? '' : e),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: avatar == e ? selectedColor.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 22)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Couleur', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.playerColors.map((c) => GestureDetector(
                  onTap: () => setDialogState(() => selectedColor = c),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selectedColor == c
                          ? Border.all(color: AppColors.onSurface, width: 3)
                          : Border.all(color: c.withValues(alpha: 0.3), width: 1),
                    ),
                    child: selectedColor == c
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                )).toList(),
              ),
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                updatePlayer(ref, player.id, player.copyWith(
                  name: name,
                  color: selectedColor,
                  avatar: avatar.isEmpty ? null : avatar,
                ));
                Navigator.of(ctx).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
