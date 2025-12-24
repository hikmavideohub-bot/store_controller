import 'package:shared_preferences/shared_preferences.dart';
import '../services/store_config_service.dart';

class StorePrefs {
  static const _kStoreId = 'store_id';
  static const _kSetupDone = 'setup_done';

  static Future<String?> getStoreId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kStoreId);
  }

  static Future<void> setStoreId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kStoreId, id);
    await sp.setBool(_kSetupDone, true);
  }

  static Future<bool> isSetupDone() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kSetupDone) ?? false;
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kStoreId);
    await sp.remove(_kSetupDone);
  }
}
