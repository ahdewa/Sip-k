import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/file_saver_helper.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class PdfViewerDialog extends StatelessWidget {
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

  /// Resolve raw bytes PDF dari base64, URL http, atau generate berkas resmi Nota Dinas
  static Future<Uint8List> resolvePdfBytes(String docSource, {LoanRequest? loan}) async {
    try {
      if (docSource.startsWith('data:')) {
        final commaIdx = docSource.indexOf(',');
        if (commaIdx != -1) {
          final rawData = docSource.substring(commaIdx + 1);
          final bytes = base64Decode(rawData);
          if (bytes.length > 4 &&
              bytes[0] == 0x25 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x44 &&
              bytes[3] == 0x46) {
            return bytes;
          }
        }
      } else if (docSource.startsWith('http://') || docSource.startsWith('https://')) {
        final res = await http.get(Uri.parse(docSource));
        if (res.statusCode == 200 &&
            res.bodyBytes.length > 4 &&
            res.bodyBytes[0] == 0x25 &&
            res.bodyBytes[1] == 0x50) {
          return res.bodyBytes;
        }
      } else if (docSource.length > 100 &&
          !docSource.contains('\n') &&
          !docSource.startsWith('assets/')) {
        try {
          final bytes = base64Decode(docSource);
          if (bytes.length > 4 && bytes[0] == 0x25) {
            return bytes;
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('PdfViewerDialog resolvePdfBytes error: $e');
    }

    // Fallback: Generate dokumen Nota Dinas resmi pemohon secara dinamis
    return await generateNotaDinasDocument(loan);
  }

  /// Generate dokumen PDF Nota Dinas resmi dengan kop surat Pemprov Jatim
  static Future<Uint8List> generateNotaDinasDocument(LoanRequest? loan) async {
    final pdf = pw.Document();
    final regNumber = loan?.officialNoteNumber.isNotEmpty == true && loan?.officialNoteNumber != '-'
        ? loan!.officialNoteNumber
        : (loan?.spkNumber ?? 'ND-0901/DINSOS/${DateTime.now().year}');

    final borrower = loan?.borrowerName ?? 'Pemohon Terdaftar';
    final nip = loan?.nip ?? '-';
    final department = loan?.department ?? 'Dinas Sosial Provinsi Jawa Timur';
    final vehicle = loan?.vehicleName ?? 'Kendaraan Operasional Dinas';
    final destination = loan?.destination ?? 'Wilayah Jawa Timur';
    final destAddress = loan?.destinationAddress.isNotEmpty == true ? loan!.destinationAddress : '-';
    final purpose = loan?.purposeDescription.isNotEmpty == true
        ? loan!.purposeDescription
        : 'Kegiatan Perjalanan Dinas Operasional';
    final driverMode = loan != null
        ? (loan.withDriver
            ? 'Dengan Driver Dinas (${loan.driverName ?? "Driver Ditugaskan"})'
            : 'Tanpa Driver (Lepas Kunci)')
        : 'Dengan Driver Dinas';
    final dateRange = loan != null
        ? '${loan.startDate.day.toString().padLeft(2, '0')}/${loan.startDate.month.toString().padLeft(2, '0')}/${loan.startDate.year} s/d ${loan.endDate.day.toString().padLeft(2, '0')}/${loan.endDate.month.toString().padLeft(2, '0')}/${loan.endDate.year}'
        : '-';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kop Surat Pemprov Jatim
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PEMERINTAH PROVINSI JAWA TIMUR',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'DINAS SOSIAL',
                      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Jl. Gayung Kebonsari No. 56 Gayungan, Kec. Gayungan, Surabaya, Jawa Timur 60235',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Divider(thickness: 2),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'NOTA DINAS USULAN PEMINJAMAN KENDARAAN',
                      style: pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Nomor: $regNumber',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              // Header Surat
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FixedColumnWidth(15),
                  2: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text('Kepada', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Kepala Dinas Sosial Provinsi Jawa Timur',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Dari', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('$borrower ($department)', style: const pw.TextStyle(fontSize: 10)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Tanggal', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      loan != null
                          ? '${loan.submittedAt.day.toString().padLeft(2, '0')}/${loan.submittedAt.month.toString().padLeft(2, '0')}/${loan.submittedAt.year}'
                          : '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Hal', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Permohonan Peminjaman Kendaraan Dinas Operasional',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 10),
              pw.Text(
                'RINCIAN PERMOHONAN PENUGASAN:',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(130),
                  1: const pw.FixedColumnWidth(15),
                  2: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text('Nama Pemohon', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(borrower, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('NIP / No. Identitas', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(nip, style: const pw.TextStyle(fontSize: 9.5)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Bidang / Seksi', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(department, style: const pw.TextStyle(fontSize: 9.5)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Unit Kendaraan', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(vehicle, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Tujuan Perjalanan', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(destination, style: const pw.TextStyle(fontSize: 9.5)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Alamat Tujuan', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(destAddress, style: const pw.TextStyle(fontSize: 9.5)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Jadwal Pelaksanaan', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(dateRange, style: const pw.TextStyle(fontSize: 9.5)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Waktu Pemakaian', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(
                      '${loan?.startTime ?? "08:00"} s/d ${loan?.endTime ?? "16:00"} WIB',
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Layanan Driver', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(driverMode, style: const pw.TextStyle(fontSize: 9.5)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Keperluan / Agenda', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(':', style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(purpose, style: const pw.TextStyle(fontSize: 9.5)),
                  ]),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Demikian nota dinas permohonan ini kami sampaikan untuk dapat diperiksa, diverifikasi, dan disetujui guna mendukung kelancaran pelaksanaan tugas kedinasan. Atas kebijaksanaan dan perkenan Bapak disampaikan terima kasih.',
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.3),
              ),
              pw.Spacer(),
              // Tanda Tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Mengetahui / Verifikator Aset,', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 44),
                      pw.Text('Kasubag Tata Usaha',
                          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                      pw.Text('NIP. 19780512 200501 1 008', style: const pw.TextStyle(fontSize: 8.5)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Pemohon / Yang Mengajukan,', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 44),
                      pw.Text(borrower,
                          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                      pw.Text('NIP. $nip', style: const pw.TextStyle(fontSize: 8.5)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    return pdf.save();
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
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
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
                    // Tombol Unduh ke Download/OVBS
                    IconButton(
                      tooltip: 'Simpan ke Download/OVBS',
                      onPressed: () async {
                        final bytes = await resolvePdfBytes(docSource, loan: loan);
                        final path = saveAndDownloadFile(bytes, fileName, 'application/pdf');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                path != null
                                    ? 'Dokumen tersimpan di: Download/OVBS/$fileName'
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
                    build: (format) => resolvePdfBytes(docSource, loan: loan),
                    pdfFileName: fileName,
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
                            'Memuat berkas PDF...',
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
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 15,
                      color: const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Dokumen digital resmi SIP-K Dinas Sosial Jawa Timur',
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
