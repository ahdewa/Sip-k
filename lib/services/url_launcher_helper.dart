// lib/services/url_launcher_helper.dart
export 'url_launcher_stub.dart'
    if (dart.library.html) 'url_launcher_web.dart'
    if (dart.library.io) 'url_launcher_io.dart';
