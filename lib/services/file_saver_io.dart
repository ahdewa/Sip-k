import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Directory _resolveDownloadDirectory() {
  if (Platform.isAndroid) {
    // Daftar kemungkinan path folder Download di berbagai merk HP Android (Samsung, Xiaomi, Oppo, Vivo, dll)
    final candidateBases = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Downloads',
      '/sdcard/Download',
      '/sdcard/Downloads',
      '/storage/self/primary/Download',
      '/storage/self/primary/Downloads',
    ];

    for (final basePath in candidateBases) {
      final baseDir = Directory(basePath);
      if (baseDir.existsSync()) {
        final ovbsDir = Directory('${baseDir.path}/OVBS');
        try {
          if (!ovbsDir.existsSync()) {
            ovbsDir.createSync(recursive: true);
          }
          if (ovbsDir.existsSync()) {
            return ovbsDir;
          }
        } catch (_) {}
      }
    }

    // Jika base Download belum terdeteksi, coba buat langsung /storage/emulated/0/Download/OVBS
    try {
      final defaultOvbs = Directory('/storage/emulated/0/Download/OVBS');
      if (!defaultOvbs.existsSync()) {
        defaultOvbs.createSync(recursive: true);
      }
      if (defaultOvbs.existsSync()) {
        return defaultOvbs;
      }
    } catch (_) {}
  } else if (Platform.isWindows) {
    try {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) {
        final ovbsDir = Directory('$userProfile\\Downloads\\OVBS');
        if (!ovbsDir.existsSync()) {
          ovbsDir.createSync(recursive: true);
        }
        if (ovbsDir.existsSync()) {
          return ovbsDir;
        }
      }
    } catch (_) {}
  }

  // Fallback ke subfolder OVBS di temporary directory
  final tempOvbs = Directory('${Directory.systemTemp.path}/OVBS');
  try {
    if (!tempOvbs.existsSync()) {
      tempOvbs.createSync(recursive: true);
    }
    if (tempOvbs.existsSync()) {
      return tempOvbs;
    }
  } catch (_) {}

  return Directory.systemTemp;
}

String? saveAndDownloadFile(Uint8List bytes, String filename, String mimeType) {
  try {
    final targetDir = _resolveDownloadDirectory();
    final file = File('${targetDir.path}/$filename');
    file.writeAsBytesSync(bytes);
    debugPrint('File berhasil diekspor ke folder OVBS: ${file.path}');

    // Panggil MediaScanner Android agar file langsung terindeks di Pengelola File / File Manager HP
    if (Platform.isAndroid) {
      try {
        Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file://${file.path}',
        ]);
      } catch (_) {}
    }

    return file.path;
  } catch (e) {
    debugPrint('Gagal menyimpan ke folder publik OVBS, mencoba fallback temp: $e');
    try {
      final fallbackFile = File('${Directory.systemTemp.path}/$filename');
      fallbackFile.writeAsBytesSync(bytes);
      debugPrint('File disimpan ke direktori temp: ${fallbackFile.path}');
      return fallbackFile.path;
    } catch (err) {
      debugPrint('Gagal total menyimpan file: $err');
      return null;
    }
  }
}

Future<String?> openOrDownloadDocument(String source, String filename) async {
  if (source.startsWith('data:')) {
    try {
      final commaIdx = source.indexOf(',');
      if (commaIdx != -1) {
        final rawData = source.substring(commaIdx + 1);
        final bytes = base64Decode(rawData);
        return saveAndDownloadFile(bytes, filename, 'application/pdf');
      }
    } catch (e) {
      debugPrint('openOrDownloadDocument io error: $e');
    }
  } else if (source.startsWith('http://') || source.startsWith('https://')) {
    try {
      final res = await http.get(Uri.parse(source));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        return saveAndDownloadFile(res.bodyBytes, filename, 'application/pdf');
      }
    } catch (e) {
      debugPrint('openOrDownloadDocument http download error: $e');
    }
  }
  return null;
}

