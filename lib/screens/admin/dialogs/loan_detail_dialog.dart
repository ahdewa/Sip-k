import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/file_saver_helper.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/app_image.dart';
import 'package:simodis_jatim/widgets/pdf_viewer_dialog.dart';

class LoanDetailDialog {
  static void _showSimPhotoViewer(
    BuildContext context,
    String photoSource,
    String borrowerName,
  ) {
    final isDarkViewer = ThemeService.isDarkMode;
    final isPdfDoc = photoSource.startsWith('data:application/pdf') ||
        photoSource.toLowerCase().endsWith('.pdf');

    if (isPdfDoc) {
      PdfViewerDialog.show(
        context,
        docSource: photoSource,
        title: 'Berkas Nota Dinas Pemohon',
        subtitle: 'Pemohon: $borrowerName',
        fileName: 'Nota_Dinas_${borrowerName.replaceAll(' ', '_')}.pdf',
      );
      return;
    }

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
                        child: Icon(
                          isPdfDoc ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
                          color: isPdfDoc ? const Color(0xFFDC2626) : const Color(0xFF24487A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPdfDoc ? 'Dokumen PDF Nota Dinas' : 'Berkas Nota Dinas Pemohon',
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
                // Body Zoomable Image / PDF Document Box
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: isDarkViewer ? const Color(0xFF0B1120) : const Color(0xFF0F172A),
                    child: isPdfDoc
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              margin: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDarkViewer ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkViewer ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.picture_as_pdf_rounded,
                                      size: 54,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Dokumen PDF Nota Dinas Resmi',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkViewer ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Surat usulan / permohonan dinas terlampir dalam format PDF digital.\nBerkas siap diverifikasi untuk persetujuan SPK.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkViewer ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      openOrDownloadDocument(
                                        photoSource,
                                        'Nota_Dinas_${borrowerName.replaceAll(' ', '_')}.pdf',
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                    label: const Text('Buka Dokumen PDF di Tab Baru'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDC2626),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ClipRRect(
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
                                        Icon(Icons.description_outlined, size: 48, color: Colors.white54),
                                        SizedBox(height: 8),
                                        Text(
                                          'Berkas Nota Dinas tidak dapat dimuat',
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
                                isPdfDoc
                                    ? 'Klik tombol merah di atas untuk membaca dokumen PDF secara lengkap'
                                    : 'Gunakan scroll mouse / cubit layar untuk perbesar gambar berkas',
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
    Function(LoanRequest)? onUpdate,
  }) {
    final isDark = ThemeService.isDarkMode;
    final durationDays = loan.endDate.difference(loan.startDate).inDays + 1;
    final isPending =
        loan.status == LoanStatus.menunggu || loan.status == LoanStatus.pending;

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                approve
                    ? 'Sistem akan otomatis menerbitkan Nota Dinas resmi untuk pemohon ${loan.borrowerName}.'
                    : 'Permohonan peminjaman armada oleh ${loan.borrowerName} akan ditolak.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              if (approve) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.3) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.airline_seat_recline_normal_rounded, size: 18, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loan.driverOption,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
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
                          ? 'Permohonan disetujui (${loan.driverOption}). Softfile Nota Dinas otomatis dikirim ke akun pemohon.'
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
      builder: (ctx) {
        bool currentWithDriver = loan.withDriver;
        String currentDriver = loan.driverName ??
            (kAvailableDrivers.isNotEmpty
                ? kAvailableDrivers.first['name']!
                : 'Pak Sugeng Riyadi');

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
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
                  '${loan.scheduleDisplay} ($durationDays Hari Kerja)',
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
                buildPopupDetailRow(
                  'Layanan Sopir Saat Ini',
                  loan.driverOption,
                ),

                if (loan.spkNumber != null) ...[
                  const SizedBox(height: 8),
                  buildPopupDetailRow(
                    'No. Terbit Nota Dinas',
                    loan.spkNumber!,
                  ),
                ],

                const SizedBox(height: 16),

                // ── PANEL EDIT PENUGASAN DRIVER (ADMIN & SUPERADMIN) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF16A34A).withValues(alpha: 0.5)
                          : const Color(0xFF86EFAC),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.airline_seat_recline_normal_rounded,
                            size: 18,
                            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alokasi Pengemudi / Driver Dinas',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF14532D),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Kasubag/Admin dapat mengubah atau menentukan driver penugasan',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF166534),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Edit Driver',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Toggle Opsi Driver: Tanpa Driver / Dengan Driver
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  currentWithDriver = false;
                                  loan.updateDriver(withDriver: false);
                                });
                                if (onUpdate != null) onUpdate(loan);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !currentWithDriver
                                      ? (isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A))
                                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !currentWithDriver
                                        ? Colors.transparent
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Tanpa Driver (Lepas Kunci)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: !currentWithDriver
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  currentWithDriver = true;
                                  loan.updateDriver(withDriver: true, driverName: currentDriver);
                                });
                                if (onUpdate != null) onUpdate(loan);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: currentWithDriver
                                      ? (isDark ? const Color(0xFF16A34A) : const Color(0xFF15803D))
                                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: currentWithDriver
                                        ? Colors.transparent
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Dengan Driver Dinas',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: currentWithDriver
                                        ? Colors.white
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (currentWithDriver) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: kAvailableDrivers.any((d) => d['name'] == currentDriver)
                              ? currentDriver
                              : kAvailableDrivers.first['name'],
                          isExpanded: true,
                          isDense: true,
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                          ),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            prefixIcon: Icon(
                              Icons.badge_rounded,
                              size: 18,
                              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF16A34A),
                                width: 1.5,
                              ),
                            ),
                          ),
                          selectedItemBuilder: (context) {
                            return kAvailableDrivers.map((driver) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  driver['name']!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                          items: kAvailableDrivers.map((driver) {
                            return DropdownMenuItem<String>(
                              value: driver['name'],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      driver['name']!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      driver['detail']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                currentDriver = val;
                                loan.updateDriver(withDriver: true, driverName: val);
                              });
                              if (onUpdate != null) onUpdate(loan);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Dokumen Persyaratan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 8),

                if (loan.simPhotoPath != null && loan.simPhotoPath!.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final docSource = loan.simPhotoPath!;
                      final isPdfDoc = docSource.startsWith('data:application/pdf') ||
                          docSource.toLowerCase().endsWith('.pdf') ||
                          docSource.contains('application/pdf');
                      final pdfFilename =
                          'Nota_Dinas_${loan.borrowerName.replaceAll(' ', '_')}.pdf';

                      return Container(
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
                                Text(
                                  isPdfDoc ? 'Berkas Nota Dinas Terlampir (PDF)' : 'Berkas Nota Dinas Terlampir',
                                  style: const TextStyle(
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
                            if (isPdfDoc) ...[
                              // Dedicated PDF Card with direct in-app interactive preview
                              InkWell(
                                onTap: () => PdfViewerDialog.show(
                                  context,
                                  docSource: docSource,
                                  title: 'Dokumen Nota Dinas - ${loan.borrowerName}',
                                  subtitle: 'Pemohon: ${loan.borrowerName} • ${loan.department}',
                                  fileName: pdfFilename,
                                  loan: loan,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                                          : const Color(0xFFFECACA),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.picture_as_pdf_rounded,
                                          size: 40,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Berkas Nota Dinas Resmi (Format PDF)',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF991B1B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Surat usulan / permohonan dinas terlampir dalam format PDF digital.\nKlik tombol di bawah untuk membaca langsung dokumen di aplikasi.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF7F1D1D),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 10,
                                        runSpacing: 8,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () => PdfViewerDialog.show(
                                              context,
                                              docSource: docSource,
                                              title: 'Dokumen Nota Dinas - ${loan.borrowerName}',
                                              subtitle: 'Pemohon: ${loan.borrowerName} • ${loan.department}',
                                              fileName: pdfFilename,
                                              loan: loan,
                                            ),
                                            icon: const Icon(Icons.visibility_rounded, size: 16),
                                            label: const Text('Lihat Dokumen PDF Langsung'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFDC2626),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              final path = await openOrDownloadDocument(docSource, pdfFilename);
                                              if (ctx.mounted) {
                                                ScaffoldMessenger.of(ctx).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      path != null
                                                          ? 'Dokumen tersimpan di: Download/OVBS/$pdfFilename'
                                                          : 'Dokumen berhasil diunduh.',
                                                    ),
                                                    behavior: SnackBarBehavior.floating,
                                                    backgroundColor: const Color(0xFF24487A),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.download_rounded, size: 15),
                                            label: const Text('Unduh PDF'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: isDark ? Colors.white : const Color(0xFF991B1B),
                                              side: BorderSide(
                                                color: isDark
                                                    ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                                                    : const Color(0xFFFECACA),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Image Preview
                              InkWell(
                                onTap: () => _showSimPhotoViewer(context, docSource, loan.borrowerName),
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
                                          source: docSource,
                                          fit: BoxFit.cover,
                                          placeholder: Center(
                                            child: Icon(
                                              Icons.description_outlined,
                                              size: 40,
                                              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
                                              'Klik Perbesar Berkas',
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
                            ],
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
                                  onTap: () {
                                    if (isPdfDoc) {
                                      PdfViewerDialog.show(
                                        context,
                                        docSource: docSource,
                                        title: 'Dokumen Nota Dinas - ',
                                        subtitle: 'Pemohon:  • ',
                                        fileName: pdfFilename,
                                        loan: loan,
                                      );
                                    } else {
                                      _showSimPhotoViewer(context, docSource, loan.borrowerName);
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isPdfDoc ? Icons.visibility_rounded : Icons.zoom_in_rounded,
                                        size: 15,
                                        color: isPdfDoc ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        isPdfDoc ? 'Lihat Dokumen PDF' : 'Buka Ukuran Penuh',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPdfDoc ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
                            'Berkas Nota Dinas tidak dilampirkan langsung pada formulir. Terverifikasi melalui berkas arsip instansi.',
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
            );
          },
        );
      },
    );
  }
}
