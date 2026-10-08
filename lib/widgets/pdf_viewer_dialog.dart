import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/file_saver_helper.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class PdfViewerDialog extends StatefulWidget {
  final String docSource;
  final String title;
  final String? subtitle;
  final String fileName;
  final LoanRequest? loan;

  const PdfViewerDialog({
    super.key,
    required this.docSource,
    required this.title,
    this.subtitle,
    required this.fileName,
    this.loan,
  });

  /// Buka modal interaktif penampil PDF langsung di dalam aplikasi
  static void show(
    BuildContext context, {
    required String docSource,
    required String title,
    String? subtitle,
    required String fileName,
    LoanRequest? loan,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PdfViewerDialog(
        docSource: docSource,
        title: title,
        subtitle: subtitle,
        fileName: fileName,
        loan: loan,
      ),
    );
  }

  /// Generate dokumen PDF Nota Dinas resmi sesuai format Pemprov Jatim
  /// serta menyertakan lampiran foto/dokumen yang diunggah pemohon
  static Future<Uint8List> generateNotaDinasDocument(LoanRequest? loan) async {
    final pdf = pw.Document();

    // 1. Muat Logo Jawa Timur
    Uint8List? logoBytes;
    try {
      final byteData = await rootBundle.load('assets/images/logo_jatim.png');
      logoBytes = byteData.buffer.asUint8List();
    } catch (_) {
      try {
        final byteData = await rootBundle.load('assets/images/logo_sipk.png');
        logoBytes = byteData.buffer.asUint8List();
      } catch (_) {}
    }

    // 2. Ekstrak data lampiran yang diupload user (Foto / Gambar)
    Uint8List? uploadedImageBytes;
    if (loan?.simPhotoPath != null && loan!.simPhotoPath!.isNotEmpty) {
      final path = loan.simPhotoPath!;
      if (path.startsWith('data:image/')) {
        final comma = path.indexOf(',');
        if (comma != -1) {
          try {
            uploadedImageBytes = base64Decode(path.substring(comma + 1));
          } catch (_) {}
        }
      } else if (path.startsWith('http://') || path.startsWith('https://')) {
        if (!path.toLowerCase().endsWith('.pdf')) {
          try {
            final res = await http.get(Uri.parse(path));
            if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
              uploadedImageBytes = res.bodyBytes;
            }
          } catch (_) {}
        }
      } else if (!path.startsWith('data:application/pdf') &&
          !path.toLowerCase().endsWith('.pdf') &&
          path.length > 80 &&
          !path.startsWith('assets/')) {
        try {
          uploadedImageBytes = base64Decode(path);
        } catch (_) {}
      }
    }

    final regNumber = loan?.officialNoteNumber.isNotEmpty == true && loan?.officialNoteNumber != '-'
        ? loan!.officialNoteNumber
        : (loan?.spkNumber ?? 'ND-0901/DINSOS/${DateTime.now().year}');

    final borrower = loan?.borrowerName ?? 'Pemohon Terdaftar';
    final nip = (loan?.nip != null && loan!.nip!.isNotEmpty) ? loan.nip! : '-';
    final department = loan?.department.isNotEmpty == true
        ? loan!.department
        : 'Bidang Penanganan Fakir Miskin';
    final vehicle = loan?.vehicleName ?? 'Toyota Avanza 1.3 Veloz (L 1455 EP)';
    final destination = loan?.destination.isNotEmpty == true
        ? loan!.destination
        : 'Kota Surabaya';
    final destAddress = (loan?.destinationAddress.isNotEmpty == true && loan!.destinationAddress != '-')
        ? loan.destinationAddress
        : '-';

    // Bersihkan tujuan narasi
    String purposeClean = loan?.purposeDescription ?? 'Kegiatan Operasional Kedinasan';
    if (purposeClean.contains('\n')) {
      purposeClean = purposeClean.split('\n').first.trim();
    }
    if (purposeClean.isEmpty) purposeClean = 'Kegiatan Operasional Kedinasan';

    final driverMode = loan != null
        ? (loan.withDriver
            ? 'Dengan Driver Dinas${loan.driverName != null ? " (${loan.driverName})" : ""}'
            : 'Tanpa Driver (Lepas Kunci)')
        : 'Dengan Driver Dinas';

    String formatDate(DateTime d) {
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

    final dateFormatted = loan != null ? formatDate(loan.submittedAt) : formatDate(DateTime.now());
    final dateRange = loan != null
        ? '${formatDate(loan.startDate)} s.d ${formatDate(loan.endDate)}'
        : formatDate(DateTime.now());

    // Helper Baris Metadata (KEPADA, DARI, dll.)
    pw.TableRow buildMetaRow(String label, String value) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2.2),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                fontFallback: const [],
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2.2),
            child: pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2.2),
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: label == 'KEPADA' || label == 'PERIHAL' ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    // Helper Baris Deskripsi Tabel
    pw.TableRow buildDescRow(String label, String val, {bool isBold = false}) {
      return pw.TableRow(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 8),
            color: PdfColors.grey100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 8),
            child: pw.Text(
              val,
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    // ==========================================
    // HALAMAN 1: LEMBAR NOTA DINAS RESMI
    // ==========================================
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 34),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. KOP SURAT (LOGO JATIM & ALAMAT RESMI)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoBytes != null) ...[
                    pw.Image(
                      pw.MemoryImage(logoBytes),
                      width: 54,
                      height: 64,
                      fit: pw.BoxFit.contain,
                    ),
                    pw.SizedBox(width: 12),
                  ],
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'PEMERINTAH PROVINSI JAWA TIMUR',
                          style: pw.TextStyle(
                            fontSize: 11.5,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        pw.Text(
                          'DINAS SOSIAL',
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.SizedBox(height: 1.5),
                        pw.Text(
                          'Jalan Gayung Kebonsari No.56b, Gayungan, Surabaya, Jawa Timur 60235',
                          style: const pw.TextStyle(fontSize: 8.5),
                        ),
                        pw.Text(
                          'Tlp./Fax (031) 8290794 – 826515 Laman dinsos.jatimprov.go.id',
                          style: const pw.TextStyle(fontSize: 8.5),
                        ),
                        pw.Text(
                          'Pos-el dinsosjatim56b@gmail.com',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            color: PdfColors.blue800,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (logoBytes != null) pw.SizedBox(width: 54), // Penyeimbang center
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1.2, color: PdfColors.black),
              pw.SizedBox(height: 10),

              // 2. JUDUL NOTA DINAS
              pw.Center(
                child: pw.Text(
                  'NOTA DINAS',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),

              // 3. TABEL KEPALA SURAT (KEPADA, DARI, TANGGAL, NOMOR, SIFAT, LAMPIRAN, PERIHAL)
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(85),
                  1: const pw.FixedColumnWidth(14),
                  2: const pw.FlexColumnWidth(),
                },
                children: [
                  buildMetaRow('KEPADA', 'Yth. Kepala Dinas Sosial Provinsi Jawa Timur'),
                  buildMetaRow('DARI', department),
                  buildMetaRow('TANGGAL', dateFormatted),
                  buildMetaRow('NOMOR', regNumber),
                  buildMetaRow('SIFAT', 'Terbuka'),
                  buildMetaRow(
                    'LAMPIRAN',
                    uploadedImageBytes != null ? '1 (satu) Berkas' : '-',
                  ),
                  buildMetaRow('PERIHAL', 'Permohonan Peminjaman Kendaraan Dinas'),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.8, color: PdfColors.black),
              pw.SizedBox(height: 10),

              // 4. PARAGRAF NARASI (PERSIS SESUAI GAMBAR DAN DATA FORM PEMINJAMAN)
              pw.Paragraph(
                text:
                    'Dalam rangka mendukung operasional $department pada tanggal $dateRange dalam kegiatan di Kabupaten/Kota $destination, dan untuk keperluan $purposeClean maka diperlukan 1 unit Kendaraan Operasional ($vehicle), sehubungan dengan hal tersebut bersama ini diajukan permohonan peminjaman kendaraan operasional yang dimaksud dengan deskripsi sebagai berikut :',
                style: const pw.TextStyle(fontSize: 9.3, lineSpacing: 1.4),
              ),
              pw.SizedBox(height: 6),

              // 5. TABEL RINCIAN DESKRIPSI PEMINJAMAN
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(130),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  buildDescRow('Nama Pemohon', borrower, isBold: true),
                  buildDescRow('NIP / Nomor Identitas', nip),
                  buildDescRow('Bidang / Unit Kerja', department),
                  buildDescRow('Unit Kendaraan Dinas', vehicle, isBold: true),
                  buildDescRow('Kota / Daerah Tujuan', destination),
                  if (destAddress.isNotEmpty && destAddress != '-')
                    buildDescRow('Alamat Lokasi Tujuan', destAddress),
                  buildDescRow('Jadwal Pelaksanaan', dateRange),
                  buildDescRow(
                    'Jam Operasional',
                    '${loan?.startTime ?? "08:00"} s/d ${loan?.endTime ?? "16:00"} WIB',
                  ),
                  buildDescRow('Layanan Pengemudi', driverMode),
                  buildDescRow('Keperluan / Agenda', purposeClean),
                ],
              ),
              pw.SizedBox(height: 12),

              // 6. KALIMAT PENUTUP
              pw.Text(
                'Demikian atas bantuan dan kerjasamanya, dihaturkan terima kasih.',
                style: const pw.TextStyle(fontSize: 9.5),
              ),
              pw.SizedBox(height: 14),

              // 7. KOTAK TANDA TANGAN (SIGNATURE BOX SEBELAH KANAN SESUAI GAMBAR)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                'Kepala ${department.isNotEmpty ? department : "Bidang"}',
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.SizedBox(height: 42), // Ruang Tanda Tangan
                              pw.Text(
                                borrower,
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  decoration: pw.TextDecoration.underline,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'NIP. $nip',
                                style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        pw.Divider(thickness: 0.8, color: PdfColors.black, height: 1),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          color: PdfColors.grey100,
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Catatan / Disposisi Kasubag TU:',
                                style: pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                              ),
                              pw.SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // ==========================================
    // HALAMAN 2: LAMPIRAN FOTO/BERKAS USER (JIKA ADA)
    // ==========================================
    if (uploadedImageBytes != null) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 34),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Lampiran
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'LAMPIRAN NOTA DINAS',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Nomor: $regNumber', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text(
                          'Pemohon: $borrower ($department)',
                          style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    if (logoBytes != null)
                      pw.Image(
                        pw.MemoryImage(logoBytes),
                        width: 36,
                        height: 42,
                        fit: pw.BoxFit.contain,
                      ),
                  ],
                ),
                pw.Divider(thickness: 1, color: PdfColors.black),
                pw.SizedBox(height: 10),
                pw.Text(
                  'BERKAS DOKUMEN / FOTO YANG DIUNGGAH OLEH PEMOHON:',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Image(
                        pw.MemoryImage(uploadedImageBytes!),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Lampiran ini merupakan kelengkapan berkas resmi yang diunggah pemohon pada aplikasi SIP-K Dinas Sosial Jawa Timur.',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// Resolve raw bytes PDF jika user mengunggah PDF asli
  static Future<Uint8List?> tryResolveUploadedPdfBytes(String docSource) async {
    try {
      if (docSource.contains('base64,')) {
        final commaIdx = docSource.indexOf('base64,');
        final rawData = docSource.substring(commaIdx + 7).trim();
        final bytes = base64Decode(rawData);
        if (bytes.length > 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46) {
          return bytes;
        }
      } else if (docSource.startsWith('data:') && docSource.contains(',')) {
        final commaIdx = docSource.indexOf(',');
        final rawData = docSource.substring(commaIdx + 1).trim();
        final bytes = base64Decode(rawData);
        if (bytes.length > 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46) {
          return bytes;
        }
      } else if (docSource.startsWith('http://') || docSource.startsWith('https://')) {
        final res = await http.get(Uri.parse(docSource));
        if (res.statusCode == 200 &&
            res.bodyBytes.length > 4 &&
            res.bodyBytes[0] == 0x25 &&
            res.bodyBytes[1] == 0x50) {
          return res.bodyBytes;
        }
      } else if (docSource.length > 100 && !docSource.startsWith('assets/')) {
        try {
          final bytes = base64Decode(docSource.trim());
          if (bytes.length > 4 &&
              bytes[0] == 0x25 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x44 &&
              bytes[3] == 0x46) {
            return bytes;
          }
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  bool _showRawUploadedPdf = false;
  bool _hasRawUploadedPdf = false;

  @override
  void initState() {
    super.initState();
    _checkUploadedPdf();
  }

  void _checkUploadedPdf() {
    final src = widget.docSource;
    if (src.startsWith('data:application/pdf') ||
        src.startsWith('data:application/x-pdf') ||
        src.contains('application/pdf') ||
        (src.startsWith('http') && src.toLowerCase().endsWith('.pdf')) ||
        (src.startsWith('http') && src.contains('/loan_documents/'))) {
      _hasRawUploadedPdf = true;
      _showRawUploadedPdf = true; // Default langsung tampilkan PDF asli yang diunggah pemohon
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 820,
            maxHeight: (screenHeight * 0.94).clamp(520, 920),
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Modal
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
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
                        color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _showRawUploadedPdf
                                ? 'Berkas PDF Asli dari Pemohon'
                                : widget.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Jika user upload PDF asli, beri tombol toggle
                    if (_hasRawUploadedPdf) ...[
                      Tooltip(
                        message: _showRawUploadedPdf
                            ? 'Beralih ke Nota Dinas Standar'
                            : 'Lihat Berkas PDF Asli Pemohon',
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showRawUploadedPdf = !_showRawUploadedPdf;
                            });
                          },
                          icon: Icon(
                            _showRawUploadedPdf
                                ? Icons.description_rounded
                                : Icons.file_present_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _showRawUploadedPdf ? 'Nota Standar' : 'PDF Pemohon',
                            style: const TextStyle(fontSize: 11),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF24487A),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    // Tombol Unduh ke Download/OVBS
                    IconButton(
                      tooltip: 'Simpan ke Download/OVBS',
                      onPressed: () async {
                        final bytes = _showRawUploadedPdf
                            ? (await PdfViewerDialog.tryResolveUploadedPdfBytes(widget.docSource) ??
                                await PdfViewerDialog.generateNotaDinasDocument(widget.loan))
                            : await PdfViewerDialog.generateNotaDinasDocument(widget.loan);
                        final path = saveAndDownloadFile(bytes, widget.fileName, 'application/pdf');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                path != null
                                    ? 'Dokumen tersimpan di: Download/OVBS/${widget.fileName}'
                                    : 'Dokumen berhasil diunduh.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF24487A),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.download_rounded, color: Color(0xFF24487A)),
                    ),
                    IconButton(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive PDF Preview Body
              Expanded(
                child: ClipRRect(
                  child: PdfPreview(
                    build: (format) async {
                      if (_showRawUploadedPdf) {
                        final raw = await PdfViewerDialog.tryResolveUploadedPdfBytes(widget.docSource);
                        if (raw != null) return raw;
                      }
                      return await PdfViewerDialog.generateNotaDinasDocument(widget.loan);
                    },
                    pdfFileName: widget.fileName,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    allowPrinting: true,
                    allowSharing: true,
                    maxPageWidth: 680,
                    previewPageMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    loadingWidget: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(strokeWidth: 3),
                          const SizedBox(height: 12),
                          Text(
                            'Menyiapkan lembar Nota Dinas...',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onError: (ctx, err) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Gagal menampilkan PDF: $err',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Footer Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Format Standar Nota Dinas Pemprov Jatim • Dinas Sosial',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    );
  }
}
