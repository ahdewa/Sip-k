import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/services/file_saver_helper.dart';

class ParsedUserItem {
  String nip;
  String name;
  String email;
  String password;
  String department;
  UserRole role;
  bool isValid;
  String? validationError;

  ParsedUserItem({
    required this.nip,
    required this.name,
    required this.email,
    required this.password,
    required this.department,
    required this.role,
    this.isValid = true,
    this.validationError,
  });

  AppUser toAppUser() {
    final cleanNip = nip.replaceAll(RegExp(r'\s+'), '');
    return AppUser(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}-${cleanNip.length > 4 ? cleanNip.substring(cleanNip.length - 4) : cleanNip}',
      name: name,
      nip: nip,
      email: email,
      department: department,
      role: role,
      username: email.contains('@') ? email.split('@').first : cleanNip,
      isActive: true,
    );
  }
}

class UserImportResult {
  final List<ParsedUserItem> items;
  final List<String> detectedHeaders;
  final Map<String, String> mappedColumns;
  final int totalRows;
  final int validRows;
  final int invalidRows;

  UserImportResult({
    required this.items,
    required this.detectedHeaders,
    required this.mappedColumns,
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
  });

  int get adminCount =>
      items.where((it) => it.isValid && (it.role == UserRole.admin || it.role == UserRole.superadmin)).length;

  int get onlyAdminCount =>
      items.where((it) => it.isValid && it.role == UserRole.admin).length;

  int get superAdminCount =>
      items.where((it) => it.isValid && it.role == UserRole.superadmin).length;

  int get userCount =>
      items.where((it) => it.isValid && it.role == UserRole.user).length;
}

class UserImportService {
  /// Membaca file bytes (baik Excel .xlsx maupun CSV .csv) dan mengekstrak NIP, Nama, Email, Password, Bidang.
  /// Kolom-kolom lain yang ada di dalam file akan otomatis diabaikan tanpa error.
  static UserImportResult parseFile({
    required Uint8List bytes,
    required String fileName,
    required UserRole defaultRole,
    String defaultPassword = 'dinsos123',
    String defaultDepartment = 'Dinas Sosial Jawa Timur',
  }) {
    final lowerName = fileName.toLowerCase();
    List<List<String>> rawRows = [];

    if (lowerName.endsWith('.xlsx') || lowerName.endsWith('.xls')) {
      rawRows = _parseExcel(bytes);
    } else {
      rawRows = _parseCsv(bytes);
    }

    if (rawRows.isEmpty) {
      return UserImportResult(
        items: [],
        detectedHeaders: [],
        mappedColumns: {},
        totalRows: 0,
        validRows: 0,
        invalidRows: 0,
      );
    }

    // 1. Identifikasi Baris Header
    final headerRow = rawRows.first;
    final detectedHeaders = headerRow.map((h) => h.trim()).toList();

    // 2. Pemetaan Pintar Kolom (Smart Header Mapping)
    int nipCol = -1;
    int nameCol = -1;
    int emailCol = -1;
    int passCol = -1;
    int deptCol = -1;
    int roleCol = -1;

    final mappedColumns = <String, String>{};

    for (int i = 0; i < detectedHeaders.length; i++) {
      final h = _normalizeHeader(detectedHeaders[i]);

      if (nipCol == -1 && (h.contains('nip') || h.contains('noinduk') || h.contains('nomorinduk'))) {
        nipCol = i;
        mappedColumns['NIP'] = detectedHeaders[i];
      } else if (nameCol == -1 && (h.contains('nama') || h.contains('name'))) {
        nameCol = i;
        mappedColumns['Nama Lengkap'] = detectedHeaders[i];
      } else if (emailCol == -1 && (h.contains('email') || h.contains('mail') || h.contains('surel'))) {
        emailCol = i;
        mappedColumns['Email'] = detectedHeaders[i];
      } else if (passCol == -1 && (h.contains('password') || h.contains('pass') || h.contains('sandi'))) {
        passCol = i;
        mappedColumns['Password'] = detectedHeaders[i];
      } else if (deptCol == -1 &&
          (h.contains('bidang') ||
              h.contains('unitkerja') ||
              h.contains('seksi') ||
              h.contains('subbag') ||
              h.contains('bagian') ||
              h.contains('department') ||
              h.contains('opd'))) {
        deptCol = i;
        mappedColumns['Bidang'] = detectedHeaders[i];
      } else if (roleCol == -1 && (h.contains('role') || h.contains('peran') || h.contains('akses') || h.contains('hakakses') || h.contains('tipe') || h.contains('level') || h.contains('kewenangan'))) {
        roleCol = i;
        mappedColumns['Role'] = detectedHeaders[i];
      }
    }

    // 3. Ekstraksi Data Tiap Baris (Mengabaikan Kolom Lain)
    final items = <ParsedUserItem>[];
    final seenNips = <String>{};

    for (int r = 1; r < rawRows.length; r++) {
      final row = rawRows[r];
      // Lewati baris kosong
      if (row.every((cell) => cell.trim().isEmpty)) continue;

      String rawNip = nipCol != -1 && nipCol < row.length ? row[nipCol].trim() : '';
      String rawName = nameCol != -1 && nameCol < row.length ? row[nameCol].trim() : '';
      String rawEmail = emailCol != -1 && emailCol < row.length ? row[emailCol].trim() : '';
      String rawPass = passCol != -1 && passCol < row.length ? row[passCol].trim() : '';
      String rawDept = deptCol != -1 && deptCol < row.length ? row[deptCol].trim() : '';
      String rawRole = roleCol != -1 && roleCol < row.length ? row[roleCol].trim() : '';

      // Tentukan Role (Bisa membaca kode angka 1, 2, 3 maupun teks 'admin', 'user', 'pegawai', dll)
      UserRole assignedRole = defaultRole;
      UserRole? detected;

      // 1. Cek nilai di kolom role utama
      if (rawRole.isNotEmpty) {
        detected = parseRoleValue(rawRole);
      }

      // 2. Cek kolom persis di sebelahnya (misal kolom D berisi angka kode 1/2/3, kolom E berisi teks ADMIN/USER)
      if (detected == null && roleCol != -1 && (roleCol + 1) < row.length) {
        detected = parseRoleValue(row[roleCol + 1].trim());
      }

      // 3. Fallback: periksa seluruh sel di baris ini selain kolom NIP, Nama, Email, Password, atau Bidang
      if (detected == null) {
        for (int c = 0; c < row.length; c++) {
          if (c == nipCol || c == nameCol || c == emailCol || c == passCol || c == deptCol) continue;
          final cellRole = parseRoleValue(row[c].trim());
          if (cellRole != null) {
            detected = cellRole;
            break;
          }
        }
      }

      if (detected != null) {
        assignedRole = detected;
      }

      // Fallback email jika kolom email tidak ada / kosong
      if (rawEmail.isEmpty) {
        if (rawNip.isNotEmpty) {
          rawEmail = '${rawNip.replaceAll(RegExp(r'\s+'), '')}@dinsos.jatimprov.go.id';
        } else if (rawName.isNotEmpty) {
          final cleanName = rawName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '.');
          rawEmail = '$cleanName@dinsos.jatimprov.go.id';
        }
      }

      // Fallback password jika kosong
      if (rawPass.isEmpty) {
        rawPass = defaultPassword;
      }

      // Fallback bidang jika kosong
      if (rawDept.isEmpty) {
        rawDept = defaultDepartment;
      }

      // Validasi baris
      bool isValid = true;
      String? error;

      if (rawNip.isEmpty) {
        isValid = false;
        error = 'NIP wajib diisi';
      } else if (rawName.isEmpty) {
        isValid = false;
        error = 'Nama Lengkap wajib diisi';
      } else if (seenNips.contains(rawNip)) {
        isValid = false;
        error = 'NIP duplikat di file';
      }

      if (isValid) {
        seenNips.add(rawNip);
      }

      items.add(
        ParsedUserItem(
          nip: rawNip,
          name: rawName,
          email: rawEmail,
          password: rawPass,
          department: rawDept,
          role: assignedRole,
          isValid: isValid,
          validationError: error,
        ),
      );
    }

    final validCount = items.where((it) => it.isValid).length;
    final invalidCount = items.length - validCount;

    return UserImportResult(
      items: items,
      detectedHeaders: detectedHeaders,
      mappedColumns: mappedColumns,
      totalRows: items.length,
      validRows: validCount,
      invalidRows: invalidCount,
    );
  }

  static String _normalizeHeader(String header) {
    return header
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  /// Parsing nilai role dari string atau kode numerik Excel:
  /// - 3 / 3.0 / 'super' / 'superadmin' -> superadmin
  /// - 2 / 2.0 / 'admin' / 'administrator' -> admin
  /// - 1 / 1.0 / 0 / 'user' / 'pegawai' / 'staf' dll -> user
  static UserRole? parseRoleValue(String? raw) {
    if (raw == null) return null;
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;

    // 1. Super Admin
    if (s == '3' ||
        s == '3.0' ||
        s.startsWith('3 ') ||
        s.startsWith('3.') ||
        s.contains('super')) {
      return UserRole.superadmin;
    }

    // 2. Admin
    if (s == '2' ||
        s == '2.0' ||
        s.startsWith('2 ') ||
        s.startsWith('2.') ||
        s == 'admin' ||
        (s.contains('admin') && !s.contains('super'))) {
      return UserRole.admin;
    }

    // 3. User / Pegawai
    if (s == '1' ||
        s == '1.0' ||
        s == '0' ||
        s == '0.0' ||
        s.startsWith('1 ') ||
        s.startsWith('1.') ||
        s.startsWith('0 ') ||
        s.startsWith('0.') ||
        s.contains('user') ||
        s.contains('pegawai') ||
        s.contains('staf') ||
        s.contains('staff') ||
        s.contains('peminjam') ||
        s.contains('karyawan') ||
        s.contains('member') ||
        s.contains('pemohon') ||
        s.contains('biasa')) {
      return UserRole.user;
    }

    // Fallback: regex pencocokan digit tunggal
    if (RegExp(r'\b3\b').hasMatch(s)) return UserRole.superadmin;
    if (RegExp(r'\b2\b').hasMatch(s)) return UserRole.admin;
    if (RegExp(r'\b1\b').hasMatch(s)) return UserRole.user;

    return null;
  }

  static List<List<String>> _parseCsv(Uint8List bytes) {
    final content = utf8.decode(bytes, allowMalformed: true);
    final lines = const LineSplitter().convert(content);
    if (lines.isEmpty) return [];

    // Deteksi delimiter berdasarkan baris pertama
    final firstLine = lines.first;
    final commas = ','.allMatches(firstLine).length;
    final semicolons = ';'.allMatches(firstLine).length;
    final tabs = '\t'.allMatches(firstLine).length;

    String delimiter = ',';
    if (semicolons > commas && semicolons > tabs) {
      delimiter = ';';
    } else if (tabs > commas && tabs > semicolons) {
      delimiter = '\t';
    }

    final rows = <List<String>>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      rows.add(_splitCsvLine(line, delimiter));
    }
    return rows;
  }

  static List<String> _splitCsvLine(String line, String delimiter) {
    final result = <String>[];
    final sb = StringBuffer();
    bool insideQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (insideQuotes && i + 1 < line.length && line[i + 1] == '"') {
          sb.write('"');
          i++; // Lewati escaped quote
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (char == delimiter && !insideQuotes) {
        result.add(sb.toString().trim());
        sb.clear();
      } else {
        sb.write(char);
      }
    }
    result.add(sb.toString().trim());
    return result;
  }

  static List<List<String>> _parseExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final rows = <List<String>>[];

    // Gunakan sheet pertama yang memiliki data
    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null || sheet.rows.isEmpty) continue;

      for (final row in sheet.rows) {
        final rowCells = <String>[];
        for (final cell in row) {
          if (cell == null || cell.value == null) {
            rowCells.add('');
          } else {
            rowCells.add(cell.value.toString().trim());
          }
        }
        rows.add(rowCells);
      }
      break; // Cukup sheet pertama
    }

    return rows;
  }

  /// Unduh contoh format CSV yang siap diedit
  static void downloadTemplateCsv() {
    const csvContent =
        'NIP,Nama Lengkap,Email,Password,Bidang,Role\r\n'
        '198507122010011005,Ahmad Fauzi S.Sos,ahmad.fauzi@dinsos.jatimprov.go.id,dinsos123,Bidang Perlindungan & Jaminan Sosial (Linjamsos),Pegawai\r\n'
        '199203152019032008,Siti Nurhaliza S.ST,siti.nurhaliza@dinsos.jatimprov.go.id,dinsos123,Bidang Rehabilitasi Sosial (Rehsos),Pegawai\r\n'
        '198811202015021003,Budi Santoso S.Kom,budi.santoso@dinsos.jatimprov.go.id,dinsos123,Sekretariat / Subbag Tata Usaha,Admin\r\n'
        '199505102020122014,Dewi Sekar Arum S.Psi,dewi.sekar@dinsos.jatimprov.go.id,dinsos123,Bidang Pemberdayaan Sosial (Dayasos),Pegawai\r\n';

    final bytes = Uint8List.fromList(utf8.encode(csvContent));
    saveAndDownloadFile(
      bytes,
      'template_import_user_dinsos.csv',
      'text/csv;charset=utf-8',
    );
  }

  /// Unduh contoh format Excel (.xlsx) dengan header bergaya rapi
  static void downloadTemplateExcel() {
    final excel = Excel.createExcel();
    final sheet = excel['Data_User'];
    excel.setDefaultSheet('Data_User');

    // Header Kolom
    final headers = ['NIP', 'Nama Lengkap', 'Email', 'Password', 'Bidang', 'Role'];
    for (int c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = CellStyle(
        bold: true,
        fontColorHex: ExcelColor.white,
        backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
      );
    }

    // Baris Contoh
    final sampleData = [
      [
        '198507122010011005',
        'Ahmad Fauzi S.Sos',
        'ahmad.fauzi@dinsos.jatimprov.go.id',
        'dinsos123',
        'Bidang Perlindungan & Jaminan Sosial (Linjamsos)',
        'Pegawai',
      ],
      [
        '199203152019032008',
        'Siti Nurhaliza S.ST',
        'siti.nurhaliza@dinsos.jatimprov.go.id',
        'dinsos123',
        'Bidang Rehabilitasi Sosial (Rehsos)',
        'Pegawai',
      ],
      [
        '198811202015021003',
        'Budi Santoso S.Kom',
        'budi.santoso@dinsos.jatimprov.go.id',
        'dinsos123',
        'Sekretariat / Subbag Tata Usaha',
        'Admin',
      ],
      [
        '199505102020122014',
        'Dewi Sekar Arum S.Psi',
        'dewi.sekar@dinsos.jatimprov.go.id',
        'dinsos123',
        'Bidang Pemberdayaan Sosial (Dayasos)',
        'Pegawai',
      ],
    ];

    for (int r = 0; r < sampleData.length; r++) {
      for (int c = 0; c < sampleData[r].length; c++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
        cell.value = TextCellValue(sampleData[r][c]);
      }
    }

    final bytes = excel.encode();
    if (bytes != null) {
      saveAndDownloadFile(
        Uint8List.fromList(bytes),
        'template_import_user_dinsos.xlsx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    }
  }
}
