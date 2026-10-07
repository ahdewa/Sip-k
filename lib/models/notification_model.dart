enum NotificationType { welcome, submitted, approved, rejected, maintenance, reminder }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time; // Format ringkas (misal: "08:30 WIB", "Kemarin", "27 Ags 2026")
  final String fullDate; // Format lengkap (misal: "01 September 2026, 08:30 WIB")
  final String detailContent; // Penjelasan detail untuk dialog pop-up
  final String referenceNumber; // Nomor referensi / SPK / Nota
  final DateTime createdAt; // Tanggal pembuatan untuk filter
  final NotificationType type;
  bool isRead;
  final String targetRole; // 'pegawai' (user pemohon) atau 'admin' / 'superadmin' atau 'all'

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.fullDate,
    required this.detailContent,
    required this.referenceNumber,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.targetRole = 'all',
  });

  /// Cek apakah notifikasi ini relevan untuk Admin / Superadmin
  bool get isForAdmin {
    if (targetRole == 'admin' || targetRole == 'superadmin') return true;
    if (targetRole == 'pegawai' || targetRole == 'user') return false;
    final t = title.toLowerCase();
    final m = message.toLowerCase();
    
    // Judul yang secara khusus hanya untuk pegawai
    if (t.contains('selamat datang') ||
        t.contains('permohonan berhasil dikirim') ||
        t.contains('pengajuan terkirim') ||
        t.contains('pengajuan disetujui (spk terbit)') ||
        t.contains('pengajuan disetujui (nota dinas terbit)')) {
      return false;
    }

    return t.contains('verifikasi') ||
        t.contains('servis') ||
        t.contains('bentrok') ||
        t.contains('akun baru') ||
        t.contains('pendaftaran akun') ||
        t.contains('rekapitulasi') ||
        t.contains('bast') ||
        type == NotificationType.maintenance ||
        m.contains('verifikasi kasubag');
  }

  /// Cek apakah notifikasi ini relevan untuk Pegawai (User Pemohon)
  bool get isForPegawai {
    if (targetRole == 'pegawai' || targetRole == 'user') return true;
    if (targetRole == 'admin' || targetRole == 'superadmin') return false;
    final t = title.toLowerCase();
    final m = message.toLowerCase();

    // Judul/topik yang hanya untuk operasional Admin/Kasubag
    if (t.contains('perlu verifikasi') ||
        t.contains('peringatan servis') ||
        t.contains('servis rutin') ||
        t.contains('penugasan bentrok') ||
        t.contains('pendaftaran akun pegawai baru') ||
        t.contains('rekapitulasi bulanan') ||
        t.contains('verifikasi pengajuan disetujui') ||
        t.contains('verifikasi pengajuan ditolak') ||
        m.contains('masuk ke antrean verifikasi kasubag')) {
      return false;
    }
    return true;
  }
}