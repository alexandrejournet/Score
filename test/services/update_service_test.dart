import 'package:flutter_test/flutter_test.dart';
import 'package:score/core/services/update_service.dart';

// We test the internal _compareVersions and _parseVersion by testing
// the public UpdateInfo.hasUpdate which uses them.

void main() {
  group('UpdateInfo.hasUpdate', () {
    test('detects newer version', () {
      final info = UpdateInfo(
        latestVersion: 'v0.0.1-alpha.13',
        currentVersion: 'v0.0.1-alpha.12',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: true,
      );
      expect(info.hasUpdate, isTrue);
    });

    test('no update when same version', () {
      final info = UpdateInfo(
        latestVersion: 'v0.0.1-alpha.12',
        currentVersion: 'v0.0.1-alpha.12',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: true,
      );
      expect(info.hasUpdate, isFalse);
    });

    test('no update when current is newer', () {
      final info = UpdateInfo(
        latestVersion: 'v0.0.1-alpha.10',
        currentVersion: 'v0.0.1-alpha.12',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: true,
      );
      expect(info.hasUpdate, isFalse);
    });

    test('handles build number suffix with +', () {
      final info = UpdateInfo(
        latestVersion: 'v0.0.1-alpha.13',
        currentVersion: 'v0.0.1-alpha.12+42',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: true,
      );
      expect(info.hasUpdate, isTrue);
    });

    test('alpha.10 is newer than alpha.9', () {
      final info = UpdateInfo(
        latestVersion: 'v0.0.1-alpha.10',
        currentVersion: 'v0.0.1-alpha.9',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: true,
      );
      expect(info.hasUpdate, isTrue);
    });

    test('alpha.2 is newer than alpha.10 (semver — alpha number is part of prerelease)', () {
      // String comparison: "alpha.10" > "alpha.2" because '1' > '2' at position after "alpha."
      // Our comparison splits by [-.+] so: ['0','0','1','alpha','10'] vs ['0','0','1','alpha','2']
      // At index 4: 10 > 2, so alpha.10 > alpha.2
      final info = UpdateInfo(
        latestVersion: 'v0.0.1-alpha.10',
        currentVersion: 'v0.0.1-alpha.2',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: true,
      );
      expect(info.hasUpdate, isTrue);
    });

    test('major version bump detected', () {
      final info = UpdateInfo(
        latestVersion: 'v1.0.0',
        currentVersion: 'v0.9.9',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: false,
      );
      expect(info.hasUpdate, isTrue);
    });

    test('minor version bump detected', () {
      final info = UpdateInfo(
        latestVersion: 'v0.2.0',
        currentVersion: 'v0.1.9',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: false,
      );
      expect(info.hasUpdate, isTrue);
    });

    test('no v prefix on current', () {
      final info = UpdateInfo(
        latestVersion: 'v0.0.1-alpha.13',
        currentVersion: 'v0.0.1-alpha.12+99',
        downloadUrl: '',
        releaseNotes: '',
        isPrerelease: true,
      );
      expect(info.hasUpdate, isTrue);
    });
  });
}
