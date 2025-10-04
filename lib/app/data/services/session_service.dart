import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class SessionService extends GetxService {
  SessionService(this._prefs);

  final SharedPreferences _prefs;

  static const String _rememberMeKey = 'remember_me';
  static const String _userKey = 'remembered_user';

  bool get isRemembered => _prefs.getBool(_rememberMeKey) ?? false;

  UserModel? get rememberedUser {
    final raw = _prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> persistUser(UserModel user) async {
    await _prefs.setBool(_rememberMeKey, true);
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearRememberedUser() async {
    await _prefs.remove(_rememberMeKey);
    await _prefs.remove(_userKey);
  }
}
