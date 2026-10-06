// lib/services/file_saver_web.dart
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

void saveAndDownloadFile(Uint8List bytes, String filename, String mimeType) {
  final base64Data = base64Encode(bytes);
  final dataUri = 'data:$mimeType;base64,$base64Data';
  final anchor = html.AnchorElement(href: dataUri)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
}

void openOrDownloadDocument(String source, String filename) {
  try {
    if (source.startsWith('data:')) {
      final commaIdx = source.indexOf(',');
      if (commaIdx != -1) {
        final meta = source.substring(5, commaIdx);
        final isBase64 = meta.contains(';base64');
        final mimeType = isBase64 ? meta.split(';base64').first : meta;
        final rawData = source.substring(commaIdx + 1);
        final bytes = isBase64
            ? base64Decode(rawData)
            : Uint8List.fromList(utf8.encode(Uri.decodeComponent(rawData)));

        final blob = html.Blob([bytes], mimeType);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(blobUrl, '_blank');
        return;
      }
    } else if (source.startsWith('http://') ||
        source.startsWith('https://') ||
        source.startsWith('blob:')) {
      html.window.open(source, '_blank');
      return;
    }

    final anchor = html.AnchorElement(href: source)
      ..setAttribute('target', '_blank')
      ..setAttribute('download', filename)
      ..style.display = 'none';
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
  } catch (e) {
    // ignore: avoid_print
    print('openOrDownloadDocument error: $e');
  }
}

