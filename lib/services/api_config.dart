import 'package:simodis_jatim/models/user_model.dart';

class ApiConfig {
  static String get baseUrl {
    return 'https://ovbs.duckdns.org/api';
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
