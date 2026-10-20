import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simodis_jatim/models/driver_model.dart';
import 'package:simodis_jatim/screens/admin/dialogs/driver_form_dialog.dart';
import 'package:simodis_jatim/services/api_service.dart';
import 'package:simodis_jatim/services/theme_service.dart';

class AdminDriversTab extends StatefulWidget {
  final bool isSuperAdmin;

  const AdminDriversTab({
    super.key,
    this.isSuperAdmin = false,
  });

  @override
  State<AdminDriversTab> createState() => _AdminDriversTabState();
}

class _AdminDriversTabState extends State<AdminDriversTab> {
  List<Driver> _drivers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  DriverStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchDrivers(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _drivers = list;
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation(Driver driver) {
    final isDark = ThemeService.isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Hapus Driver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data pengemudi "${driver.name}"?\nData yang dihapus tidak dapat dipulihkan.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ApiService.deleteDriver(driver.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Driver "${driver.name}" berhasil dihapus.'),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                  _loadDrivers(forceRefresh: true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus driver.'),
                      backgroundColor: Color(0xFFDC2626),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Hapus Driver', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDarkMode;
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    final filtered = _drivers.where((d) {
      final q = _searchQuery.trim().toLowerCase();
      final matchQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.nip.toLowerCase().contains(q) ||
          d.phone.toLowerCase().contains(q) ||
          d.simType.toLowerCase().contains(q) ||
          d.notes.toLowerCase().contains(q);

      final matchStatus = _selectedStatusFilter == null || d.status == _selectedStatusFilter;

      return matchQuery && matchStatus;
    }).toList();

    final countSiaga = _drivers.where((d) => d.status == DriverStatus.siaga).length;
    final countBertugas = _drivers.where((d) => d.status == DriverStatus.bertugas).length;
    final countCuti = _drivers.where((d) => d.status == DriverStatus.cuti).length;
    final countNonaktif = _drivers.where((d) => d.status == DriverStatus.nonaktif).length;

    return RefreshIndicator(
      onRefresh: () => _loadDrivers(forceRefresh: true),
      color: const Color(0xFF24487A),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Kelola Driver & Pengemudi Dinas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24487A).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_drivers.length} Driver',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF24487A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kelola data pengemudi dinas, lisensi SIM, nomor kontak, serta status kesiapan operasional pool.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => DriverFormDialog.show(
                        context,
                        onSuccess: () => _loadDrivers(forceRefresh: true),
                      ),
                      icon: const Icon(Icons.person_add_rounded, size: 16),
                      label: Text(
                        isMobile ? 'Tambah' : 'Tambah Driver Baru',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24487A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Filter Chips & Stats
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Semua (${_drivers.length})',
                        isSelected: _selectedStatusFilter == null,
                        color: const Color(0xFF24487A),
                        onTap: () => setState(() => _selectedStatusFilter = null),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Siaga ($countSiaga)',
                        isSelected: _selectedStatusFilter == DriverStatus.siaga,
                        color: const Color(0xFF16A34A),
                        onTap: () => setState(() => _selectedStatusFilter = DriverStatus.siaga),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Bertugas ($countBertugas)',
                        isSelected: _selectedStatusFilter == DriverStatus.bertugas,
                        color: const Color(0xFFD97706),
                        onTap: () => setState(() => _selectedStatusFilter = DriverStatus.bertugas),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Cuti ($countCuti)',
                        isSelected: _selectedStatusFilter == DriverStatus.cuti,
                        color: const Color(0xFF2563EB),
                        onTap: () => setState(() => _selectedStatusFilter = DriverStatus.cuti),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Nonaktif ($countNonaktif)',
                        isSelected: _selectedStatusFilter == DriverStatus.nonaktif,
                        color: const Color(0xFF64748B),
                        onTap: () => setState(() => _selectedStatusFilter = DriverStatus.nonaktif),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari nama driver, NIP, no. telepon, golongan SIM...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      borderSide: const BorderSide(color: Color(0xFF24487A), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF24487A),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                size: 56,
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Tidak ada driver yang cocok dengan pencarian'
                                    : 'Belum ada data driver terdaftar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Coba gunakan kata kunci lain'
                                    : 'Klik tombol "+ Tambah Driver Baru" di atas untuk menambahkan.',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final driver = filtered[index];
                          return _buildDriverCard(driver, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard(Driver driver, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Driver Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF24487A).withValues(alpha: 0.12),
                child: Text(
                  driver.name.isNotEmpty
                      ? driver.name
                          .split(' ')
                          .map((w) => w.isNotEmpty ? w[0] : '')
                          .take(2)
                          .join('')
                          .toUpperCase()
                      : 'DR',
                  style: const TextStyle(
                    color: Color(0xFF24487A),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: driver.status.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Driver Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24487A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        driver.simType,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF24487A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (driver.nip.isNotEmpty) ...[
                      Text(
                        'NIP: ${driver.nip}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: driver.phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No. HP ${driver.phone} disalin ke clipboard'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 12,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            driver.phone,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (driver.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    driver.notes,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: driver.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: driver.status.color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: driver.status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  driver.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: driver.status.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Buttons: Edit & Delete
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            tooltip: 'Edit Driver',
            onPressed: () => DriverFormDialog.show(
              context,
              driverToEdit: driver,
              onSuccess: () => _loadDrivers(forceRefresh: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: const Color(0xFFDC2626),
            tooltip: 'Hapus Driver',
            onPressed: () => _showDeleteConfirmation(driver),
          ),
        ],
      ),
    );
  }
}
