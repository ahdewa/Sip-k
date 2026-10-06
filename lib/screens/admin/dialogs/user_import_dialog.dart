import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/user_model.dart';
import 'package:simodis_jatim/services/api_service.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/services/user_import_service.dart';

class UserImportDialog extends StatefulWidget {
  final UserRole targetRole;
  final bool isSuperAdmin;
  final List<AppUser> existingUsers;
  final Function(AppUser)? onAddUser;
  final VoidCallback? onSuccess;

  const UserImportDialog({
    super.key,
    required this.targetRole,
    this.isSuperAdmin = false,
    required this.existingUsers,
    this.onAddUser,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required UserRole targetRole,
    bool isSuperAdmin = false,
    required List<AppUser> existingUsers,
    Function(AppUser)? onAddUser,
    VoidCallback? onSuccess,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UserImportDialog(
        targetRole: targetRole,
        isSuperAdmin: isSuperAdmin,
        existingUsers: existingUsers,
        onAddUser: onAddUser,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<UserImportDialog> createState() => _UserImportDialogState();
}

class _UserImportDialogState extends State<UserImportDialog> {
  String? _selectedFileName;
  Uint8List? _fileBytes;
  UserImportResult? _parsedResult;
  bool _isLoadingFile = false;
  bool _isImporting = false;
  double _importProgress = 0.0;
  int _importedCount = 0;
  String _defaultPassword = 'dinsos123';
  final TextEditingController _defaultPasswordCtrl = TextEditingController(text: 'dinsos123');

  @override
  void dispose() {
    _defaultPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      setState(() => _isLoadingFile = true);
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null) {
        final bytes = await result.xFile.readAsBytes();
        final fileName = result.name;

        final parseRes = UserImportService.parseFile(
          bytes: bytes,
          fileName: fileName,
          defaultRole: widget.targetRole,
          defaultPassword: _defaultPassword,
        );

        // Tandai duplikasi dengan user yang sudah terdaftar di sistem
        final existingNips = widget.existingUsers.map((u) => u.nip.trim()).toSet();
        for (var item in parseRes.items) {
          if (item.isValid && existingNips.contains(item.nip.trim())) {
            item.isValid = false;
            item.validationError = 'NIP sudah terdaftar di sistem';
          }
        }

        setState(() {
          _selectedFileName = fileName;
          _fileBytes = bytes;
          _parsedResult = parseRes;
          _isLoadingFile = false;
        });
      } else {
        setState(() => _isLoadingFile = false);
      }
    } catch (e) {
      setState(() => _isLoadingFile = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membaca file: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _reparseWithNewDefaultPassword(String newPass) {
    if (_fileBytes == null || _selectedFileName == null) return;
    _defaultPassword = newPass;

    final parseRes = UserImportService.parseFile(
      bytes: _fileBytes!,
      fileName: _selectedFileName!,
      defaultRole: widget.targetRole,
      defaultPassword: newPass,
    );

    final existingNips = widget.existingUsers.map((u) => u.nip.trim()).toSet();
    for (var item in parseRes.items) {
      if (item.isValid && existingNips.contains(item.nip.trim())) {
        item.isValid = false;
        item.validationError = 'NIP sudah terdaftar di sistem';
      }
    }

    setState(() {
      _parsedResult = parseRes;
    });
  }

  Future<void> _executeImport() async {
    if (_parsedResult == null) return;
    final validItems = _parsedResult!.items.where((it) => it.isValid).toList();
    if (validItems.isEmpty) return;

    setState(() {
      _isImporting = true;
      _importProgress = 0.0;
      _importedCount = 0;
    });

    int successCount = 0;
    for (int i = 0; i < validItems.length; i++) {
      final item = validItems[i];
      final appUser = item.toAppUser();

      // Tambahkan ke sistem lokal dan panggil API
      widget.onAddUser?.call(appUser);
      await ApiService.createUser(appUser, password: item.password);

      successCount++;
      if (mounted) {
        setState(() {
          _importedCount = successCount;
          _importProgress = (i + 1) / validItems.length;
        });
      }
      // Delay kecil agar UI halus dan tidak membebani server
      await Future.delayed(const Duration(milliseconds: 60));
    }

    if (mounted) {
      Navigator.pop(context);
      widget.onSuccess?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Berhasil mengimpor $successCount akun ${widget.targetRole == UserRole.admin ? "Admin" : "Pegawai"}!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final roleName = widget.targetRole == UserRole.admin ? 'Admin' : 'Pegawai';

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 680),
        child: Column(
          children: [
            // ─── HEADER DIALOG ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.upload_file_rounded,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import Akun $roleName (Excel / CSV)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Membaca kolom NIP, Nama Lengkap, Email, Password, dan Bidang secara otomatis.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isImporting ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ],
              ),
            ),

            // ─── BODY KONTEN ────────────────────────────────────────
            Expanded(
              child: _selectedFileName == null
                  ? _buildEmptyUploadView(isDark)
                  : _buildPreviewContentView(isDark),
            ),

            // ─── FOOTER ACTION ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Tombol download template di kiri
                  PopupMenuButton<String>(
                    tooltip: 'Unduh contoh format file',
                    onSelected: (val) {
                      if (val == 'csv') {
                        UserImportService.downloadTemplateCsv();
                      } else {
                        UserImportService.downloadTemplateExcel();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mengunduh template $val...'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'excel',
                        child: Row(
                          children: [
                            Icon(Icons.table_chart_rounded, color: Color(0xFF16A34A), size: 18),
                            SizedBox(width: 8),
                            Text('Unduh Template Excel (.xlsx)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'csv',
                        child: Row(
                          children: [
                            Icon(Icons.description_outlined, color: Color(0xFF2563EB), size: 18),
                            SizedBox(width: 8),
                            Text('Unduh Template CSV (.csv)'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 16,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Unduh Contoh Template',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  if (_selectedFileName != null) ...[
                    OutlinedButton(
                      onPressed: _isImporting ? null : _pickFile,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      child: const Text('Ganti File'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: (_isImporting || (_parsedResult?.validRows ?? 0) == 0)
                          ? null
                          : _executeImport,
                      icon: _isImporting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded, size: 16),
                      label: Text(
                        _isImporting
                            ? 'Mengimpor ($_importedCount/${_parsedResult?.validRows ?? 0})...'
                            : 'Impor (${_parsedResult?.validRows ?? 0}) Akun',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyUploadView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: _isLoadingFile ? null : _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                            : const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.file_upload_outlined,
                        size: 40,
                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Berkas Excel (.xlsx) atau CSV (.csv)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Klik untuk memilih berkas dari komputer/perangkat Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sistem otomatis membaca kolom: NIP, Nama Lengkap, Email, Password, Bidang',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Catatan: Kolom-kolom tambahan lainnya (seperti No, Golongan, Jabatan, dll) akan otomatis diabaikan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContentView(bool isDark) {
    final result = _parsedResult!;
    final items = result.items;

    return Column(
      children: [
        // ─── BARIS INFORMASI PEMETAAN FILE ─────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: 18,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedFileName ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  // Badges Ringkasan
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${result.validRows} Siap Diimpor',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  if (result.invalidRows > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${result.invalidRows} Tidak Valid / Duplikat',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildHeaderMappingChip('NIP', result.mappedColumns['NIP'], isDark),
                        _buildHeaderMappingChip('Nama Lengkap', result.mappedColumns['Nama Lengkap'], isDark),
                        _buildHeaderMappingChip('Email', result.mappedColumns['Email'], isDark),
                        _buildHeaderMappingChip('Password', result.mappedColumns['Password'], isDark),
                        _buildHeaderMappingChip('Bidang', result.mappedColumns['Bidang'], isDark),
                      ],
                    ),
                  ),
                  if (result.mappedColumns['Password'] == null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showEditDefaultPasswordDialog(isDark),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.key_rounded, size: 12, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 4),
                            Text(
                              'Pass Default: $_defaultPassword',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit_outlined, size: 11),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Progress bar jika sedang proses impor
        if (_isImporting)
          LinearProgressIndicator(
            value: _importProgress,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            color: const Color(0xFF16A34A),
            minHeight: 4,
          ),

        // ─── TABEL PRATINJAU DATA ──────────────────────────────────
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada baris data pengguna yang ditemukan di dalam file.',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final it = items[index];
                    return _buildUserPreviewRow(it, index + 1, isDark);
                  },
                ),
        ),
      ],
    );
  }

  void _showEditDefaultPasswordDialog(bool isDark) {
    _defaultPasswordCtrl.text = _defaultPassword;
    showDialog<void>(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Ubah Password Default', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password ini akan diberikan ke semua akun yang kolom password-nya kosong di file Excel/CSV.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _defaultPasswordCtrl,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Password Default Baru',
                hintText: 'Misal: dinsos123',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPass = _defaultPasswordCtrl.text.trim();
              if (newPass.isNotEmpty) {
                _reparseWithNewDefaultPassword(newPass);
              }
              Navigator.pop(dCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24487A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMappingChip(String field, String? sourceCol, bool isDark) {
    final isMapped = sourceCol != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isMapped
            ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF))
            : (isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isMapped
              ? (isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE))
              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          width: 0.8,
        ),
      ),
      child: Text(
        isMapped ? '$field: "$sourceCol"' : '$field: (Default)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isMapped
              ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8))
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildUserPreviewRow(ParsedUserItem item, int index, bool isDark) {
    return Container(
      color: !item.isValid
          ? (isDark ? const Color(0xFF3B1518).withValues(alpha: 0.4) : const Color(0xFFFEF2F2))
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nomor Baris & Status Indicator
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.isValid
                  ? (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7))
                  : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isValid ? Icons.check : Icons.close,
              size: 14,
              color: item.isValid ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 12),

          // NIP & Nama
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isNotEmpty ? item.name : '(Nama kosong)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: item.isValid
                        ? (isDark ? Colors.white : const Color(0xFF1E293B))
                        : const Color(0xFFDC2626),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.nip.isNotEmpty ? 'NIP: ${item.nip}' : '(NIP kosong)',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Email & Bidang
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.email,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.business_rounded, size: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.department,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Password & Keterangan Status
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!item.isValid)
                  Text(
                    item.validationError ?? 'Tidak valid',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                    textAlign: TextAlign.end,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Pass: ${item.password}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
