import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simodis_jatim/services/api_config.dart';

String normalizeImageSource(String source) {
  var url = source.trim();
  if (kIsWeb) return url;
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

ImageProvider<Object>? imageProviderFromSource(String source) {
  if (source.isEmpty) return null;

  final dataUriMarker = RegExp(
    r'^data:image/(png|jpeg|jpg|webp);base64,',
    caseSensitive: false,
  );
  final match = dataUriMarker.firstMatch(source);
  if (match != null) {
    final encoded = source.substring(match.end);
    try {
      return MemoryImage(base64Decode(encoded));
    } on FormatException {
      return null;
    }
  }

  if (source.startsWith('http://') ||
      source.startsWith('https://') ||
      source.startsWith('blob:')) {
    return NetworkImage(source);
  }

  if (source.startsWith('assets/')) {
    return AssetImage(source);
  }

  if (!kIsWeb) {
    try {
      final file = File(source);
      if (file.existsSync()) {
        return FileImage(file);
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
    _fetchIfRemote();
  }

  @override
  void didUpdateWidget(covariant AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _bytes = null;
      _fetchIfRemote();
    }
  }

  Future<void> _fetchIfRemote() async {
    final normalized = normalizeImageSource(widget.source);
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      try {
        final res = await http.get(Uri.parse(normalized));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty && mounted) {
          setState(() {
            _bytes = res.bodyBytes;
          });
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
        errorBuilder: (context, error, stackTrace) => widget.placeholder,
      );
    }

    final normalized = normalizeImageSource(widget.source);
    final provider = imageProviderFromSource(normalized);
    if (provider == null) return widget.placeholder;

    return Image(
      image: provider,
      fit: widget.fit,
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
