import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:simodis_jatim/services/api_config.dart';

class WilayahItem {
  final String code;
  final String name;

  const WilayahItem({required this.code, required this.name});

  factory WilayahItem.fromJson(Map<String, dynamic> json) {
    return WilayahItem(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WilayahItem &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => name;
}

class WilayahService {
  static const String _baseUrl = 'https://wilayah.id/api';

  // Cache in-memory agar tidak membebani network saat berpindah-pindah
  static List<WilayahItem>? _cachedRegencies;
  static final Map<String, List<WilayahItem>> _cachedDistricts = {};
  static final Map<String, List<WilayahItem>> _cachedVillages = {};

  /// Mengambil daftar Kabupaten / Kota di Jawa Timur (Kode Provinsi 35)
  static Future<List<WilayahItem>> getRegencies() async {
    if (_cachedRegencies != null && _cachedRegencies!.isNotEmpty) {
      return _cachedRegencies!;
    }

    // 1. Coba lewat proxy Laravel backend (anti-CORS untuk Flutter Web/Chrome)
    try {
      final proxyUrl = '${ApiConfig.baseUrl}/wilayah/regencies/35';
      final response = await http
          .get(Uri.parse(proxyUrl))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] as List? ?? [];
        final list = data.map((item) => WilayahItem.fromJson(item)).toList();
        if (list.isNotEmpty) {
          _cachedRegencies = list;
          return list;
        }
      }
    } catch (_) {}

    // 2. Direct ke wilayah.id (berfungsi normal di Android/iOS HP fisik)
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/regencies/35.json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] as List? ?? [];
        final list = data.map((item) => WilayahItem.fromJson(item)).toList();
        if (list.isNotEmpty) {
          _cachedRegencies = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('WilayahService.getRegencies error: $e');
    }

    // Fallback jika offline atau server tidak merespon
    return _fallbackRegencies;
  }

  /// Mengambil daftar Kecamatan berdasarkan kode Kabupaten/Kota
  static Future<List<WilayahItem>> getDistricts(String regencyCode) async {
    if (_cachedDistricts.containsKey(regencyCode)) {
      return _cachedDistricts[regencyCode]!;
    }

    // 1. Coba lewat proxy Laravel backend (anti-CORS untuk Flutter Web/Chrome)
    try {
      final proxyUrl = '${ApiConfig.baseUrl}/wilayah/districts/$regencyCode';
      final response = await http
          .get(Uri.parse(proxyUrl))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] as List? ?? [];
        final list = data.map((item) => WilayahItem.fromJson(item)).toList();
        if (list.isNotEmpty) {
          _cachedDistricts[regencyCode] = list;
          return list;
        }
      }
    } catch (_) {}

    // 2. Direct ke wilayah.id (berfungsi normal di Android/iOS HP fisik)
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/districts/$regencyCode.json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] as List? ?? [];
        final list = data.map((item) => WilayahItem.fromJson(item)).toList();
        if (list.isNotEmpty) {
          _cachedDistricts[regencyCode] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('WilayahService.getDistricts error: $e');
    }

    return [];
  }

  /// Mengambil daftar Kelurahan / Desa berdasarkan kode Kecamatan
  static Future<List<WilayahItem>> getVillages(String districtCode) async {
    if (_cachedVillages.containsKey(districtCode)) {
      return _cachedVillages[districtCode]!;
    }

    // 1. Coba lewat proxy Laravel backend (anti-CORS untuk Flutter Web/Chrome)
    try {
      final proxyUrl = '${ApiConfig.baseUrl}/wilayah/villages/$districtCode';
      final response = await http
          .get(Uri.parse(proxyUrl))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] as List? ?? [];
        final list = data.map((item) => WilayahItem.fromJson(item)).toList();
        if (list.isNotEmpty) {
          _cachedVillages[districtCode] = list;
          return list;
        }
      }
    } catch (_) {}

    // 2. Direct ke wilayah.id (berfungsi normal di Android/iOS HP fisik)
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/villages/$districtCode.json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] as List? ?? [];
        final list = data.map((item) => WilayahItem.fromJson(item)).toList();
        if (list.isNotEmpty) {
          _cachedVillages[districtCode] = list;
          return list;
        }
      }
    } catch (e) {
      debugPrint('WilayahService.getVillages error: $e');
    }

    return [];
  }

  /// Fallback resmi 38 Kabupaten / Kota se-Jawa Timur
  static const List<WilayahItem> _fallbackRegencies = [
    WilayahItem(code: '35.01', name: 'Kabupaten Pacitan'),
    WilayahItem(code: '35.02', name: 'Kabupaten Ponorogo'),
    WilayahItem(code: '35.03', name: 'Kabupaten Trenggalek'),
    WilayahItem(code: '35.04', name: 'Kabupaten Tulungagung'),
    WilayahItem(code: '35.05', name: 'Kabupaten Blitar'),
    WilayahItem(code: '35.06', name: 'Kabupaten Kediri'),
    WilayahItem(code: '35.07', name: 'Kabupaten Malang'),
    WilayahItem(code: '35.08', name: 'Kabupaten Lumajang'),
    WilayahItem(code: '35.09', name: 'Kabupaten Jember'),
    WilayahItem(code: '35.10', name: 'Kabupaten Banyuwangi'),
    WilayahItem(code: '35.11', name: 'Kabupaten Bondowoso'),
    WilayahItem(code: '35.12', name: 'Kabupaten Situbondo'),
    WilayahItem(code: '35.13', name: 'Kabupaten Probolinggo'),
    WilayahItem(code: '35.14', name: 'Kabupaten Pasuruan'),
    WilayahItem(code: '35.15', name: 'Kabupaten Sidoarjo'),
    WilayahItem(code: '35.16', name: 'Kabupaten Mojokerto'),
    WilayahItem(code: '35.17', name: 'Kabupaten Jombang'),
    WilayahItem(code: '35.18', name: 'Kabupaten Nganjuk'),
    WilayahItem(code: '35.19', name: 'Kabupaten Madiun'),
    WilayahItem(code: '35.20', name: 'Kabupaten Magetan'),
    WilayahItem(code: '35.21', name: 'Kabupaten Ngawi'),
    WilayahItem(code: '35.22', name: 'Kabupaten Bojonegoro'),
    WilayahItem(code: '35.23', name: 'Kabupaten Tuban'),
    WilayahItem(code: '35.24', name: 'Kabupaten Lamongan'),
    WilayahItem(code: '35.25', name: 'Kabupaten Gresik'),
    WilayahItem(code: '35.26', name: 'Kabupaten Bangkalan'),
    WilayahItem(code: '35.27', name: 'Kabupaten Sampang'),
    WilayahItem(code: '35.28', name: 'Kabupaten Pamekasan'),
    WilayahItem(code: '35.29', name: 'Kabupaten Sumenep'),
    WilayahItem(code: '35.71', name: 'Kota Kediri'),
    WilayahItem(code: '35.72', name: 'Kota Blitar'),
    WilayahItem(code: '35.73', name: 'Kota Malang'),
    WilayahItem(code: '35.74', name: 'Kota Probolinggo'),
    WilayahItem(code: '35.75', name: 'Kota Pasuruan'),
    WilayahItem(code: '35.76', name: 'Kota Mojokerto'),
    WilayahItem(code: '35.77', name: 'Kota Madiun'),
    WilayahItem(code: '35.78', name: 'Kota Surabaya'),
    WilayahItem(code: '35.79', name: 'Kota Batu'),
  ];
}
