import 'package:simodis_jatim/models/user_model.dart';

class ApiConfig {
  /// Base URL endpoint Laravel Backend
  /// - Web & Windows: http://localhost/sip-k-backend/public/api
  /// - Android Emulator: http://10.0.2.2/sip-k-backend/public/api
  /// - HP Fisik: Ganti dengan IP Wi-Fi Laptop (contoh: http://192.168.1.15/sip-k-backend/public/api)
  static String get baseUrl {
    // Endpoint Laravel Backend di Azure VM
    return 'http://20.244.48.18/api';
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
