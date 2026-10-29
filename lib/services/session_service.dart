import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/services/api_config.dart';

class SessionService {
  static const String _keyRole = 'auth_session_role';
  static const String _keyToken = 'auth_session_token';
  static const String _keyUserId = 'auth_session_user_id';
  static const String _keyProfile = 'auth_session_profile';

  /// Menyimpan sesi login ke penyimpanan lokal (LocalStorage pada Web / SharedPreferences pada Mobile & Desktop)
  static Future<void> saveSession({
    required String role,
    String? token,
    String? userId,
    UserProfile? profile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRole, role);

      if (token != null && token.isNotEmpty) {
        await prefs.setString(_keyToken, token);
      } else {
        await prefs.remove(_keyToken);
      }

      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(_keyUserId, userId);
      } else {
        await prefs.remove(_keyUserId);
      }

      if (profile != null) {
        await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
      } else {
        await prefs.remove(_keyProfile);
      }
    } catch (e) {
      debugPrint('SessionService.saveSession error: $e');
    }
  }

  /// Memperbarui data profil di sesi lokal jika terjadi perubahan profil
  static Future<void> updateSavedProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('SessionService.updateSavedProfile error: $e');
    }
  }

  /// Memuat sesi login saat aplikasi dibuka / di-refresh (Ctrl + R)
  static Future<String?> loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(_keyRole);
      if (role == null || role.isEmpty) {
        return null;
      }

      final token = prefs.getString(_keyToken);
      final userId = prefs.getString(_keyUserId);
      final profileStr = prefs.getString(_keyProfile);

      ApiConfig.authToken = token;
      ApiConfig.currentUserId = userId;

      if (profileStr != null && profileStr.isNotEmpty) {
        try {
          final profileMap = jsonDecode(profileStr) as Map<String, dynamic>;
          ApiConfig.currentUserProfile = UserProfile.fromJson(profileMap);
        } catch (e) {
          debugPrint('SessionService parse profile error: $e');
        }
      }

      return role;
    } catch (e) {
      debugPrint('SessionService.loadSavedSession error: $e');
      return null;
    }
  }

  /// Menghapus sesi saat pengguna menekan tombol Logout (Keluar)
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRole);
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyProfile);

      ApiConfig.authToken = null;
      ApiConfig.currentUserId = null;
      ApiConfig.currentUserProfile = null;
    } catch (e) {
      debugPrint('SessionService.clearSession error: $e');
    }
  }
}
