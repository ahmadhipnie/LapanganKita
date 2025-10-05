import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _preferences;

  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberMe = 'remember_me';

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _preferences?.setString(_keyUserData, json.encode(userData));
    await _preferences?.setBool(_keyIsLoggedIn, true);
  }

  // Get user data
  Map<String, dynamic>? getUserData() {
    final userDataString = _preferences?.getString(_keyUserData);
    if (userDataString != null) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Check if user is logged in
   bool get isLoggedIn {
    final loggedIn = _preferences?.getBool(_keyIsLoggedIn) ?? false;
    final userData = getUserData();
    
    if (userData != null) {
    }
    
    return loggedIn && userData != null;
  }

  String? getUserRole() {
    final userData = getUserData();
    return userData?['role']?.toString();
  }

  // Save remember me preference
  Future<void> setRememberMe(bool value) async {
    await _preferences?.setBool(_keyRememberMe, value);
  }

  // Get remember me preference
  bool get rememberMe => _preferences?.getBool(_keyRememberMe) ?? false;

  // Clear all data (logout)
  Future<void> clearAllData() async {
    await _preferences?.clear();
  }

  // Clear only user data but keep remember me
  Future<void> clearUserData() async {
    await _preferences?.remove(_keyUserData);
    await _preferences?.setBool(_keyIsLoggedIn, false);
  }
}