import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(allGroupsProvider);
    final themeMode = ref.watch(themeModeProvider);

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
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(title: l10n.data),
          _SettingsTile(
            icon: Icons.group_work_outlined,
            title: l10n.groups,
            subtitle: l10n.groupsCount(groups.length),
            onTap: () => context.pushNamed('settings-groups'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _VersionLabel(),
        ],
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '...';
        final build = snapshot.data?.buildNumber ?? '';
        return Center(
          child: Text('SCORE v$version+$build',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.outline)),
        );
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
