import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:simodis_jatim/models/user_model.dart';

class ApiConfig {
  /// Base URL endpoint Laravel Backend
  /// - Web & Windows: http://localhost/sip-k-backend/public/api
  /// - Android Emulator: http://10.0.2.2/sip-k-backend/public/api
  /// - HP Fisik: Ganti dengan IP Wi-Fi Laptop (contoh: http://192.168.1.15/sip-k-backend/public/api)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/sip-k-backend/public/api';
    }
    try {
      if (Platform.isAndroid) {
        // IP Wi-Fi Laptop Anda agar HP Fisik bisa mengakses Laravel
        return 'http://10.10.1.69/sip-k-backend/public/api';
      }
    } catch (_) {}
    return 'http://localhost/sip-k-backend/public/api';
  }

  // Token sesi login yang sedang aktif
  static String? authToken;
  static String? currentUserId;
  static UserProfile? currentUserProfile;

  /// Kontak WhatsApp Helpdesk Admin (Reset Password & Kendala Akun)
  static const String helpdeskWhatsappNumber = '6285607832173';
  static const String helpdeskWhatsappDisplay = '0856-0783-2173';
  static const String helpdeskWhatsappMessage =
      'Halo Admin OVBS Dinsos Jatim, saya mengalami kendala lupa password / akun login. Mohon bantuannya untuk reset kata sandi.';
}
