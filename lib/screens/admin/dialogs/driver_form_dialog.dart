import 'package:flutter/material.dart';
import 'package:simodis_jatim/models/driver_model.dart';
import 'package:simodis_jatim/services/api_service.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class DriverFormDialog {
  static Widget _buildFormInput(
    TextEditingController ctrl,
    String label,
    String hint, {
    bool isNumber = false,
    bool isPhone = false,
    bool isDark = false,
    String? Function(String?)? validator,
    int maxLines = 1,
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
          maxLines: maxLines,
          keyboardType: isNumber
              ? TextInputType.number
              : (isPhone ? TextInputType.phone : TextInputType.text),
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
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

  static void show(
    BuildContext context, {
    Driver? driverToEdit,
    VoidCallback? onSuccess,
  }) {
    final isDark = ThemeService.isDarkMode;
    final isEdit = driverToEdit != null;

    final nameCtrl = TextEditingController(text: driverToEdit?.name ?? '');
    final nipCtrl = TextEditingController(text: driverToEdit?.nip ?? '');
    final phoneCtrl = TextEditingController(text: driverToEdit?.phone ?? '');
    final simNumberCtrl = TextEditingController(text: driverToEdit?.simNumber ?? '');
    final notesCtrl = TextEditingController(text: driverToEdit?.notes ?? '');

    String selectedSimType = driverToEdit?.simType ?? 'SIM B1 Umum';
    DriverStatus selectedStatus = driverToEdit?.status ?? DriverStatus.siaga;

    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    final simTypes = [
      'SIM A',
      'SIM B1',
      'SIM B1 Umum',
      'SIM B2',
      'SIM B2 Umum',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24487A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    color: Color(0xFF24487A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Data Pengemudi / Driver' : 'Tambah Driver Baru',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFormInput(
                        nameCtrl,
                        'Nama Lengkap Driver',
                        'Contoh: Sugeng Riyadi',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormInput(
                              nipCtrl,
                              'NIP / No. Pegawai (Opsional)',
                              'Contoh: 19800512...',
                              isDark: isDark,
                              validator: (val) => null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormInput(
                              phoneCtrl,
                              'No. WhatsApp / HP',
                              'Contoh: 081234567890',
                              isPhone: true,
                              isDark: isDark,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'No. HP wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Golongan SIM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: simTypes.contains(selectedSimType)
                                      ? selectedSimType
                                      : simTypes.first,
                                  isExpanded: true,
                                  dropdownColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFF8FAFC),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 11,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  ),
                                  items: simTypes
                                      .map((st) => DropdownMenuItem(
                                            value: st,
                                            child: Text(
                                              st,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() {
                                        selectedSimType = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFormInput(
                              simNumberCtrl,
                              'Nomor SIM (Opsional)',
                              'No. registrasi SIM',
                              isDark: isDark,
                              validator: (val) => null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Kesiapan Driver',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<DriverStatus>(
                            initialValue: selectedStatus,
                            isExpanded: true,
                            dropdownColor: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            items: DriverStatus.values
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: s.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            s.label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedStatus = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFormInput(
                        notesCtrl,
                        'Penugasan / Catatan Driver',
                        'Contoh: Driver Pool Utama, Reaksi Cepat Tagana, dll.',
                        isDark: isDark,
                        maxLines: 2,
                        validator: (val) => null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setDialogState(() => isLoading = true);

                        final newDriver = Driver(
                          id: driverToEdit?.id ?? '',
                          name: nameCtrl.text.trim(),
                          nip: nipCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          simType: selectedSimType,
                          simNumber: simNumberCtrl.text.trim(),
                          status: selectedStatus,
                          notes: notesCtrl.text.trim(),
                        );

                        final success = isEdit
                            ? await ApiService.updateDriver(newDriver)
                            : await ApiService.createDriver(newDriver);

                        setDialogState(() => isLoading = false);

                        if (dialogCtx.mounted) {
                          Navigator.pop(dialogCtx);
                        }

                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit
                                      ? 'Data driver berhasil diperbarui!'
                                      : 'Driver baru berhasil ditambahkan!',
                                ),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                            onSuccess?.call();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit
                                      ? 'Gagal memperbarui data driver. Periksa koneksi backend.'
                                      : 'Gagal menambahkan driver. Periksa koneksi backend.',
                                ),
                                backgroundColor: const Color(0xFFDC2626),
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24487A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Driver',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
