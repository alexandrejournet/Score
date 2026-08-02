import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool isPrerelease;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isPrerelease,
  });

  bool get hasUpdate => latestVersion != currentVersion;
}

class UpdateService {
  static const _owner = 'alexandrejournet';
  static const _repo = 'Score';
  static const _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = 'v${packageInfo.version}';

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) return null;

      final releases = jsonDecode(response.body) as List;
      if (releases.isEmpty) return null;

      final latest = releases.first as Map<String, dynamic>;
      final latestTag = latest['tag_name'] as String;
      final isPrerelease = latest['prerelease'] as bool;
      final releaseNotes = latest['body'] as String? ?? '';

      String? apkUrl;
      final assets = latest['assets'] as List? ?? [];
      for (final asset in assets) {
        final name = asset['name'] as String;
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String;
          break;
        }
      }

      if (latestTag == currentVersion) return null;

      return UpdateInfo(
        latestVersion: latestTag,
        currentVersion: currentVersion,
        downloadUrl: apkUrl ?? latest['html_url'] as String,
        releaseNotes: releaseNotes,
        isPrerelease: isPrerelease,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> downloadAndInstall(
    UpdateInfo updateInfo,
    void Function(double progress) onProgress,
    void Function(String error) onError,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/Score-${updateInfo.latestVersion}.apk';
      final file = File(filePath);

      final request = http.Request('GET', Uri.parse(updateInfo.downloadUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        onError('Download failed: ${response.statusCode}');
        return;
      }

      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;
      final sink = file.openWrite();

      await response.stream.listen(
        (chunk) {
          sink.add(chunk);
          downloadedBytes += chunk.length;
          if (totalBytes > 0) {
            onProgress(downloadedBytes / totalBytes);
          }
        },
      ).asFuture();

      await sink.close();

      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        onError('Could not open APK: ${result.message}');
      }
    } catch (e) {
      onError(e.toString());
    }
  }
}
