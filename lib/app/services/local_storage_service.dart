// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LocalStorageService extends GetxService {
//   static LocalStorageService get instance => Get.find<LocalStorageService>();

//   late SharedPreferences? _preferences;

//   // Keys - Tetap sama dengan punya Anda
//   static const String _keyUserData = 'user_data';
//   static const String _keyIsLoggedIn = 'is_logged_in';
//   static const String _keyRememberMe = 'remember_me';

//   // Initialize service
//   static Future<LocalStorageService> init() async {
//     final service = Get.put(LocalStorageService());
//     await service._initialize();
//     return service;
//   }

//   Future<void> _initialize() async {
//     _preferences = await SharedPreferences.getInstance();
//   }

//   // ========== EXISTING FUNCTIONALITY (Tetap Sama) ==========

//   // Save user data
//   Future<void> saveUserData(Map<String, dynamic> userData) async {
//     await _preferences!.setString(_keyUserData, json.encode(userData));
//     await _preferences!.setBool(_keyIsLoggedIn, true);
//   }

//   // Get user data
//   Map<String, dynamic>? getUserData() {
//     if (_preferences == null) {
//       print('LocalStorageService not initialized yet!');
//       return null;
//     }

//     final userDataString = _preferences!.getString(_keyUserData);
//     if (userDataString != null) {
//       try {
//         return json.decode(userDataString) as Map<String, dynamic>;
//       } catch (e) {
//         print('Error decoding user data: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   // Check if user is logged in
//   bool get isLoggedIn {
//     if (_preferences == null) return false;

//     final loggedIn = _preferences!.getBool(_keyIsLoggedIn) ?? false;
//     final userData = getUserData();
//     return loggedIn && userData != null;
//   }

//   String? getUserRole() {
//     if (_preferences == null) return null;

//     final userData = getUserData();
//     return userData?['role']?.toString();
//   }

//   String get userRole {
//     return getUserRole() ?? '';
//   }

//   // ========== REMEMBER ME (Dari SessionService) ==========

//   // Save remember me preference
//   Future<void> setRememberMe(bool value) async {
//     await _preferences!.setBool(_keyRememberMe, value);
//   }

//   // Get remember me preference
//   bool get rememberMe {
//     if (_preferences == null) return false;
//     return _preferences!.getBool(_keyRememberMe) ?? false;
//   }

//   // Clear all data (logout)
//   Future<void> clearAllData() async {
//     await _preferences!.clear();
//   }

//   // Clear only user data but keep remember me
//   Future<void> clearUserData() async {
//     await _preferences!.remove(_keyUserData);
//     await _preferences!.remove(_keyIsLoggedIn);
//   }

//   // ========== SIMPLE USER INFO ==========

//   String get userName => getUserData()?['name']?.toString() ?? '';
//   String get userEmail => getUserData()?['email']?.toString() ?? '';
// }


import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService extends GetxService {
  static LocalStorageService get instance => Get.find<LocalStorageService>();

  SharedPreferences? _preferences;

  // Keys
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyToken = 'user_token';
  static const String _keyRefreshToken = 'refresh_token';

  // Initialize service
  static Future<LocalStorageService> init() async {
    final service = Get.put(LocalStorageService());
    await service._initialize();
    return service;
  }

  Future<void> _initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // ========== SAFE GETTERS ==========

  /// Get user data as Map
  Map<String, dynamic>? getUserData() {
    if (_preferences == null) {
      print('LocalStorageService not initialized yet!');
      return null;
    }
    
    final userDataString = _preferences!.getString(_keyUserData);
    if (userDataString != null) {
      try {
        return json.decode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding user data: $e');
        return null;
      }
    }
    return null;
  }

  /// Check if user is logged in
  bool get isLoggedIn {
    if (_preferences == null) return false;
    
    final loggedIn = _preferences!.getBool(_keyIsLoggedIn) ?? false;
    final userData = getUserData();
    return loggedIn && userData != null;
  }

  /// Get user role
  String? getUserRole() {
    if (_preferences == null) return null;
    
    final userData = getUserData();
    return userData?['role']?.toString();
  }

  /// Get user role as string (non-nullable)
  String get userRole => getUserRole() ?? '';

  /// Get user ID
  int get userId {
    final userData = getUserData();
    return int.tryParse(userData?['id']?.toString() ?? '0') ?? 0;
  }

  /// Get remember me preference
  bool get rememberMe {
    if (_preferences == null) return false;
    return _preferences!.getBool(_keyRememberMe) ?? false;
  }

  /// Get authentication token
  String? get token {
    if (_preferences == null) return null;
    return _preferences!.getString(_keyToken);
  }

  /// Get refresh token
  String? get refreshToken {
    if (_preferences == null) return null;
    return _preferences!.getString(_keyRefreshToken);
  }

  /// Check if token exists
  bool get hasToken => token != null && token!.isNotEmpty;

  // ========== USER INFO GETTERS ==========

  String get userName => getUserData()?['name']?.toString() ?? '';
  String get userEmail => getUserData()?['email']?.toString() ?? '';
  String? get userAvatar => getUserData()?['avatar_url']?.toString();
  String? get userPhone => getUserData()?['phone']?.toString();
  String? get userGender => getUserData()?['gender']?.toString();
  String? get userAddress => getUserData()?['address']?.toString();
  String? get userBirthdate => getUserData()?['date_of_birth']?.toString();
  String? get userAccountNumber => getUserData()?['account_number']?.toString();
  String? get userBankType => getUserData()?['bank_type']?.toString();

  // ========== USER ROLE CHECKERS ==========

  bool get isCustomer => userRole.toLowerCase() == 'user' || userRole.toLowerCase() == 'customer';
  bool get isFieldManager => userRole.toLowerCase() == 'field_manager' || userRole.toLowerCase() == 'field_owner';
  bool get isFieldAdmin => userRole.toLowerCase() == 'field_admin';

  // ========== SAFE SETTERS ==========

  /// Save complete user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (_preferences == null) {
      print('Cannot save user data: LocalStorageService not initialized');
      return;
    }
    
    await _preferences!.setString(_keyUserData, json.encode(userData));
    await _preferences!.setBool(_keyIsLoggedIn, true);
  }

  /// Save remember me preference
  Future<void> setRememberMe(bool value) async {
    if (_preferences == null) return;
    await _preferences!.setBool(_keyRememberMe, value);
  }

  /// Save authentication token
  Future<void> setToken(String token) async {
    if (_preferences == null) return;
    await _preferences!.setString(_keyToken, token);
  }

  /// Save refresh token
  Future<void> setRefreshToken(String refreshToken) async {
    if (_preferences == null) return;
    await _preferences!.setString(_keyRefreshToken, refreshToken);
  }

  /// Update specific user field
  Future<void> updateUserField(String key, dynamic value) async {
    if (_preferences == null) return;
    
    final userData = getUserData() ?? {};
    userData[key] = value;
    await saveUserData(userData);
  }

  // ========== AUTO LOGIN CREDENTIALS ==========

  /// Save credentials for auto-login (use flutter_secure_storage for production)
  Future<void> saveCredentialsForAutoLogin(String email, String password) async {
    if (_preferences == null) return;
    
    if (rememberMe) {
      await _preferences!.setString('auto_login_email', email);
      await _preferences!.setString('auto_login_password', password);
    }
  }

  /// Get saved credentials for auto-login
  Map<String, String>? getSavedCredentials() {
    if (_preferences == null) return null;
    
    if (rememberMe) {
      final email = _preferences!.getString('auto_login_email');
      final password = _preferences!.getString('auto_login_password');
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    }
    return null;
  }

  /// Clear saved credentials
  Future<void> clearSavedCredentials() async {
    if (_preferences == null) return;
    
    await _preferences!.remove('auto_login_email');
    await _preferences!.remove('auto_login_password');
  }

    Future<void> clearUserData() async {
    await _preferences!.remove(_keyUserData);
    await _preferences!.remove(_keyIsLoggedIn);
  }


  // ========== DATA MANAGEMENT ==========

  /// Clear all authentication data (logout)
  Future<void> clearAuthData() async {
    if (_preferences == null) return;
    
    await _preferences!.remove(_keyUserData);
    await _preferences!.remove(_keyIsLoggedIn);
    await _preferences!.remove(_keyToken);
    await _preferences!.remove(_keyRefreshToken);
    
    // Clear saved credentials if not remembered
    if (!rememberMe) {
      await clearSavedCredentials();
    }
  }

  /// Clear all data (full reset)
  Future<void> clearAllData() async {
    if (_preferences == null) return;
    await _preferences!.clear();
  }

  /// Safe logout - clear data based on remember me preference
  Future<void> logout() async {
    if (rememberMe) {
      // Keep remember me preference and email for next login
      final email = userEmail;
      await clearAuthData();
      // Restore email for auto-fill
      if (email.isNotEmpty) {
        await _preferences!.setString('auto_login_email', email);
      }
    } else {
      // Clear everything if not remembered
      await clearAllData();
    }
  }

  // ========== CUSTOM DATA STORAGE ==========

  /// Save any custom data
  Future<void> saveData<T>(String key, T value) async {
    if (_preferences == null) return;
    
    if (T == String) {
      await _preferences!.setString(key, value as String);
    } else if (T == int) {
      await _preferences!.setInt(key, value as int);
    } else if (T == double) {
      await _preferences!.setDouble(key, value as double);
    } else if (T == bool) {
      await _preferences!.setBool(key, value as bool);
    } else if (T == List<String>) {
      await _preferences!.setStringList(key, value as List<String>);
    } else {
      throw Exception('Unsupported data type: $T');
    }
  }

  /// Get custom data
  T? getData<T>(String key) {
    if (_preferences == null) return null;
    
    try {
      if (T == String) {
        return _preferences!.getString(key) as T?;
      } else if (T == int) {
        return _preferences!.getInt(key) as T?;
      } else if (T == double) {
        return _preferences!.getDouble(key) as T?;
      } else if (T == bool) {
        return _preferences!.getBool(key) as T?;
      } else if (T == List<String>) {
        return _preferences!.getStringList(key) as T?;
      } else {
        throw Exception('Unsupported data type: $T');
      }
    } catch (e) {
      return null;
    }
  }

  /// Remove custom data
  Future<void> removeData(String key) async {
    if (_preferences == null) return;
    await _preferences!.remove(key);
  }

  /// Check if data exists for key
  bool containsKey(String key) {
    if (_preferences == null) return false;
    return _preferences!.containsKey(key);
  }

  /// Get all stored keys
  Set<String> getKeys() {
    if (_preferences == null) return {};
    return _preferences!.getKeys();
  }

  // ========== DEBUG & MAINTENANCE ==========

  /// Print all stored data (for debugging)
  void printAllData() {
    if (_preferences == null) {
      print('LocalStorageService not initialized');
      return;
    }
    
    print('=== LOCAL STORAGE DATA ===');
    for (String key in _preferences!.getKeys()) {
      final value = _preferences!.get(key);
      print('$key: $value');
    }
    print('==========================');
  }

  /// Clear data by prefix (useful for cleanup)
  Future<void> clearByPrefix(String prefix) async {
    if (_preferences == null) return;
    
    final keysToRemove = _preferences!.getKeys()
        .where((key) => key.startsWith(prefix))
        .toList();
    
    for (String key in keysToRemove) {
      await _preferences!.remove(key);
    }
  }
}