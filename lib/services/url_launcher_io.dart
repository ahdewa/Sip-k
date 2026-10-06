// lib/services/url_launcher_io.dart
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchCustomUrl(String urlString) async {
  try {
    final uri = Uri.parse(urlString);

    // 1. Coba langsung buka dengan externalApplication
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {}

    // 2. Coba canLaunchUrl + mode platformDefault
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }

    // 3. Fallback ke inAppBrowserView jika eksternal gagal
    try {
      return await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {}

    return false;
  } catch (_) {
    return false;
  }
}

Future<bool> launchWhatsAppUrl({
  required String phoneNumber,
  required String message,
}) async {
  try {
    // Bersihkan karakter non-angka
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMsg = Uri.encodeComponent(message);

    // 1. Coba buka langsung Aplikasi WhatsApp via native intent scheme (whatsapp://send)
    final nativeUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMsg');
    try {
      if (await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication)) {
        return true;
      }
    } catch (_) {}

    try {
      if (await launchUrl(nativeUri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {}

    // 2. Coba buka via link web wa.me
    final waMeUri = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMsg');
    try {
      if (await launchUrl(waMeUri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {}

    // 3. Coba buka via link api.whatsapp.com
    final apiWaUri = Uri.parse('https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMsg');
    try {
      if (await launchUrl(apiWaUri, mode: LaunchMode.externalApplication)) {
        return true;
      }
    } catch (_) {}

    // 4. Fallback jika canLaunchUrl mengizinkan
    if (await canLaunchUrl(waMeUri)) {
      return await launchUrl(waMeUri, mode: LaunchMode.platformDefault);
    }

    return false;
  } catch (_) {
    return false;
  }
}
