import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:simodis_jatim/services/api_service.dart';
import 'package:simodis_jatim/services/api_config.dart';
import 'package:simodis_jatim/screens/loan_history_screen.dart';

// Global Key untuk ScaffoldMessenger (banner foreground) dan Navigator (pindah halaman)
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Dipanggil saat aplikasi di background / terminate ketika pesan masuk
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  debugPrint("FCM Background Message: ${message.messageId} - ${message.notification?.title}");
}

class FcmService {
  static String? _fcmToken;
  static String? get currentToken => _fcmToken;
  static bool _initialized = false;
  static void Function(RemoteMessage)? onMessageReceived;

  /// Inisialisasi Firebase & Firebase Cloud Messaging
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Firebase Core initialization
      // Pada Android, konfigurasi otomatis dibaca dari google-services.json
      if (!kIsWeb) {
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } else {
        debugPrint('FCM: Web platform terdeteksi, lewati inisialisasi native Firebase.');
        _initialized = true;
        return;
      }

      final messaging = FirebaseMessaging.instance;

      // 1. Minta izin notifikasi (Android 13+ & iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM: Status Izin Notifikasi: ${settings.authorizationStatus}');

      // 2. Ambil token perangkat
      try {
        _fcmToken = await messaging.getToken();
        debugPrint('FCM: Device Token Didapatkan: $_fcmToken');
      } catch (e) {
        debugPrint('FCM: Gagal mengambil device token: $e');
      }

      // 3. Listener jika token diperbarui Google
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM: Token diperbarui: $newToken');
        if (ApiConfig.currentUserId != null) {
          ApiService.updateFcmToken(newToken);
        }
      });

      // 4. Listener saat notifikasi masuk saat aplikasi AKTIF (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM: Pesan Foreground Masuk: ${message.notification?.title} - ${message.notification?.body}');
        _showInAppNotification(message);
        onMessageReceived?.call(message);
      });

      // 5. Listener saat pengguna mengklik notifikasi dari bilah notifikasi Android (kondisi background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM: Notifikasi diklik oleh pengguna (Background): ${message.data}');
        handleNotificationClick(message);
      });

      // 6. Listener saat aplikasi dibuka dari kondisi mati/tertutup (Terminated) via klik notifikasi
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('FCM: Aplikasi dibuka dari notifikasi (Terminated): ${message.data}');
          Future.delayed(const Duration(milliseconds: 1200), () {
            handleNotificationClick(message);
          });
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('FCM: Inisialisasi error (abaikan jika di browser/web): $e');
    }
  }

  /// Handler terpusat saat notifikasi diklik: mengarahkan pengguna langsung ke halaman yang sesuai
  static Future<void> handleNotificationClick(RemoteMessage message) async {
    final navState = rootNavigatorKey.currentState;
    if (navState == null) {
      debugPrint('FCM: rootNavigatorKey.currentState bernilai null');
      return;
    }

    final type = (message.data['type'] ?? '').toString();
    debugPrint('FCM: Menavigasi ke aplikasi dari notifikasi, type: $type, payload: ${message.data}');

    // Ambil data peminjaman terbaru dari backend
    final freshLoans = await ApiService.fetchLoans() ?? [];

    int tabIndex = 0;
    if (type == 'approved' || type.contains('disetujui')) {
      tabIndex = 1; // Tab Disetujui
    } else if (type == 'rejected' || type.contains('ditolak')) {
      tabIndex = 4; // Tab Ditolak
    } else if (type == 'returned' || type.contains('selesai')) {
      tabIndex = 3; // Tab Selesai
    } else if (type == 'submitted' || type.contains('menunggu')) {
      tabIndex = 0; // Tab Menunggu
    }

    // Arahkan langsung ke halaman Riwayat Peminjaman dengan tab yang tepat
    navState.push(
      MaterialPageRoute(
        builder: (_) => LoanHistoryScreen(
          loans: freshLoans,
          initialTabIndex: tabIndex,
        ),
      ),
    );
  }

  /// Sinkronisasi token ke server Laravel untuk user yang sedang aktif
  static Future<void> syncTokenWithBackend([String? userId]) async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;

    try {
      await ApiService.updateFcmToken(token);
      debugPrint('FCM: Token berhasil disinkronkan ke backend untuk user ${userId ?? ApiConfig.currentUserId}');
    } catch (e) {
      debugPrint('FCM: Gagal sinkronisasi token: $e');
    }
  }

  /// Tampilkan notifikasi pop-up cantik di dalam aplikasi saat pesan masuk di foreground
  static void _showInAppNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notifikasi Baru';
    final body = message.notification?.body ?? '';

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Buka',
          textColor: const Color(0xFF60A5FA),
          onPressed: () {
            handleNotificationClick(message);
          },
        ),
        content: InkWell(
          onTap: () {
            rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            handleNotificationClick(message);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF60A5FA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
