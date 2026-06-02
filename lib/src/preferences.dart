import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Persistent SDK preference storage.
class MeiroPreferences {
  /// Creates preference storage.
  MeiroPreferences(this._sharedPreferences, {Uuid uuid = const Uuid()})
      : _uuid = uuid;

  final SharedPreferences _sharedPreferences;
  final Uuid _uuid;

  /// Loads SharedPreferences and returns SDK preference storage.
  static Future<MeiroPreferences> create() async {
    return MeiroPreferences(await SharedPreferences.getInstance());
  }

  /// Current anonymous user id.
  String get userId {
    final existing = _sharedPreferences.getString(_userIdKey);
    if (existing != null) {
      return existing;
    }
    final generated = _uuid.v4();
    _sharedPreferences.setString(_userIdKey, generated);
    return generated;
  }

  /// Firebase registration token.
  String? get fcmToken => _sharedPreferences.getString(_fcmTokenKey);

  set fcmToken(String? value) {
    if (value == null) {
      _sharedPreferences.remove(_fcmTokenKey);
    } else {
      _sharedPreferences.setString(_fcmTokenKey, value);
    }
  }

  /// Whether this is the first launch after install.
  bool get freshInstall => _sharedPreferences.getBool(_freshInstallKey) ?? true;

  set freshInstall(bool value) {
    _sharedPreferences.setBool(_freshInstallKey, value);
  }

  /// Resets anonymous identity.
  void resetIdentity() {
    _sharedPreferences.remove(_userIdKey);
  }

  static const _userIdKey = 'io.meiro.sdk.user_uuid';
  static const _fcmTokenKey = 'io.meiro.sdk.fcm_token';
  static const _freshInstallKey = 'io.meiro.sdk.fresh_install';
}
