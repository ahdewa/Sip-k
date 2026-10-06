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
