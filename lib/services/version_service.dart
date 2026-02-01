import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static String _version = '1.0.0';
  static String _buildNumber = '1';

  static String get version => _version;
  static String get buildNumber => _buildNumber;
  static String get fullVersion => '$_version+$_buildNumber';

  static Future<void> init() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } catch (e) {
      // Fallback stays at default
    }
  }
}
