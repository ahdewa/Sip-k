enum LoanStatus {
  menunggu,
  pending, // Alias untuk menunggu
  disetujui,
  approved, // Alias untuk disetujui
  digunakan, // Sedang digunakan dalam penugasan dinas
  ditolak,
  rejected, // Alias untuk ditolak
  dibatalkan,
  selesai,
}

class LoanRequest {
  final String id;
  final String borrowerName;
  final String? nip;
  final String department;
  final String vehicleId;
  final String vehicleName;
  final String destination;
  final String destinationAddress;
  final String purposeDescription;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime; // Format: "HH:mm" misal "08:00"
  final String? endTime; // Format: "HH:mm" misal "16:00"
  final String officialNoteNumber;
  final String? simPhotoPath; // Berkas Nota Dinas (gambar atau PDF)
  // Layanan Pengemudi
  bool withDriver; // true: Dengan Driver, false: Tanpa Driver (Lepas Kunci)
  String? driverName; // Nama supir jika Dengan Driver
  LoanStatus status;
  final DateTime submittedAt;
  String? spkNumber;

  // Properti untuk proses pengembalian unit (BAST)
  dynamic returnOdometer; // Mendukung int maupun String
  dynamic returnFuel; // Mendukung String ("Full", "75%") maupun int
  String? returnNotes;

  LoanRequest({
    required this.id,
    required this.borrowerName,
    this.nip,
    required this.department,
    required this.vehicleId,
    required this.vehicleName,
    required this.destination,
    this.destinationAddress = '',
    this.purposeDescription = '',
    required this.startDate,
    required this.endDate,
    this.startTime = '08:00',
    this.endTime = '16:00',
    this.officialNoteNumber = '-',
    this.simPhotoPath,
    this.withDriver = false,
    this.driverName,
    this.status = LoanStatus.menunggu,
    required this.submittedAt,
    this.spkNumber,
    this.returnOdometer,
    this.returnFuel,
    this.returnNotes,
  });

  String get applicantName => borrowerName;
  String get driverOption => withDriver
      ? 'Dengan Driver (${driverName ?? "Supir Dinas"})'
      : 'Tanpa Driver (Lepas Kunci)';

  String get timeRangeDisplay {
    final s = startTime ?? '08:00';
    final e = endTime ?? '16:00';
    return '$s - $e WIB';
  }

  String get scheduleDisplay {
    final sDate = '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}';
    final eDate = '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
    final sTime = startTime ?? '08:00';
    final eTime = endTime ?? '16:00';

    if (sDate == eDate) {
      return '$sDate ($sTime - $eTime WIB)';
    }
    return '$sDate ($sTime) s/d $eDate ($eTime WIB)';
  }

  DateTime get startDateTime {
    final s = startTime ?? '08:00';
    final parts = s.split(':');
    final h = int.tryParse(parts.first) ?? 8;
    final m = parts.length > 1 ? (int.tryParse(parts[1].split(' ').first) ?? 0) : 0;
    return DateTime(startDate.year, startDate.month, startDate.day, h, m);
  }

  DateTime get endDateTime {
    final e = endTime ?? '16:00';
    final parts = e.split(':');
    final h = int.tryParse(parts.first) ?? 16;
    final m = parts.length > 1 ? (int.tryParse(parts[1].split(' ').first) ?? 0) : 0;
    return DateTime(endDate.year, endDate.month, endDate.day, h, m);
  }

  DateTime get deadlineDateTime =>
      DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

  bool get isPastDeadline {
    return DateTime.now().isAfter(deadlineDateTime);
  }

  String get formattedSubmittedAt {
    final d = submittedAt;
    final day = d.day.toString().padLeft(2, '0');
    final mon = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day/$mon/$year ($hour:$min WIB)';
  }

  String get timeAgoSubmitted {
    final now = DateTime.now();
    final diff = now.difference(submittedAt);
    if (diff.isNegative || diff.inMinutes < 2) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mnt lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      final day = submittedAt.day.toString().padLeft(2, '0');
      final mon = submittedAt.month.toString().padLeft(2, '0');
      final year = submittedAt.year;
      return '$day/$mon/$year';
    }
  }

  bool get isNewSubmission {
    final diff = DateTime.now().difference(submittedAt);
    return !diff.isNegative && diff.inHours < 24;
  }

  void updateDriver({required bool withDriver, String? driverName}) {
    this.withDriver = withDriver;
    this.driverName = withDriver ? driverName : null;
  }
}

/// Daftar supir dinas operasional pool kendaraan Dinas Sosial Jatim
const List<Map<String, String>> kAvailableDrivers = [
  {
    'name': 'Pak Sugeng Riyadi',
    'detail': 'Driver Pool Utama • SIM B1 Umum • Siaga',
  },
  {
    'name': 'Pak Bambang Hermawan',
    'detail': 'Driver Operasional UPT • SIM A/B1 • Siaga',
  },
  {
    'name': 'Pak Agus Prasetyo',
    'detail': 'Driver Reaksi Cepat Tagana • SIM B1 • Siaga',
  },
  {
    'name': 'Pak Joko Susilo',
    'detail': 'Driver Kedinasan Khusus Pimpinan • SIM A • Siaga',
  },
  {
    'name': 'Pak Eko Wahyudi',
    'detail': 'Driver Patwal & Logistik Bantuan • SIM B1 Umum • Siaga',
  },
  {
    'name': 'Ditugaskan oleh Kasubag Umum / Pool',
    'detail': 'Alokasi otomatis oleh petugas pengelola pool kendaraan',
  },
];
