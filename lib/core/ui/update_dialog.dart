import 'package:flutter/material.dart';
import 'package:score/core/services/update_service.dart';
import 'package:score/core/theme/app_colors.dart';
import 'package:score/core/theme/app_spacing.dart';
import 'package:score/core/l10n/app_localizations.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final AppLocalizations l10n;

  const UpdateDialog({super.key, required this.updateInfo, required this.l10n});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
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
    ).then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }
}
