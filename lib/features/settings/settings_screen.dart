import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/update_service.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/ui/update_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(allGroupsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final hapticEnabled = ref.watch(hapticEnabledProvider);
    final updateChannel = ref.watch(updateChannelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(l10n.settingsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
          ),
          _SectionTitle(title: l10n.general),
          _SettingsTile(
            icon: Icons.bar_chart,
            title: l10n.statistics,
            onTap: () => context.pushNamed('statistics'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(l10n.darkMode),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              final mode = value ? ThemeMode.dark : ThemeMode.light;
              ref.read(themeModeProvider.notifier).state = mode;
              saveTheme(ref, mode);
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text(l10n.hapticFeedback),
            value: hapticEnabled,
            onChanged: (value) {
              ref.read(hapticEnabledProvider.notifier).state = value;
              PersistenceService.saveHapticEnabled(value);
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: Text(l10n.updateChannel),
            subtitle: Text(updateChannel == 'alpha' ? 'Alpha' : 'Stable'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'stable', label: Text('Stable')),
                ButtonSegment(value: 'alpha', label: Text('Alpha')),
              ],
              selected: {updateChannel},
              onSelectionChanged: (v) {
                ref.read(updateChannelProvider.notifier).state = v.first;
                PersistenceService.saveUpdateChannel(v.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(title: l10n.data),
          _SettingsTile(
            icon: Icons.add_circle_outline,
            title: l10n.createGame,
            onTap: () => context.pushNamed('create-game'),
          ),
          _SettingsTile(
            icon: Icons.group_work_outlined,
            title: l10n.groups,
            subtitle: l10n.groupsCount(groups.length),
            onTap: () => context.pushNamed('settings-groups'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(title: _t(l10n, 'About', 'À propos')),
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: _checking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.system_update),
              title: Text(l10n.checkForUpdates),
              subtitle: _VersionSubtitle(),
              trailing: _checking ? null : const Icon(Icons.chevron_right),
              onTap: _checking ? null : _checkForUpdate,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _checkForUpdate() async {
    setState(() => _checking = true);

    try {
      final channel = ref.read(updateChannelProvider);
      final updateInfo = await UpdateService.checkForUpdate(channel: channel);
      if (!mounted) return;

      if (updateInfo != null && updateInfo.hasUpdate) {
        final l10n = AppLocalizations.of(context);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => UpdateDialog(updateInfo: updateInfo, l10n: l10n),
          );
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.upToDate} (${updateInfo?.latestVersion ?? "?"})'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.updateCheckFailed}: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  String _t(AppLocalizations l10n, String en, String fr) {
    return l10n.locale.languageCode == 'fr' ? fr : en;
  }
}

class _VersionSubtitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(updateChannelProvider);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '...';
        final build = snapshot.data?.buildNumber ?? '';
        return Text('SCORE v$version+$build (${channel == 'alpha' ? 'alpha' : 'stable'})',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline));
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
