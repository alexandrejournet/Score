import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/game.dart';

const _uuid = Uuid();

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _rulesController = TextEditingController();
  ScoreType _scoreType = ScoreType.points;
  int _minPlayers = 2;
  int _maxPlayers = 4;
  Color _color = AppColors.playerColors[0];
  final List<_CategoryEntry> _categories = [];

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createGame)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.gameName,
              hintText: 'Mon Jeu',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _iconController,
            decoration: InputDecoration(
              labelText: l10n.icon,
              hintText: '🎲',
            ),
            maxLength: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.scoreTypeLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ScoreType>(
            segments: [
              ButtonSegment(value: ScoreType.points, label: Text(l10n.points)),
              ButtonSegment(value: ScoreType.categories, label: Text(l10n.categories)),
            ],
            selected: {_scoreType},
            onSelectionChanged: (v) => setState(() => _scoreType = v.first),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(l10n.minPlayers, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: TextEditingController(text: '$_minPlayers'),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (v) => _minPlayers = int.tryParse(v) ?? 2,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(l10n.maxPlayers, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: TextEditingController(text: '$_maxPlayers'),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (v) => _maxPlayers = int.tryParse(v) ?? 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.colorLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: AppColors.playerColors.map((c) => GestureDetector(
              onTap: () => setState(() => _color = c),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: _color == c
                      ? Border.all(color: AppColors.onSurface, width: 3)
                      : null,
                ),
              ),
            )).toList(),
          ),
          if (_scoreType == ScoreType.categories) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text(l10n.categories, style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _categories.add(_CategoryEntry())),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.add),
                ),
              ],
            ),
            ..._categories.asMap().entries.map((e) => _buildCategoryRow(e.key, e.value)),
          ],
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _rulesController,
            decoration: InputDecoration(labelText: l10n.rules),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isNotEmpty ? _save : null,
              child: Text(l10n.create),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(int index, _CategoryEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: entry.labelController,
              decoration: InputDecoration(hintText: 'Label', isDense: true),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 60,
            child: TextField(
              controller: entry.maxController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'Max', isDense: true),
            ),
          ),
          Checkbox(
            value: entry.hasMultiplier,
            onChanged: (v) => setState(() => entry.hasMultiplier = v ?? false),
          ),
          const Text('×', style: TextStyle(fontSize: 12)),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => setState(() => _categories.removeAt(index)),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final game = Game(
      id: 'custom-${_uuid.v4().substring(0, 8)}',
      name: name,
      scoreType: _scoreType,
      minPlayers: _minPlayers,
      maxPlayers: _maxPlayers,
      icon: _iconController.text.trim().isEmpty ? null : _iconController.text.trim(),
      color: _color,
      isCustom: true,
      categories: _categories
          .where((c) => c.labelController.text.trim().isNotEmpty)
          .map((c) => ScoringCategory(
                label: c.labelController.text.trim(),
                maxValue: int.tryParse(c.maxController.text) ?? 99,
                hasMultiplier: c.hasMultiplier,
              ))
          .toList(),
      rules: _rulesController.text.trim().isEmpty ? null : _rulesController.text.trim(),
    );

    addGame(ref, game);
    if (context.canPop()) context.pop();
  }
}

class _CategoryEntry {
  final labelController = TextEditingController();
  final maxController = TextEditingController();
  bool hasMultiplier = false;
}
