import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simodis_jatim/models/vehicle_model.dart';
import 'package:simodis_jatim/services/theme_service.dart';
import 'package:simodis_jatim/widgets/app_image.dart';

class VehicleFormDialog {
  static InputDecoration _inputDecoration([bool isDark = false]) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF24487A), width: 1.5),
      ),
    );
  }

  static Widget _buildFormInput(
    TextEditingController ctrl,
    String label,
    String hint, {
    bool isNumber = false,
    bool isDark = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
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
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: Color(0xFF24487A),
                width: 1.5,
              ),
            ),
          ),
          validator: validator ??
              ((val) => val == null || val.trim().isEmpty ? 'Wajib diisi' : null),
        ),
      ],
    );
  }

  static Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF24487A),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    Vehicle? vehicleToEdit,
    Function(Vehicle)? onAddVehicle,
    Function(Vehicle)? onUpdateVehicle,
    VoidCallback? onSuccess,
  }) {
    final isEdit = vehicleToEdit != null;
    final nameCtrl = TextEditingController(text: vehicleToEdit?.name ?? '');
    final brandCtrl = TextEditingController(
      text: vehicleToEdit?.brand ?? 'Toyota',
    );
    final plateCtrl = TextEditingController(
      text: vehicleToEdit?.plateNumber ?? 'L ',
    );
    final colorCtrl = TextEditingController(
      text: vehicleToEdit?.color ?? 'Hitam',
    );
    final capacityCtrl = TextEditingController(
      text: vehicleToEdit?.capacity.toString() ?? '7',
    );
    final transCtrl = TextEditingController(
      text: vehicleToEdit?.transmission ?? 'Manual',
    );
    final fuelTypeCtrl = TextEditingController(
      text: vehicleToEdit?.fuelType ?? 'Pertamax / Dexlite',
    );
    final odoCtrl = TextEditingController(
      text: vehicleToEdit?.currentOdometer.toString() ?? '10000',
    );
    final chassisCtrl = TextEditingController(
      text: vehicleToEdit?.chassisNumber ?? '',
    );
    final engineCtrl = TextEditingController(
      text: vehicleToEdit?.engineNumber ?? '',
    );
    final imgUrlCtrl = TextEditingController(
      text: vehicleToEdit?.imageUrl ??
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800&q=80',
    );
    final List<String> galleryPhotos = [];
    if (vehicleToEdit != null) {
      for (final img in vehicleToEdit.allImages) {
        if (img.trim().isNotEmpty &&
            img != 'assets/images/logo_sipk.png' &&
            !galleryPhotos.contains(img.trim())) {
          galleryPhotos.add(img.trim());
        }
      }
      if (galleryPhotos.isEmpty && vehicleToEdit.imageUrl.trim().isNotEmpty) {
        galleryPhotos.add(vehicleToEdit.imageUrl.trim());
      }
    } else if (imgUrlCtrl.text.trim().isNotEmpty) {
      galleryPhotos.add(imgUrlCtrl.text.trim());
    }
    final addUrlCtrl = TextEditingController();

    final noteCtrl = TextEditingController(
      text: vehicleToEdit?.conditionNote ??
          'Kondisi prima, siap operasional dinas luar kota.',
    );

    VehicleType selectedType = vehicleToEdit?.type ?? VehicleType.mobil;
    VehicleStatus selectedStatus =
        vehicleToEdit?.status ?? VehicleStatus.tersedia;
    final formKey = GlobalKey<FormState>();

    final isDark = ThemeService.isDarkMode;

    final fuelOptions = [
      'Pertamax / Dexlite',
      'Pertalite',
      'Pertamax',
      'Dexlite',
      'Solar Subsidi',
      'Bensin / Pertalite',
    ];

    final transmissionOptions = [
      'Manual',
      'Otomatis',
      'manual',
      'Automatic',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Dialog
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24487A).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.directions_car_rounded,
                                  color: Color(0xFF24487A),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEdit
                                        ? 'Edit Armada Kendaraan'
                                        : 'Tambah Armada Baru',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'Lengkapi spesifikasi unit sesuai katalog armada pemohon',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),

                      // SECTION 1: IDENTITAS UTAMA
                      _buildSectionHeader('1. Identitas Utama Kendaraan', Icons.badge_outlined, isDark),
                      const SizedBox(height: 6),

                      _buildFormInput(
                        nameCtrl,
                        'Nama Kendaraan',
                        'Contoh: Toyota Fortuner 2.8 VRZ / Toyota Innova Reborn',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildFormInput(
                              brandCtrl,
                              'Merek Unit',
                              'Contoh: Toyota, Mitsubishi, Daihatsu',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormInput(
                              plateCtrl,
                              'Plat Nomor',
                              'Contoh: L 1234 YTH',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kategori (Roda)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<VehicleType>(
                                  initialValue: selectedType,
                                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  decoration: _inputDecoration(isDark),
                                  items: [
                                    DropdownMenuItem(
                                      value: VehicleType.mobil,
                                      child: Text(
                                        'Mobil (Roda 4)',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: VehicleType.motor,
                                      child: Text(
                                        'Motor (Roda 2)',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) => setModalState(
                                    () => selectedType = v ?? VehicleType.mobil,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status Unit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<VehicleStatus>(
                                  initialValue: selectedStatus,
                                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  decoration: _inputDecoration(isDark),
                                  items: const [
                                    DropdownMenuItem(
                                      value: VehicleStatus.tersedia,
                                      child: Text(
                                        'Tersedia',
                                        style: TextStyle(
                                          color: Color(0xFF16A34A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: VehicleStatus.digunakan,
                                      child: Text(
                                        'Dipakai',
                                        style: TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: VehicleStatus.pemeliharaan,
                                      child: Text(
                                        'Perawatan',
                                        style: TextStyle(
                                          color: Color(0xFFD97706),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) => setModalState(
                                    () => selectedStatus =
                                        v ?? VehicleStatus.tersedia,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // SECTION 2: SPESIFIKASI & KEADAAN FISIK (SESUAI KATALOG USER)
                      _buildSectionHeader('2. Spesifikasi & Keadaan Fisik', Icons.tune_rounded, isDark),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: _buildFormInput(
                              colorCtrl,
                              'Warna Body',
                              'Contoh: Hitam, Putih, Silver',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormInput(
                              capacityCtrl,
                              'Kapasitas Penumpang',
                              'Contoh: 7 (Orang)',
                              isNumber: true,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transmisi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: transmissionOptions.contains(transCtrl.text)
                                      ? transCtrl.text
                                      : 'Manual',
                                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  decoration: _inputDecoration(isDark),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Manual',
                                      child: Text('Manual'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Otomatis',
                                      child: Text('Otomatis (Automatic)'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setModalState(() => transCtrl.text = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jenis BBM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: fuelOptions.contains(fuelTypeCtrl.text)
                                      ? fuelTypeCtrl.text
                                      : fuelOptions.first,
                                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  decoration: _inputDecoration(isDark),
                                  items: fuelOptions
                                      .map((f) => DropdownMenuItem(
                                            value: f,
                                            child: Text(
                                              f,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setModalState(() => fuelTypeCtrl.text = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildFormInput(
                              chassisCtrl,
                              'Nomor Rangka (VIN)',
                              'Contoh: MH1L1234YTH-KD7',
                              isDark: isDark,
                              validator: (v) => null, // Optional, auto-generated if empty
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormInput(
                              engineCtrl,
                              'Nomor Mesin',
                              'Contoh: 2KD-L1234YTH-7',
                              isDark: isDark,
                              validator: (v) => null, // Optional, auto-generated if empty
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      _buildFormInput(
                        odoCtrl,
                        'Odometer Saat Ini (KM)',
                        'Contoh: 10000',
                        isNumber: true,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),

                      // SECTION 3: FOTO & KONDISI
                      _buildSectionHeader('3. Foto Armada & Kondisi Fisik', Icons.photo_camera_outlined, isDark),
                      const SizedBox(height: 6),

                      // UPLOAD & KELOLA BEBERAPA FOTO ARMADA
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Foto Armada Kendaraan (${galleryPhotos.length} Foto)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Foto pertama menjadi cover utama. User dapat menggeser foto di katalog.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Tombol Aksi Upload
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final picker = ImagePicker();
                                    final pickedList = await picker.pickMultiImage(
                                      maxWidth: 1024,
                                      maxHeight: 1024,
                                      imageQuality: 85,
                                    );
                                    if (pickedList.isNotEmpty) {
                                      for (final picked in pickedList) {
                                        final bytes = await picked.readAsBytes();
                                        final uri = imageDataUri(picked.name, bytes);
                                        if (!galleryPhotos.contains(uri)) {
                                          galleryPhotos.add(uri);
                                        }
                                      }
                                      if (galleryPhotos.isNotEmpty) {
                                        imgUrlCtrl.text = galleryPhotos.first;
                                      }
                                      setModalState(() {});
                                    }
                                  } catch (e) {
                                    debugPrint('Gagal memilih banyak foto: $e');
                                  }
                                },
                                icon: const Icon(Icons.photo_library_rounded, size: 16),
                                label: const Text(
                                  'Upload Beberapa Foto',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      maxWidth: 1024,
                                      maxHeight: 1024,
                                      imageQuality: 85,
                                    );
                                    if (picked == null) return;
                                    final bytes = await picked.readAsBytes();
                                    final uri = imageDataUri(picked.name, bytes);
                                    if (!galleryPhotos.contains(uri)) {
                                      galleryPhotos.add(uri);
                                    }
                                    if (galleryPhotos.isNotEmpty) {
                                      imgUrlCtrl.text = galleryPhotos.first;
                                    }
                                    setModalState(() {});
                                  } catch (e) {
                                    debugPrint('Gagal memilih foto: $e');
                                  }
                                },
                                icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                                label: const Text(
                                  'Tambah 1 Foto',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                                  side: BorderSide(
                                    color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF93C5FD),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Area List Foto (Grid / Preview)
                          if (galleryPhotos.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    selectedType == VehicleType.mobil
                                        ? Icons.directions_car_outlined
                                        : Icons.two_wheeler_outlined,
                                    size: 38,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada foto armada yang diunggah.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Gunakan tombol "Upload Beberapa Foto" untuk memilih satu atau beberapa gambar sekaligus.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(galleryPhotos.length, (idx) {
                                  final isCover = idx == 0;
                                  final photoSrc = galleryPhotos[idx];

                                  return Stack(
                                    children: [
                                      Container(
                                        width: 110,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isCover
                                                ? const Color(0xFF2563EB)
                                                : (isDark
                                                    ? const Color(0xFF334155)
                                                    : const Color(0xFFCBD5E1)),
                                            width: isCover ? 2.2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.08),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: AppImage(
                                            source: photoSrc,
                                            fit: BoxFit.cover,
                                            placeholder: Center(
                                              child: Icon(
                                                selectedType == VehicleType.mobil
                                                    ? Icons.directions_car
                                                    : Icons.two_wheeler,
                                                color: const Color(0xFF94A3B8),
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Label Cover Utama (jika foto pertama)
                                      if (isCover)
                                        Positioned(
                                          bottom: 4,
                                          left: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2563EB).withValues(alpha: 0.92),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                                SizedBox(width: 2),
                                                Text(
                                                  'Cover Utama',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        // Tombol Jadikan Cover untuk foto ke-2 dst
                                        Positioned(
                                          bottom: 4,
                                          left: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () {
                                              setModalState(() {
                                                final moved = galleryPhotos.removeAt(idx);
                                                galleryPhotos.insert(0, moved);
                                                imgUrlCtrl.text = moved;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.65),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Set Jadi Cover',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Tombol Hapus (X) di Pojok Kanan Atas
                                      Positioned(
                                        top: 3,
                                        right: 3,
                                        child: InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              galleryPhotos.removeAt(idx);
                                              if (galleryPhotos.isNotEmpty) {
                                                imgUrlCtrl.text = galleryPhotos.first;
                                              } else {
                                                imgUrlCtrl.clear();
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC2626).withValues(alpha: 0.9),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.2),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Input Tambah URL Foto Langsung
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: addUrlCtrl,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Atau tempel URL / link gambar (https://... / assets/...)',
                                    hintStyle: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final url = addUrlCtrl.text.trim();
                                  if (url.isNotEmpty) {
                                    if (!galleryPhotos.contains(url)) {
                                      galleryPhotos.add(url);
                                    }
                                    if (galleryPhotos.isNotEmpty && imgUrlCtrl.text.trim().isEmpty) {
                                      imgUrlCtrl.text = galleryPhotos.first;
                                    }
                                    addUrlCtrl.clear();
                                    setModalState(() {});
                                  }
                                },
                                icon: const Icon(Icons.add_link_rounded, size: 16),
                                label: const Text('Tambah URL', style: TextStyle(fontSize: 11.5)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      _buildFormInput(
                        noteCtrl,
                        'Catatan Kondisi Fisik Unit',
                        'Contoh: Kondisi prima, siap operasional dinas luar kota.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final capacity =
                                  int.tryParse(capacityCtrl.text.trim()) ?? 4;
                              final odo = int.tryParse(odoCtrl.text.trim()) ?? 0;

                              final primaryImage = galleryPhotos.isNotEmpty
                                  ? galleryPhotos.first
                                  : (imgUrlCtrl.text.trim().isNotEmpty
                                      ? imgUrlCtrl.text.trim()
                                      : 'assets/images/logo_sipk.png');
                              final allGallery = galleryPhotos.isNotEmpty
                                  ? List<String>.from(galleryPhotos)
                                  : [primaryImage];

                              if (isEdit) {
                                final updatedVehicle = Vehicle(
                                  id: vehicleToEdit.id,
                                  name: nameCtrl.text.trim(),
                                  brand: brandCtrl.text.trim(),
                                  plateNumber: plateCtrl.text.trim(),
                                  color: colorCtrl.text.trim(),
                                  type: selectedType,
                                  status: selectedStatus,
                                  capacity: capacity,
                                  transmission: transCtrl.text.trim(),
                                  currentOdometer: odo,
                                  fuelPercent: vehicleToEdit.fuelPercent,
                                  fuelType: fuelTypeCtrl.text.trim(),
                                  conditionNote: noteCtrl.text.trim(),
                                  imageUrl: primaryImage,
                                  galleryImages: allGallery,
                                  chassisNumber: chassisCtrl.text.trim().isNotEmpty
                                      ? chassisCtrl.text.trim()
                                      : vehicleToEdit.chassisNumber,
                                  engineNumber: engineCtrl.text.trim().isNotEmpty
                                      ? engineCtrl.text.trim()
                                      : vehicleToEdit.engineNumber,
                                );
                                onUpdateVehicle?.call(updatedVehicle);
                              } else {
                                final newVehicle = Vehicle(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  name: nameCtrl.text.trim(),
                                  brand: brandCtrl.text.trim(),
                                  plateNumber: plateCtrl.text.trim(),
                                  color: colorCtrl.text.trim(),
                                  type: selectedType,
                                  status: selectedStatus,
                                  capacity: capacity,
                                  transmission: transCtrl.text.trim(),
                                  currentOdometer: odo,
                                  fuelPercent: 100,
                                  fuelType: fuelTypeCtrl.text.trim(),
                                  conditionNote: noteCtrl.text.trim(),
                                  imageUrl: primaryImage,
                                  galleryImages: allGallery,
                                  chassisNumber: chassisCtrl.text.trim().isNotEmpty
                                      ? chassisCtrl.text.trim()
                                      : null,
                                  engineNumber: engineCtrl.text.trim().isNotEmpty
                                      ? engineCtrl.text.trim()
                                      : null,
                                );
                                onAddVehicle?.call(newVehicle);
                              }
                              Navigator.pop(ctx);
                              onSuccess?.call();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit
                                        ? 'Perubahan armada berhasil disimpan!'
                                        : 'Armada baru berhasil ditambahkan!',
                                  ),
                                  backgroundColor: const Color(0xFF16A34A),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24487A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Simpan Perubahan Armada' : 'Tambahkan Armada Baru',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
