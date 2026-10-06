import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class AdminInfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdminInfoLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 100,
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
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class AdminLoanCard extends StatelessWidget {
  final LoanRequest item;
  final VoidCallback onShowDetail;
  final VoidCallback onShowReturn;

  const AdminLoanCard({
    super.key,
    required this.item,
    required this.onShowDetail,
    required this.onShowReturn,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    Color badgeBg;
    Color badgeText;
    String statusTitle;

    switch (item.status) {
      case LoanStatus.disetujui:
      case LoanStatus.approved:
        badgeBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
        badgeText = isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
        statusTitle = 'DISETUJUI (NOTA DINAS TERBIT)';
        break;
      case LoanStatus.digunakan:
        badgeBg = isDark ? const Color(0xFF075985) : const Color(0xFFE0F2FE);
        badgeText = isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7);
        statusTitle = 'SEDANG DIGUNAKAN';
        break;
      case LoanStatus.ditolak:
      case LoanStatus.rejected:
        badgeBg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
        badgeText = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        statusTitle = 'DITOLAK';
        break;
      case LoanStatus.selesai:
        badgeBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        badgeText = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
        statusTitle = 'SELESAI (BAST TUNTAS)';
        break;
      default:
        badgeBg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        badgeText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        statusTitle = 'MENUNGGU VERIFIKASI';
    }

    final isPending =
        item.status == LoanStatus.menunggu || item.status == LoanStatus.pending;
    final isActive =
        item.status == LoanStatus.disetujui ||
        item.status == LoanStatus.approved ||
        item.status == LoanStatus.digunakan;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.vehicleName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (item.isNewSubmission && isPending) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fiber_new_rounded,
                                    size: 13,
                                    color: Color(0xFFDC2626),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'BARU',
                                    style: TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusTitle,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pemohon: ${item.borrowerName} • ${item.department}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 10),
                AdminInfoLine(
                  icon: Icons.history_toggle_off_rounded,
                  label: 'Waktu Pengajuan',
                  value: '${item.formattedSubmittedAt} • ${item.timeAgoSubmitted}',
                ),
                const SizedBox(height: 4),
                AdminInfoLine(
                  icon: Icons.calendar_month_rounded,
                  label: 'Jadwal',
                  value: item.scheduleDisplay,
                ),
                const SizedBox(height: 4),
                AdminInfoLine(
                  icon: Icons.near_me_rounded,
                  label: 'Tujuan',
                  value: item.destination,
                ),
                const SizedBox(height: 4),
                AdminInfoLine(
                  icon: Icons.description_outlined,
                  label: 'Nota Dinas',
                  value:
                      item.officialNoteNumber.isEmpty
                          ? '-'
                          : item.officialNoteNumber,
                ),
                const SizedBox(height: 4),
                AdminInfoLine(
                  icon: Icons.airline_seat_recline_normal_rounded,
                  label: 'Layanan Sopir',
                  value: item.driverOption,
                ),
                if (item.spkNumber != null) ...[
                  const SizedBox(height: 4),
                  AdminInfoLine(
                    icon: Icons.badge_outlined,
                    label: 'No. Register',
                    value: item.spkNumber!,
                  ),
                ],
              ],
            ),
          ),

          // FOOTER KARTU MENUNGGU VERIFIKASI: HANYA ADA TOMBOL "LIHAT DETAIL" DI KIRI BAWAH
          if (isPending) ...[
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onShowDetail,
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text(
                    'Lihat Detail Pengajuan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],

          // FOOTER KARTU AKTIF: PROSES BAST (OPSI SELESAI LEBIH AWAL) & INFO BATAS 23:59
          if (isActive) ...[
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onShowReturn,
                  icon: const Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Terima Unit & BAST (Selesai Cepat)',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24487A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_mode_rounded,
                    size: 13,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Batas Pengembalian: ${item.endDate.day.toString().padLeft(2, '0')}/${item.endDate.month.toString().padLeft(2, '0')}/${item.endDate.year} pukul 23:59 WIB (Otomatis Selesai)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
