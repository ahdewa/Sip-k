import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/file_saver_helper.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/app_image.dart';
import 'package:simodis_jatim/widgets/pdf_viewer_dialog.dart';

class NotaDinasDialog extends StatelessWidget {
  final LoanRequest loan;

  const NotaDinasDialog({super.key, required this.loan});

  String _formatDate(DateTime d) {
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  Future<void> _generateAndDownloadPdf(BuildContext context) async {
    final bytes = await PdfViewerDialog.generateNotaDinasDocument(loan);
    final safeId = loan.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = 'Nota_Dinas_$safeId.pdf';
    final savedPath = saveAndDownloadFile(bytes, filename, 'application/pdf');

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath != null
                ? 'Berkas tersimpan di: Download/OVBS/$filename'
                : 'Berkas Nota Dinas berhasil diunduh ke folder Download/OVBS.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF24487A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final regNumber = loan.officialNoteNumber.isNotEmpty && loan.officialNoteNumber != '-'
        ? loan.officialNoteNumber
        : (loan.spkNumber ?? 'ND-0901/DINSOS/${DateTime.now().year}');

    final department = loan.department.isNotEmpty ? loan.department : 'Bidang Penanganan Fakir Miskin';
    final dateRange = '${_formatDate(loan.startDate)} s.d ${_formatDate(loan.endDate)}';
    String purposeClean = loan.purposeDescription;
    if (purposeClean.contains('\n')) {
      purposeClean = purposeClean.split('\n').first.trim();
    }
    if (purposeClean.isEmpty) purposeClean = 'kegiatan perjalanan dinas operasional';

    final hasUploadedFile = loan.simPhotoPath != null && loan.simPhotoPath!.isNotEmpty;
    final isUploadedImage = hasUploadedFile &&
        !loan.simPhotoPath!.startsWith('data:application/pdf') &&
        !loan.simPhotoPath!.toLowerCase().endsWith('.pdf');

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 620),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Dialog (Judul & Tombol Tutup)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description_rounded, size: 20, color: Color(0xFF24487A)),
                      const SizedBox(width: 8),
                      Text(
                        'Lembar Nota Dinas Resmi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // AREA LEMBAR DOKUMEN CETAK (PERSIS SESUAI GAMBAR TEMPLATE)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KOP SURAT (LOGO JATIM & TEKS CENTER)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo_jatim.png',
                          width: 44,
                          height: 52,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/logo_sipk.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                'PEMERINTAH PROVINSI JAWA TIMUR',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'DINAS SOSIAL',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Jalan Gayung Kebonsari No.56b, Gayungan, Surabaya, Jawa Timur 60235',
                                style: TextStyle(fontSize: 7.5, color: Color(0xFF334155)),
                              ),
                              Text(
                                'Tlp./Fax (031) 8290794 – 826515 Laman dinsos.jatimprov.go.id',
                                style: TextStyle(fontSize: 7.5, color: Color(0xFF334155)),
                              ),
                              Text(
                                'Pos-el dinsosjatim56b@gmail.com',
                                style: TextStyle(
                                  fontSize: 7.5,
                                  color: Color(0xFF1D4ED8),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 44), // Penyeimbang center
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(height: 1.5, color: Colors.black),
                    const SizedBox(height: 10),

                    // JUDUL NOTA DINAS
                    const Center(
                      child: Text(
                        'NOTA DINAS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TABEL KEPALA SURAT
                    _buildRowText('KEPADA', 'Yth. Kepala Dinas Sosial Provinsi Jawa Timur', isBoldVal: true),
                    _buildRowText('DARI', department),
                    _buildRowText('TANGGAL', _formatDate(loan.submittedAt)),
                    _buildRowText('NOMOR', regNumber),
                    _buildRowText('SIFAT', 'Terbuka'),
                    _buildRowText('LAMPIRAN', hasUploadedFile ? '1 (satu) Berkas' : '-'),
                    _buildRowText('PERIHAL', 'Permohonan Peminjaman Kendaraan Dinas', isBoldVal: true),

                    const SizedBox(height: 8),
                    Container(height: 1, color: Colors.black),
                    const SizedBox(height: 10),

                    // PARAGRAF NARASI
                    Text(
                      'Dalam rangka mendukung operasional $department pada tanggal $dateRange dalam kegiatan di Kabupaten/Kota ${loan.destination}, dan untuk keperluan $purposeClean maka diperlukan 1 unit Kendaraan Operasional (${loan.vehicleName}), sehubungan dengan hal tersebut bersama ini diajukan permohonan peminjaman kendaraan operasional yang dimaksud dengan deskripsi sebagai berikut :',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF1E293B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // TABEL DESKRIPSI PEMINJAMAN
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          _buildTableItem('Nama Pemohon', loan.borrowerName, isBold: true),
                          _buildTableItem('NIP / No. Identitas', loan.nip ?? '-'),
                          _buildTableItem('Bidang / Unit Kerja', department),
                          _buildTableItem('Unit Kendaraan', loan.vehicleName, isBold: true),
                          _buildTableItem('Kota Tujuan', loan.destination),
                          if (loan.destinationAddress.isNotEmpty && loan.destinationAddress != '-')
                            _buildTableItem('Alamat Lokasi', loan.destinationAddress),
                          _buildTableItem('Jadwal Pelaksanaan', dateRange),
                          _buildTableItem(
                            'Jam Operasional',
                            '${loan.startTime ?? "08:00"} s/d ${loan.endTime ?? "16:00"} WIB',
                          ),
                          _buildTableItem(
                            'Layanan Driver',
                            loan.withDriver
                                ? 'Dengan Driver Dinas${loan.driverName != null ? " (${loan.driverName})" : ""}'
                                : 'Tanpa Driver (Lepas Kunci)',
                          ),
                          _buildTableItem('Keperluan / Agenda', purposeClean),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // KALIMAT PENUTUP
                    const Text(
                      'Demikian atas bantuan dan kerjasamanya, dihaturkan terima kasih.',
                      style: TextStyle(fontSize: 9.5, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 14),

                    // KOTAK TANDA TANGAN (SEBELAH KANAN SESUAI GAMBAR)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.8),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              child: Column(
                                children: [
                                  Text(
                                    'Kepala $department',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 38), // Ruang Tanda Tangan
                                  Text(
                                    loan.borrowerName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'NIP. ${loan.nip ?? "-"}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 7.5, color: Color(0xFF334155)),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 0.8, color: Colors.black),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(5),
                              color: const Color(0xFFF8FAFC),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Catatan / Disposisi Kasubag TU:',
                                    style: TextStyle(fontSize: 7, color: Color(0xFF64748B)),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // LAMPIRAN GAMBAR DARI USER (JIKA ADA)
                    if (isUploadedImage) ...[
                      const SizedBox(height: 16),
                      Container(height: 1, color: const Color(0xFFE2E8F0)),
                      const SizedBox(height: 8),
                      const Text(
                        'Lampiran Berkas yang Diunggah Pemohon:',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF24487A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9),
                          child: AppImage(
                            source: loan.simPhotoPath!,
                            fit: BoxFit.contain,
                            placeholder: const Center(
                              child: Icon(Icons.image_outlined, size: 36, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TOMBOL AKSI
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _generateAndDownloadPdf(context),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text(
                        'Unduh PDF',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF24487A),
                        side: const BorderSide(color: Color(0xFF24487A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        PdfViewerDialog.show(
                          context,
                          docSource: loan.simPhotoPath ?? '',
                          title: 'Dokumen Nota Dinas - ${loan.borrowerName}',
                          subtitle: 'Pemohon: ${loan.borrowerName} • $department',
                          fileName: 'Nota_Dinas_${loan.id}.pdf',
                          loan: loan,
                        );
                      },
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: const Text(
                        'Buka Preview PDF',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowText(String label, String value, {bool isBoldVal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 9, color: Colors.black)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isBoldVal ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableItem(String label, String val, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 8.5, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
