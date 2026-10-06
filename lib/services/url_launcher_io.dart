// lib/services/url_launcher_io.dart
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchCustomUrl(String urlString) async {
  try {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  } catch (_) {
    return false;
  }
}
