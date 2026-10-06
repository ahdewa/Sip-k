import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simodis_jatim/services/api_config.dart';

String normalizeImageSource(String source) {
  var url = source.trim();
  if (url.isEmpty) return '';

  if (kIsWeb) {
    if ((url.startsWith('http://') || url.startsWith('https://')) &&
        !url.contains('/image-proxy?url=')) {
      return '${ApiConfig.baseUrl}/image-proxy?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  try {
    if (Platform.isAndroid && url.startsWith('http://localhost')) {
      final host = Uri.parse(ApiConfig.baseUrl).host;
      if (host.isNotEmpty && host != 'localhost') {
        url = url.replaceFirst('http://localhost', 'http://$host');
      }
    }
  } catch (_) {}
  return url;
}

// In-memory cache agar image provider (khususnya base64 MemoryImage dan remote) tidak di-decode ulang setiap frame/rebuild
final Map<String, ImageProvider<Object>> _imageCache = {};
final Map<String, Uint8List> _remoteBytesCache = {};

ImageProvider<Object>? imageProviderFromSource(String source) {
  if (source.isEmpty) return null;
  if (_imageCache.containsKey(source)) {
    return _imageCache[source];
  }

  final dataUriMarker = RegExp(
    r'^data:image/(png|jpeg|jpg|webp);base64,',
    caseSensitive: false,
  );
  final match = dataUriMarker.firstMatch(source);
  if (match != null) {
    final encoded = source.substring(match.end);
    try {
      final provider = MemoryImage(base64Decode(encoded));
      _imageCache[source] = provider;
      return provider;
    } on FormatException {
      return null;
    }
  }

  if (source.startsWith('http://') ||
      source.startsWith('https://') ||
      source.startsWith('blob:')) {
    final provider = NetworkImage(source);
    _imageCache[source] = provider;
    return provider;
  }

  if (source.startsWith('assets/')) {
    final provider = AssetImage(source);
    _imageCache[source] = provider;
    return provider;
  }

  if (!kIsWeb) {
    try {
      final file = File(source);
      if (file.existsSync()) {
        final provider = FileImage(file);
        _imageCache[source] = provider;
        return provider;
      }
    } catch (_) {}
  }

  return null;
}

class AppImage extends StatefulWidget {
  final String source;
  final BoxFit fit;
  final Widget placeholder;

  const AppImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholder = const Icon(Icons.image_not_supported_outlined),
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    final normalized = normalizeImageSource(widget.source);
    if (_remoteBytesCache.containsKey(normalized)) {
      _bytes = _remoteBytesCache[normalized];
    } else {
      _fetchIfRemote();
    }
  }

  @override
  void didUpdateWidget(covariant AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      final normalized = normalizeImageSource(widget.source);
      if (_remoteBytesCache.containsKey(normalized)) {
        _bytes = _remoteBytesCache[normalized];
      } else {
        _bytes = null;
        _fetchIfRemote();
      }
    }
  }

  Future<void> _fetchIfRemote() async {
    final normalized = normalizeImageSource(widget.source);
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      if (_remoteBytesCache.containsKey(normalized)) {
        if (mounted) setState(() => _bytes = _remoteBytesCache[normalized]);
        return;
      }
      try {
        final res = await http.get(Uri.parse(normalized));
        if (res.statusCode == 200 && res.bodyBytes.length > 10 && mounted) {
          final ct = (res.headers['content-type'] ?? '').toLowerCase();
          final b = res.bodyBytes;
          final isImage = !ct.contains('text/html') &&
              ((b[0] == 0xFF && b[1] == 0xD8) || // JPEG
                  (b[0] == 0x89 && b[1] == 0x50) || // PNG
                  (b[0] == 0x47 && b[1] == 0x49) || // GIF
                  (b[0] == 0x52 && b[1] == 0x49)); // WEBP
          if (isImage) {
            _remoteBytesCache[normalized] = b;
            setState(() {
              _bytes = b;
            });
          }
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => widget.placeholder,
      );
    }

    final normalized = normalizeImageSource(widget.source);
    final provider = imageProviderFromSource(normalized);
    if (provider == null) return widget.placeholder;

    return Image(
      image: provider,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => widget.placeholder,
    );
  }
}

bool isSupportedImageFile(String fileName) {
  final extension = fileName.toLowerCase().split('.').last;
  return extension == 'png' || extension == 'jpg' || extension == 'jpeg';
}

String imageDataUri(String fileName, Uint8List bytes) {
  final extension = fileName.toLowerCase().split('.').last;
  final mimeType = extension == 'png' ? 'png' : 'jpeg';
  return 'data:image/$mimeType;base64,${base64Encode(bytes)}';
}
