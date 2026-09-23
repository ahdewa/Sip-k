import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/app_image.dart';

class LoanDetailDialog {
  static void _showSimPhotoViewer(
    BuildContext context,
    String photoSource,
    String borrowerName,
  ) {
    final isDarkViewer = ThemeService.isDarkMode;
    showDialog(
      context: context,
      builder: (viewerCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 750, maxHeight: 600),
            decoration: BoxDecoration(
              color: isDarkViewer ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Viewer
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                  decoration: BoxDecoration(
                    color: isDarkViewer ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkViewer ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24487A).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.badge_rounded,
                          color: Color(0xFF24487A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foto Dokumen SIM Pengemudi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDarkViewer ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Pemohon: $borrowerName',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkViewer ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.pop(viewerCtx),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDarkViewer ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body Zoomable Image
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: isDarkViewer ? const Color(0xFF0B1120) : const Color(0xFF0F172A),
                    child: ClipRRect(
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.8,
                        maxScale: 4.0,
                        child: Center(
                          child: AppImage(
                            source: photoSource,
                            fit: BoxFit.contain,
                            placeholder: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.badge_outlined, size: 48, color: Colors.white54),
                                  SizedBox(height: 8),
                                  Text(
                                    'Gambar SIM tidak dapat dimuat',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Footer Hint
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDarkViewer ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                    border: Border(
                      top: BorderSide(
                        color: isDarkViewer ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.pinch_rounded,
                              size: 16,
                              color: isDarkViewer ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Gunakan scroll mouse / cubit layar untuk perbesar SIM',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkViewer ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(viewerCtx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24487A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required LoanRequest loan,
    required Function(LoanRequest, bool) onVerify,
  }) {
    final isDark = ThemeService.isDarkMode;
    final durationDays = loan.endDate.difference(loan.startDate).inDays + 1;
    final isPending =
        loan.status == LoanStatus.menunggu || loan.status == LoanStatus.pending;

    String formatDate(DateTime d) {
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }

    String formatDateTimeFull(DateTime d) {
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} Pukul ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} WIB';
    }

    Widget buildPopupDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            Text(
              ': ',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      );
    }

    void showConfirmApproval(
      BuildContext context,
      LoanRequest loan,
      bool approve,
    ) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            approve ? 'Konfirmasi Terbitkan Nota Dinas?' : 'Tolak Permohonan?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  approve
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
            ),
          ),
          content: Text(
            approve
                ? 'Sistem akan otomatis mengirimkan Softfile Nota Dinas resmi ke akun pemohon ${loan.borrowerName} untuk dicetak.'
                : 'Permohonan peminjaman armada oleh ${loan.borrowerName} akan ditolak.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onVerify(loan, approve);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      approve
                          ? 'Permohonan disetujui. Softfile Nota Dinas otomatis dikirim ke akun pemohon.'
                          : 'Permohonan telah ditolak.',
                    ),
                    backgroundColor:
                        approve
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    approve
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: Text(approve ? 'Ya, Terbitkan' : 'Ya, Tolak'),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Pengajuan Peminjaman',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Registrasi: ${loan.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                  ),
                ),
                Divider(
                  height: 20,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),

                // Informasi Waktu Masuk Sistem (Jam & Menit)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled_rounded,
                        size: 20,
                        color: Color(0xFF24487A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu Pengajuan Diterima:',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              formatDateTimeFull(loan.submittedAt),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Data Pemohon & Kendaraan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),
                buildPopupDetailRow('Nama Pemohon', loan.borrowerName),
                buildPopupDetailRow(
                  'Unit Kerja / Bidang',
                  loan.department.isEmpty
                      ? 'Dinas Sosial Jatim'
                      : loan.department,
                ),
                buildPopupDetailRow('Armada Diajukan', loan.vehicleName),
                buildPopupDetailRow(
                  'Jadwal Tugas',
                  '${formatDate(loan.startDate)} s/d ${formatDate(loan.endDate)} ($durationDays Hari Kerja)',
                ),

                const SizedBox(height: 14),
                Text(
                  'Rincian Penugasan Dinas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),
                buildPopupDetailRow('Tujuan Dinas', loan.destination),
                buildPopupDetailRow(
                  'Alamat Lengkap',
                  loan.destinationAddress.isEmpty
                      ? 'Area Kota / UPT Terkait'
                      : loan.destinationAddress,
                ),
                buildPopupDetailRow(
                  'Deskripsi Keperluan',
                  loan.purposeDescription.isEmpty
                      ? '-'
                      : loan.purposeDescription,
                ),
                buildPopupDetailRow(
                  'Nomor Nota Dinas',
                  loan.officialNoteNumber.isEmpty
                      ? '-'
                      : loan.officialNoteNumber,
                ),
                buildPopupDetailRow(
                  'Surat Usulan Bidang',
                  'Terlampir & Tervalidasi E-Office',
                ),

                if (loan.spkNumber != null) ...[
                  const SizedBox(height: 8),
                  buildPopupDetailRow(
                    'No. Terbit Nota Dinas',
                    loan.spkNumber!,
                  ),
                ],

                const SizedBox(height: 16),
                Text(
                  'Dokumen Persyaratan & SIM Pengemudi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),

                if (loan.simPhotoPath != null && loan.simPhotoPath!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Foto SIM Terlampir Pemohon',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Siap Diverifikasi',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Preview Card with hover & click to zoom
                        InkWell(
                          onTap: () => _showSimPhotoViewer(context, loan.simPhotoPath!, loan.borrowerName),
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  height: 165,
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                  child: AppImage(
                                    source: loan.simPhotoPath!,
                                    fit: BoxFit.cover,
                                    placeholder: Center(
                                      child: Icon(
                                        Icons.badge_outlined,
                                        size: 40,
                                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Overlay button
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Klik Perbesar SIM',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Atas Nama: ${loan.borrowerName}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            InkWell(
                              onTap: () => _showSimPhotoViewer(context, loan.simPhotoPath!, loan.borrowerName),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in_rounded, size: 15, color: Color(0xFF2563EB)),
                                  SizedBox(width: 3),
                                  Text(
                                    'Buka Ukuran Penuh',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Foto SIM tidak dilampirkan langsung pada formulir. Terverifikasi melalui berkas arsip pengemudi instansi.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // TOMBOL ATAS-BAWAH HANYA MUNCUL JIKA STATUS MASIH MENUNGGU
                if (isPending) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        showConfirmApproval(context, loan, true);
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Setujui & Terbitkan Nota Dinas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        showConfirmApproval(context, loan, false);
                      },
                      icon: const Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: Color(0xFFDC2626),
                      ),
                      label: const Text(
                        'Tolak Permohonan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
