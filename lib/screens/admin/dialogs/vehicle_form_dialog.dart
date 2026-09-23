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
              vertical: 12,
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
          ),
          validator:
              validator ??
              ((val) =>
                  val == null || val.trim().isEmpty ? 'Wajib diisi' : null),
        ),
      ],
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
      text: vehicleToEdit?.transmission ?? 'Otomatis',
    );
    final fuelTypeCtrl = TextEditingController(
      text: vehicleToEdit?.fuelType ?? 'Pertamax / Dexlite',
    );
    final odoCtrl = TextEditingController(
      text: vehicleToEdit?.currentOdometer.toString() ?? '10000',
    );
    final imgUrlCtrl = TextEditingController(
      text:
          vehicleToEdit?.imageUrl ??
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800&q=80',
    );
    final noteCtrl = TextEditingController(
      text:
          vehicleToEdit?.conditionNote ??
          'Kondisi prima, siap operasional dinas luar kota.',
    );

    VehicleType selectedType = vehicleToEdit?.type ?? VehicleType.mobil;
    VehicleStatus selectedStatus =
        vehicleToEdit?.status ?? VehicleStatus.tersedia;
    final formKey = GlobalKey<FormState>();

    final isDark = ThemeService.isDarkMode;
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                    _buildFormInput(
                      nameCtrl,
                      'Nama Kendaraan',
                      'Toyota Innova Reborn',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormInput(
                            brandCtrl,
                            'Merek',
                            'Toyota',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormInput(
                            plateCtrl,
                            'Plat Nomor',
                            'L 1023 SP',
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
                                'Jenis',
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
                                      'Mobil',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: VehicleType.motor,
                                    child: Text(
                                      'Motor',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
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
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormInput(
                            capacityCtrl,
                            'Kapasitas',
                            '7',
                            isNumber: true,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormInput(
                            transCtrl,
                            'Transmisi',
                            'Matic / Manual',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    // UPLOAD / GANTI FOTO ARMADA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Foto Armada Kendaraan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 80,
                                  height: 64,
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                  child: AppImage(
                                    source: imgUrlCtrl.text.trim().isNotEmpty
                                        ? imgUrlCtrl.text.trim()
                                        : 'assets/images/logo_sipk.png',
                                    fit: BoxFit.cover,
                                    placeholder: Center(
                                      child: Icon(
                                        selectedType == VehicleType.mobil
                                            ? Icons.directions_car
                                            : Icons.two_wheeler,
                                        color: const Color(0xFF94A3B8),
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        try {
                                          final picker = ImagePicker();
                                          final picked = await picker.pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 800,
                                            maxHeight: 800,
                                            imageQuality: 80,
                                          );
                                          if (picked == null) return;
                                          final bytes = await picked.readAsBytes();
                                          final uri = imageDataUri(picked.name, bytes);
                                          setModalState(() {
                                            imgUrlCtrl.text = uri;
                                          });
                                        } catch (e) {
                                          debugPrint('Gagal memilih foto: $e');
                                        }
                                      },
                                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                                      label: const Text(
                                        'Pilih / Ganti Foto',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Klik untuk memilih gambar dari galeri / file komputer Anda.',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: imgUrlCtrl,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Atau Masukkan URL / Path Gambar Langsung',
                            labelStyle: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            hintText: 'https://... atau assets/...',
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
                          onChanged: (_) => setModalState(() {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildFormInput(
                      noteCtrl,
                      'Catatan Kondisi Unit',
                      'Kondisi siap dinas luar kota',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final capacity =
                                int.tryParse(capacityCtrl.text.trim()) ?? 4;
                            final odo = int.tryParse(odoCtrl.text.trim()) ?? 0;

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
                                imageUrl: imgUrlCtrl.text.trim(),
                                galleryImages:
                                    vehicleToEdit.galleryImages.isNotEmpty
                                        ? vehicleToEdit.galleryImages
                                        : [imgUrlCtrl.text.trim()],
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
                                imageUrl: imgUrlCtrl.text.trim(),
                                galleryImages: [imgUrlCtrl.text.trim()],
                              );
                              onAddVehicle?.call(newVehicle);
                            }
                            Navigator.pop(ctx);
                            onSuccess?.call();
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
                          isEdit ? 'Simpan Perubahan' : 'Tambahkan Armada',
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
    );
  }
}
