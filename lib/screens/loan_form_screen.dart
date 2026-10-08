import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/models/loan_model.dart';
import 'package:simodis_jatim/services/api_config.dart';
import 'package:simodis_jatim/services/api_service.dart';
import 'package:simodis_jatim/services/wilayah_service.dart';
import 'package:simodis_jatim/widgets/app_image.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class LoanFormScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Vehicle? preselectedVehicle;
  final Function(LoanRequest) onSubmit;
  final List<LoanRequest>? existingLoans;

  const LoanFormScreen({
    super.key,
    required this.vehicles,
    this.preselectedVehicle,
    required this.onSubmit,
    this.existingLoans,
  });

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Data Pegawai (Otomatis dari login)
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedDepartment;

  // 2. Berkas Nota Dinas (Gambar / PDF)
  Uint8List? _notaDinasBytes;
  String? _notaDinasName;
  bool _isPdf = false;
  int _notaDinasSize = 0;

  // 3. Jadwal Peminjaman & Jam Operasional
  DateTimeRange? _selectedDateRange;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);
  List<LoanRequest> _allLoans = [];

  // 4. Tujuan (Dropdown Cascading Kota/Kecamatan/Kelurahan & Keperluan via API Wilayah Jatim)
  WilayahItem? _selectedCityItem;
  WilayahItem? _selectedDistrictItem;
  WilayahItem? _selectedSubDistrictItem;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedSubDistrict;
  String? _selectedPurpose;

  List<WilayahItem> _regencyList = [];
  List<WilayahItem> _districtList = [];
  List<WilayahItem> _villageList = [];

  bool _isLoadingRegencies = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingVillages = false;

  // 5. Unit Armada
  Vehicle? _selectedVehicle;

  // 6. Layanan Pengemudi (Driver / Tanpa Driver)
  bool _withDriver = false;
  String _selectedDriver = 'Pak Sugeng Riyadi';

  static const List<Map<String, String>> _availableDrivers = [
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

  // Daftar Keperluan Kedinasan Dinas Sosial
  static const List<String> _purposeOptions = [
    'Monitoring & Evaluasi Program Bantuan Sosial (Monev Bansos)',
    'Penyaluran Bantuan Sosial & Logistik Kedaruratan Bencana',
    'Kunjungan Kerja & Pengawasan Fasilitas UPT / Panti Sosial',
    'Penanganan Cepat Kedaruratan Bencana Alam & Tagana',
    'Rapat Koordinasi Antar-Instansi & Kerjasama Wilayah Bakorwil',
    'Pendampingan Program PKH & Graduasi Keluarga Sejahtera',
    'Layanan Antar-Jemput & Penjangkauan Disabilitas / Lansia',
    'Pengawasan Aset, Sarana Prasarana & Logistik Kedinasan',
    'Tugas Operasional Administrasi & Pelayanan Kedinasan Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.preselectedVehicle;

    // Otomatis isi NIP dan Nama pemohon dari data profil saat login
    final currentUser = ApiConfig.currentUserProfile;
    _nipController.text = currentUser?.nip.isNotEmpty == true
        ? currentUser!.nip
        : '199503152020121002';
    _nameController.text = currentUser?.name.isNotEmpty == true
        ? currentUser!.name
        : 'Alamsyah';
    _selectedDepartment = currentUser?.department.isNotEmpty == true
        ? currentUser!.department
        : 'Sekretariat';

    // Inisialisasi daftar pinjaman aktif untuk pengecekan bentrok jadwal
    if (widget.existingLoans != null) {
      _allLoans = List.from(widget.existingLoans!);
      _ensureSelectedDriverAvailable();
    }
    _loadExistingLoansForCollisionCheck();

    // Memuat daftar Kabupaten / Kota di Jawa Timur via API
    _loadRegencies();
  }

  Future<void> _loadExistingLoansForCollisionCheck() async {
    final list = await ApiService.fetchLoans();
    if (list != null && mounted) {
      setState(() {
        _allLoans = list;
        _ensureSelectedDriverAvailable();
      });
    }
  }

  @override
  void dispose() {
    _nipController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Cek kelengkapan data step 1-4 untuk membuka pemilihan armada kendaraan
  bool get _isStepDetailsComplete {
    return _nameController.text.trim().isNotEmpty &&
        _nipController.text.trim().isNotEmpty &&
        _selectedDepartment != null &&
        _selectedDateRange != null &&
        _selectedCity != null &&
        _selectedDistrict != null &&
        _selectedSubDistrict != null &&
        _selectedPurpose != null;
  }

  Future<void> _loadRegencies() async {
    setState(() => _isLoadingRegencies = true);
    final list = await WilayahService.getRegencies();
    if (mounted) {
      setState(() {
        _regencyList = list;
        _isLoadingRegencies = false;
      });
    }
  }

  Future<void> _loadDistricts(String regencyCode) async {
    setState(() {
      _isLoadingDistricts = true;
      _districtList = [];
      _selectedDistrictItem = null;
      _selectedDistrict = null;
      _villageList = [];
      _selectedSubDistrictItem = null;
      _selectedSubDistrict = null;
    });

    final list = await WilayahService.getDistricts(regencyCode);
    if (mounted) {
      setState(() {
        _districtList = list;
        _isLoadingDistricts = false;
      });
    }
  }

  Future<void> _loadVillages(String districtCode) async {
    setState(() {
      _isLoadingVillages = true;
      _villageList = [];
      _selectedSubDistrictItem = null;
      _selectedSubDistrict = null;
    });

    final list = await WilayahService.getVillages(districtCode);
    if (mounted) {
      setState(() {
        _villageList = list;
        _isLoadingVillages = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final firstAllowedDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final lastAllowedDate = firstAllowedDate.add(const Duration(days: 7));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(start: firstAllowedDate, end: firstAllowedDate),
      helpText: 'PILIH RENTANG TANGGAL',
      saveText: 'PILIH',
      builder: (context, child) {
        final isDark = ThemeService.isDarkMode;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF2563EB),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF24487A),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1E293B),
                  ),
            appBarTheme: AppBarTheme(
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF24487A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        if (_selectedVehicle != null && _getConflictingLoan(_selectedVehicle!.id) != null) {
          _selectedVehicle = null;
        }
        _ensureSelectedDriverAvailable();
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'PILIH JAM BERANGKAT',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      builder: (context, child) {
        final isDark = ThemeService.isDarkMode;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF2563EB),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF24487A),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1E293B),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
        if (_selectedVehicle != null && _getConflictingLoan(_selectedVehicle!.id) != null) {
          _selectedVehicle = null;
        }
        _ensureSelectedDriverAvailable();
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: 'PILIH JAM KEMBALI',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      builder: (context, child) {
        final isDark = ThemeService.isDarkMode;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF2563EB),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF24487A),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1E293B),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
        if (_selectedVehicle != null && _getConflictingLoan(_selectedVehicle!.id) != null) {
          _selectedVehicle = null;
        }
        _ensureSelectedDriverAvailable();
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  LoanRequest? _getConflictingLoan(String vehicleId) {
    if (_selectedDateRange == null) return null;
    final formStart = DateTime(
      _selectedDateRange!.start.year,
      _selectedDateRange!.start.month,
      _selectedDateRange!.start.day,
      _startTime.hour,
      _startTime.minute,
    );
    final formEnd = DateTime(
      _selectedDateRange!.end.year,
      _selectedDateRange!.end.month,
      _selectedDateRange!.end.day,
      _endTime.hour,
      _endTime.minute,
    );

    for (final loan in _allLoans) {
      if (loan.vehicleId != vehicleId) continue;
      // Jangan blokir jika permohonan berstatus ditolak, dibatalkan, telah selesai, atau sudah lewat batas 23:59
      if (loan.status == LoanStatus.ditolak ||
          loan.status == LoanStatus.rejected ||
          loan.status == LoanStatus.dibatalkan ||
          loan.status == LoanStatus.selesai ||
          loan.isPastDeadline) {
        continue;
      }

      // Rentang waktu tumpang-tindih (overlap collision)
      if (formStart.isBefore(loan.endDateTime) && formEnd.isAfter(loan.startDateTime)) {
        return loan;
      }
    }
    return null;
  }

  /// Cek apakah supir/driver tertentu sedang bertugas dinas pada jadwal yang dipilih
  LoanRequest? _getConflictingDriverLoan(String driverName) {
    if (driverName.startsWith('Ditugaskan oleh')) {
      return null; // Opsi alokasi otomatis Kasubag selalu tersedia
    }

    final target = driverName.trim().toLowerCase();
    DateTime formStart;
    DateTime formEnd;

    if (_selectedDateRange != null) {
      formStart = DateTime(
        _selectedDateRange!.start.year,
        _selectedDateRange!.start.month,
        _selectedDateRange!.start.day,
        _startTime.hour,
        _startTime.minute,
      );
      formEnd = DateTime(
        _selectedDateRange!.end.year,
        _selectedDateRange!.end.month,
        _selectedDateRange!.end.day,
        _endTime.hour,
        _endTime.minute,
      );
    } else {
      final now = DateTime.now();
      formStart = now;
      formEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    for (final loan in _allLoans) {
      if (!loan.withDriver) continue;

      String loanDriver = (loan.driverName ?? '').trim().toLowerCase();
      if (loanDriver.isEmpty && loan.purposeDescription.contains('Dengan Driver:')) {
        loanDriver = loan.purposeDescription
            .split('Dengan Driver:')
            .last
            .split('\n')
            .first
            .trim()
            .toLowerCase();
      }

      if (loanDriver.isEmpty) continue;

      // Cek apakah supir yang sama
      if (!loanDriver.contains(target) && !target.contains(loanDriver)) {
        continue;
      }

      // Jangan blokir jika permohonan berstatus ditolak, dibatalkan, telah selesai, atau sudah lewat batas 23:59
      if (loan.status == LoanStatus.ditolak ||
          loan.status == LoanStatus.rejected ||
          loan.status == LoanStatus.dibatalkan ||
          loan.status == LoanStatus.selesai ||
          loan.isPastDeadline) {
        continue;
      }

      // 1. Sedang dinas aktif saat ini (status digunakan)
      final isCurrentlyInUse = loan.status == LoanStatus.digunakan &&
          !loan.isPastDeadline &&
          (_selectedDateRange == null ||
              (_selectedDateRange!.start.year == loan.startDate.year &&
                  _selectedDateRange!.start.month == loan.startDate.month &&
                  _selectedDateRange!.start.day == loan.startDate.day));

      // 2. Rentang waktu tumpang-tindih (overlap collision)
      final isTimeOverlapping =
          formStart.isBefore(loan.endDateTime) && formEnd.isAfter(loan.startDateTime);

      if (isCurrentlyInUse || isTimeOverlapping) {
        return loan;
      }
    }
    return null;
  }

  /// Memastikan supir yang terpilih tidak sedang dalam status bentrok / dinas
  void _ensureSelectedDriverAvailable() {
    if (_getConflictingDriverLoan(_selectedDriver) != null) {
      final available = _availableDrivers.firstWhere(
        (d) => _getConflictingDriverLoan(d['name']!) == null,
        orElse: () => _availableDrivers.last,
      );
      _selectedDriver = available['name']!;
    }
  }

  // Pemilihan Dokumen Nota Dinas (PDF atau Gambar)
  Future<void> _pickNotaDinasFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (file != null) {
        final bytes = await file.xFile.readAsBytes();
        if (bytes.length > 8 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file melebihi 8 MB. Silakan gunakan berkas PDF/Foto dengan ukuran maksimal 8 MB.'),
                backgroundColor: Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
        final isPdf = file.name.toLowerCase().endsWith('.pdf');
        setState(() {
          _notaDinasName = file.name;
          _notaDinasBytes = bytes;
          _notaDinasSize = bytes.length;
          _isPdf = isPdf;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _pickNotaDinasCamera() async {
    try {
      final pickedPhoto = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (pickedPhoto == null) return;
      final bytes = await pickedPhoto.readAsBytes();

      setState(() {
        _notaDinasName = pickedPhoto.name;
        _notaDinasBytes = bytes;
        _notaDinasSize = bytes.length;
        _isPdf = false;
      });
    } catch (e) {
      debugPrint('Error picking camera: $e');
    }
  }

  Future<void> _showNotaDinasPickerSheet() async {
    final isDark = ThemeService.isDarkMode;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)),
              title: const Text('Upload Dokumen PDF atau Gambar (Berkas)'),
              subtitle: const Text('Pilih berkas dari memori perangkat (PDF, PNG, JPG)'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickNotaDinasFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB)),
              title: const Text('Foto Fisik Dokumen dengan Kamera'),
              subtitle: const Text('Ambil foto langsung surat usulan fisik'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickNotaDinasCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tentukan jadwal peminjaman terlebih dahulu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedCity == null || _selectedDistrict == null || _selectedSubDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan lengkapi pilihan kota, kecamatan, dan kelurahan tujuan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih keperluan kedinasan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih salah satu armada yang tersedia.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi tabrakan jam peminjaman di hari yang sama
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (_selectedDateRange!.start.year == _selectedDateRange!.end.year &&
        _selectedDateRange!.start.month == _selectedDateRange!.end.month &&
        _selectedDateRange!.start.day == _selectedDateRange!.end.day &&
        endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam kembali harus lebih lambat dari jam berangkat untuk peminjaman di hari yang sama.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi bentrok dengan jadwal peminjaman armada lain
    final conflict = _getConflictingLoan(_selectedVehicle!.id);
    if (conflict != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Armada ${_selectedVehicle!.name} bertabrakan dengan jadwal peminjaman lain (${conflict.scheduleDisplay}). Silakan pilih armada lain atau ubah jam peminjaman.'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validasi ketersediaan driver jika memilih opsi Dengan Driver
    if (_withDriver) {
      final driverConflict = _getConflictingDriverLoan(_selectedDriver);
      if (driverConflict != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedDriver sedang bertugas dinas (${driverConflict.scheduleDisplay}). Silakan pilih driver lain yang berstatus Siaga.'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (_notaDinasBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan upload berkas Nota Dinas terlebih dahulu (PDF atau Gambar).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Format Data URI untuk berkas Nota Dinas
    final documentUri = _isPdf
        ? 'data:application/pdf;base64,${base64Encode(_notaDinasBytes!)}'
        : imageDataUri(_notaDinasName ?? 'nota_dinas.jpg', _notaDinasBytes!);

    // Format destinasi dan alamat
    final formattedDestination = '$_selectedCity, Kec. $_selectedDistrict, Kel. $_selectedSubDistrict';
    final formattedAddress = formattedDestination;

    // Format deskripsi keperluan lengkap beserta informasi driver dan jam peminjaman
    final driverText = _withDriver
        ? 'Dengan Driver: $_selectedDriver'
        : 'Tanpa Driver (Lepas Kunci)';
    final timeText = '${_formatTime(_startTime)} s/d ${_formatTime(_endTime)} WIB';
    final completePurpose = '$_selectedPurpose\n• Jam Operasional: $timeText\n• Layanan Pengemudi: $driverText';

    final newLoan = LoanRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      borrowerName: _nameController.text.trim(),
      nip: _nipController.text.trim(),
      department: _selectedDepartment!,
      vehicleId: _selectedVehicle!.id,
      vehicleName: _selectedVehicle!.name,
      destination: formattedDestination,
      destinationAddress: formattedAddress,
      purposeDescription: completePurpose,
      startDate: _selectedDateRange!.start,
      endDate: _selectedDateRange!.end,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      officialNoteNumber: 'Diproses saat SPK',
      simPhotoPath: documentUri, // Menyimpan lampiran berkas Nota Dinas
      withDriver: _withDriver,
      driverName: _withDriver ? _selectedDriver : null,
      status: LoanStatus.menunggu,
      submittedAt: DateTime.now(),
    );

    Navigator.pop(context);
    widget.onSubmit(newLoan);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76.0),
        child: Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          padding: const EdgeInsets.fromLTRB(10, 10, 20, 8),
          alignment: Alignment.centerLeft,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Formulir Permohonan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pengajuan pinjam kendaraan dinas operasional',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF24487A),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() {});
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. DATA IDENTITAS PEMOHON (OTOMATIS DARI LOGIN)
                _buildSectionTitle(
                  '1. Identitas Pemohon',
                  Icons.person_pin_rounded,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    children: [
                      // NIP Pegawai (Otomatis dari Akun)
                      _buildReadOnlyField(
                        controller: _nipController,
                        label: 'NIP Pegawai (Nomor Induk Pegawai)',
                        hint: 'NIP pemohon terisi otomatis',
                        icon: Icons.badge_outlined,
                        badgeText: 'Terverifikasi Akun',
                      ),
                      const SizedBox(height: 14),

                      // Nama Lengkap Pegawai (Otomatis dari Akun)
                      _buildReadOnlyField(
                        controller: _nameController,
                        label: 'Nama Lengkap Pegawai',
                        hint: 'Nama pemohon terisi otomatis',
                        icon: Icons.person_outline_rounded,
                        badgeText: 'Pegawai Login',
                      ),
                      const SizedBox(height: 14),

                      // Bidang / Seksi / Sub Bagian
                      _buildDepartmentDropdown(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. BERKAS NOTA DINAS (GANTI DARI FOTO SIM MENJADI UPLOAD NOTA DINAS GAMBAR / PDF)
                _buildSectionTitle(
                  '2. Berkas Nota Dinas',
                  Icons.description_rounded,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardBoxDecoration(),
                  child: _notaDinasBytes == null
                      ? InkWell(
                          onTap: _showNotaDinasPickerSheet,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
                                    : const Color(0xFFBFDBFE),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                                        : const Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.upload_file_rounded,
                                    size: 32,
                                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Upload Nota Dinas Resmi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF24487A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mendukung format Dokumen PDF atau Berkas Gambar (PNG, JPG)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
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
                              if (!_isPdf) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _notaDinasBytes!,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _isPdf
                                          ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                                          : const Color(0xFF2563EB).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _isPdf
                                          ? Icons.picture_as_pdf_rounded
                                          : Icons.image_rounded,
                                      size: 24,
                                      color: _isPdf ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _notaDinasName ?? 'Nota_Dinas.pdf',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${_isPdf ? "Dokumen PDF" : "Berkas Gambar"} • ${_formatFileSize(_notaDinasSize)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _showNotaDinasPickerSheet,
                                    icon: const Icon(Icons.edit_outlined, size: 15),
                                    label: const Text('Ganti', style: TextStyle(fontSize: 12)),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus berkas',
                                    onPressed: () => setState(() {
                                      _notaDinasBytes = null;
                                      _notaDinasName = null;
                                      _notaDinasSize = 0;
                                    }),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFDC2626),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // 3. JADWAL PEMINJAMAN (H+1 s/d H+7)
                _buildSectionTitle(
                  '3. Jadwal Peminjaman',
                  Icons.calendar_month_rounded,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Rentang Tanggal (Min. H+1 s/d H+7)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateBox(
                              label: 'MULAI',
                              date: _selectedDateRange?.start,
                              onTap: _pickDateRange,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          Expanded(
                            child: _buildDateBox(
                              label: 'SELESAI',
                              date: _selectedDateRange?.end,
                              onTap: _pickDateRange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih Jam Operasional Peminjaman (WIB)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeBox(
                              label: 'JAM BERANGKAT',
                              time: _startTime,
                              onTap: _pickStartTime,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          Expanded(
                            child: _buildTimeBox(
                              label: 'JAM KEMBALI',
                              time: _endTime,
                              onTap: _pickEndTime,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedDateRange != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2563EB) : const Color(0xFFDBEAFE),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_filled_rounded,
                                size: 15,
                                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Jadwal Tugas: ${_selectedDateRange!.duration.inDays + 1} Hari • ${_formatTime(_startTime)} - ${_formatTime(_endTime)} WIB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF24487A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 4. TUJUAN (KATA 'KEDINASAN' DIHAPUS, DIGANTI DROPDOWN KOTA, KECAMATAN, KELURAHAN & DROPDOWN KEPERLUAN)
                _buildSectionTitle(
                  '4. Tujuan',
                  Icons.location_on_rounded,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown 1: Kota / Kabupaten (API Wilayah Jawa Timur)
                      _buildDropdownField<WilayahItem>(
                        label: 'Kota / Kabupaten Tujuan',
                        hint: _isLoadingRegencies
                            ? 'Memuat data wilayah Jawa Timur...'
                            : 'Pilih Kota / Kabupaten di Jawa Timur',
                        icon: Icons.location_city_rounded,
                        value: _selectedCityItem,
                        isLoading: _isLoadingRegencies,
                        items: _regencyList.map((item) {
                          return DropdownMenuItem<WilayahItem>(
                            value: item,
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCityItem = val;
                            _selectedCity = val?.name;
                          });
                          if (val != null) {
                            _loadDistricts(val.code);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Dropdown 2: Kecamatan (API Wilayah Jawa Timur)
                      _buildDropdownField<WilayahItem>(
                        label: 'Kecamatan',
                        hint: _selectedCityItem == null
                            ? 'Pilih Kota / Kabupaten terlebih dahulu'
                            : _isLoadingDistricts
                                ? 'Memuat daftar kecamatan...'
                                : 'Pilih Kecamatan tujuan',
                        icon: Icons.explore_rounded,
                        value: _selectedDistrictItem,
                        isLoading: _isLoadingDistricts,
                        items: _districtList.map((item) {
                          return DropdownMenuItem<WilayahItem>(
                            value: item,
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (_selectedCityItem == null || _isLoadingDistricts)
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedDistrictItem = val;
                                  _selectedDistrict = val?.name;
                                });
                                if (val != null) {
                                  _loadVillages(val.code);
                                }
                              },
                      ),
                      const SizedBox(height: 14),

                      // Dropdown 3: Kelurahan / Desa (API Wilayah Jawa Timur)
                      _buildDropdownField<WilayahItem>(
                        label: 'Kelurahan / Desa',
                        hint: _selectedDistrictItem == null
                            ? 'Pilih Kecamatan terlebih dahulu'
                            : _isLoadingVillages
                                ? 'Memuat daftar kelurahan/desa...'
                                : 'Pilih Kelurahan / Desa tujuan',
                        icon: Icons.holiday_village_rounded,
                        value: _selectedSubDistrictItem,
                        isLoading: _isLoadingVillages,
                        items: _villageList.map((item) {
                          return DropdownMenuItem<WilayahItem>(
                            value: item,
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (_selectedDistrictItem == null || _isLoadingVillages)
                            ? null
                            : (val) {
                                setState(() {
                                  _selectedSubDistrictItem = val;
                                  _selectedSubDistrict = val?.name;
                                });
                              },
                      ),

                      const SizedBox(height: 14),

                      // Dropdown Keperluan (Menggantikan input manual)
                      _buildDropdownField<String>(
                        label: 'Keperluan',
                        hint: 'Pilih keperluan penugasan kedinasan',
                        icon: Icons.assignment_outlined,
                        value: _selectedPurpose,
                        items: _purposeOptions.map((purpose) {
                          return DropdownMenuItem<String>(
                            value: purpose,
                            child: Text(
                              purpose,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPurpose = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. UNIT ARMADA YANG DIPINJAM
                _buildSectionTitle(
                  '5. Unit Armada yang Dipinjam',
                  Icons.directions_car_rounded,
                ),
                const SizedBox(height: 10),
                if (!_isStepDetailsComplete)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_clock_rounded,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Lengkapi identitas, jadwal tanggal, dan tujuan di atas terlebih dahulu untuk memilih armada.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: () {
                      // Urutkan armada: yang Tersedia (Available & Tidak Bentrok) di atas, yang Terpakai/Unavailable/Bentrok di bawah
                      final sortedVehicles = List<Vehicle>.from(widget.vehicles)
                        ..sort((a, b) {
                          final aConflict = _getConflictingLoan(a.id);
                          final bConflict = _getConflictingLoan(b.id);
                          final aAvailable = a.status == VehicleStatus.tersedia && aConflict == null;
                          final bAvailable = b.status == VehicleStatus.tersedia && bConflict == null;
                          if (aAvailable && !bAvailable) return -1;
                          if (!aAvailable && bAvailable) return 1;
                          return 0;
                        });

                      return sortedVehicles.map((v) {
                        final isSelected = _selectedVehicle?.id == v.id;
                        final conflict = _getConflictingLoan(v.id);
                        final isVehicleAvailable = v.status == VehicleStatus.tersedia && conflict == null;

                        // Background dan border: jika tidak tersedia atau jadwal bentrok berikan background merah lembut
                        Color cardBg;
                        Color cardBorder;
                        if (!isVehicleAvailable) {
                          cardBg = isDark ? const Color(0xFF3B1518) : const Color(0xFFFEF2F2);
                          cardBorder = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
                        } else if (isSelected) {
                          cardBg = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFEFF6FF);
                          cardBorder = isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A);
                        } else {
                          cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
                          cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
                        }

                        return GestureDetector(
                          onTap: isVehicleAvailable
                              ? () {
                                  setState(() {
                                    _selectedVehicle = v;
                                  });
                                }
                              : () {
                                  if (conflict != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Unit ${v.name} sudah dipinjam pada jadwal ${conflict.scheduleDisplay}. Pilih jam atau armada lain.',
                                        ),
                                        backgroundColor: const Color(0xFFDC2626),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: cardBorder,
                                width: isSelected ? 1.8 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 68,
                                    height: 56,
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                    child: AppImage(
                                      source: v.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: Icon(
                                        v.type == VehicleType.mobil
                                            ? Icons.directions_car
                                            : Icons.two_wheeler,
                                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        v.plateNumber,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${v.fuelDisplay} • ${v.capacity} Penumpang',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (conflict != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Jadwal Bentrok',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          conflict.timeRangeDisplay,
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            color: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (v.status != VehicleStatus.tersedia)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Unavailable',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                                              : const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Available',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        color: isSelected
                                            ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A))
                                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                        size: 22,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList();
                    }(),
                  ),

                const SizedBox(height: 20),

                // 6. FITUR DRIVER / TANPA DRIVER (URUTAN NOMER 6)
                _buildSectionTitle(
                  '6. Layanan Pengemudi (Driver)',
                  Icons.airline_seat_recline_normal_rounded,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardBoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih opsi pengemudi untuk perjalanan dinas ini:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Opsi 1: Tanpa Driver (Lepas Kunci)
                          Expanded(
                            child: _buildDriverOptionCard(
                              title: 'Tanpa Driver',
                              subtitle: 'Lepas Kunci (Bawa Sendiri)',
                              icon: Icons.key_rounded,
                              isSelected: !_withDriver,
                              onTap: () => setState(() => _withDriver = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Opsi 2: Dengan Driver
                          Expanded(
                            child: _buildDriverOptionCard(
                              title: 'Dengan Driver',
                              subtitle: 'Supir Dinas Operasional',
                              icon: Icons.person_pin_circle_rounded,
                              isSelected: _withDriver,
                              onTap: () => setState(() => _withDriver = true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _withDriver ? Icons.info_outline_rounded : Icons.verified_user_outlined,
                              size: 15,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _withDriver
                                    ? 'Sub Bagian Umum akan menugaskan driver dinas resmi mendampingi perjalanan Anda.'
                                    : 'Pegawai pemohon mengemudikan kendaraan secara mandiri dan bertanggung jawab penuh.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Pilihan Pengemudi (Hanya tampil jika opsi Dengan Driver dipilih)
                      if (_withDriver) ...[
                        const SizedBox(height: 14),
                        _buildDriverSelector(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isStepDetailsComplete &&
                      _selectedVehicle != null &&
                      _getConflictingLoan(_selectedVehicle!.id) == null &&
                      (!_withDriver || _getConflictingDriverLoan(_selectedDriver) == null) &&
                      _notaDinasBytes != null
                  ? _handleSubmit
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF2563EB) : const Color(0xFF24487A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                disabledForegroundColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kirim Pengajuan Permohonan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverSelector() {
    final isDark = ThemeService.isDarkMode;
    final busyCount = _availableDrivers
        .where((d) => _getConflictingDriverLoan(d['name']!) != null)
        .length;
    final readyCount = _availableDrivers.length - busyCount;

    final effectiveSelectedDriver = _getConflictingDriverLoan(_selectedDriver) == null
        ? _selectedDriver
        : _availableDrivers.firstWhere(
            (d) => _getConflictingDriverLoan(d['name']!) == null,
            orElse: () => _availableDrivers.last,
          )['name']!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2563EB).withValues(alpha: 0.6)
              : const Color(0xFFBFDBFE),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin_circle_rounded,
                size: 17,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 6),
              Text(
                'Pilih Driver / Supir Dinas',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (busyCount > 0
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF16A34A))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  busyCount > 0
                      ? '$readyCount Siaga • $busyCount Sedang Dinas'
                      : 'Semua Driver Siaga',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: busyCount > 0
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('driver_field_$effectiveSelectedDriver'),
            initialValue: effectiveSelectedDriver,
            isExpanded: true,
            isDense: true,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
            ),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              prefixIcon: Icon(
                Icons.airline_seat_recline_normal_rounded,
                size: 20,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
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
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
            selectedItemBuilder: (context) {
              return _availableDrivers.map((driver) {
                final conflict = _getConflictingDriverLoan(driver['name']!);
                final isBusy = conflict != null;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          driver['name']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBusy)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF7F1D1D).withValues(alpha: 0.5)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Sedang Dinas',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList();
            },
            items: _availableDrivers.map((driver) {
              final conflict = _getConflictingDriverLoan(driver['name']!);
              final isBusy = conflict != null;

              return DropdownMenuItem<String>(
                value: driver['name'],
                enabled: !isBusy,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              driver['name']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isBusy
                                    ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                decoration: isBusy ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (isBusy)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.5)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDark ? const Color(0xFFEF4444) : const Color(0xFFF87171),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 11,
                                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Sedang Dinas',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isBusy
                            ? 'Sedang dinas (${conflict.vehicleName} • ${conflict.scheduleDisplay})'
                            : driver['detail']!,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isBusy ? FontWeight.w600 : FontWeight.normal,
                          color: isBusy
                              ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null && _getConflictingDriverLoan(val) == null) {
                setState(() => _selectedDriver = val);
              }
            },
          ),
          if (busyCount > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.2) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFFEF4444).withValues(alpha: 0.3) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Driver bertanda "Sedang Dinas" sedang bertugas pada jadwal yang dipilih dan tidak dapat dipilih.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                        fontWeight: FontWeight.w500,
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

  Widget _buildDriverOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = ThemeService.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFEFF6FF))
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A))
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected
                  ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A))
                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF24487A))
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final isDark = ThemeService.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : 'Pilih...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: date != null
                          ? (isDark ? Colors.white : const Color(0xFF1E293B))
                          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final isDark = ThemeService.isDarkMode;
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} WIB';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    final isDark = ThemeService.isDarkMode;
    final deptList = <String>{
      'Sekretariat / Subbag Tata Usaha',
      'Subbag Penyusunan Program & Anggaran',
      'Subbag Keuangan & Pengelolaan Aset',
      'Bidang Perlindungan & Jaminan Sosial (Linjamsos)',
      'Bidang Rehabilitasi Sosial (Rehsos)',
      'Bidang Pemberdayaan Sosial (Dayasos)',
      'Bidang Penanganan Fakir Miskin (PFM)',
      'Unit Pelaksana Teknis (UPT) / Panti Sosial',
      'Sekretariat',
      'Rehabilitasi',
      'Pemberdayaan Sosial',
      'Pelaksana Teknis',
      'Penanganan Bencana',
      'Dinas Sosial Jawa Timur',
      'Dinas Sosial Provinsi Jawa Timur',
      if (_selectedDepartment != null && _selectedDepartment!.trim().isNotEmpty)
        _selectedDepartment!.trim(),
    }.toList();

    final safeValue = (deptList.contains(_selectedDepartment))
        ? _selectedDepartment
        : deptList.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bidang / Seksi / Sub Bagian',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
          ),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: 'Pilih bidang pemohon',
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              Icons.business_rounded,
              size: 18,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF64748B),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                width: 1.5,
              ),
            ),
          ),
          items: deptList
              .map(
                (department) => DropdownMenuItem<String>(
                  value: department,
                  child: Text(
                    department,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedDepartment = value);
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    bool isLoading = false,
  }) {
    final isDark = ThemeService.isDarkMode;
    final T? safeValue = (value != null && items.any((it) => it.value == value))
        ? value
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: safeValue,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          icon: isLoading
              ? Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 6),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                  ),
                )
              : Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                ),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF64748B),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
                width: 1.5,
              ),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String badgeText,
  }) {
    final isDark = ThemeService.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF16A34A)),
                  const SizedBox(width: 4),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF64748B)),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSectionTitle(String title, IconData icon) {
    final isDark = ThemeService.isDarkMode;
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardBoxDecoration() {
    final isDark = ThemeService.isDarkMode;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
