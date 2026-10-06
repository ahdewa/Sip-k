// lib/services/url_launcher_web.dart
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<bool> launchCustomUrl(String urlString) async {
  try {
    html.window.open(urlString, '_blank');
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> launchWhatsAppUrl({
  required String phoneNumber,
  required String message,
}) async {
  try {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMsg = Uri.encodeComponent(message);
    final url = 'https://wa.me/$cleanPhone?text=$encodedMsg';
    html.window.open(url, '_blank');
    return true;
  } catch (_) {
    return false;
  }
}
