# 🚗 SIP-K JATIM (Sistem Informasi Pengelolaan Kendaraan)
### Dinas Sosial Provinsi Jawa Timur

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Laravel-11.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel" />
  <img src="https://img.shields.io/badge/MySQL-8.4-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/Firebase-FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-brightgreen?style=for-the-badge" alt="Platform" />
</p>

---

## 📌 Tentang Proyek

**SIP-K Jatim** (*Sistem Informasi Pengelolaan Kendaraan Dinas*) adalah aplikasi terintegrasi berbasis **Mobile (Flutter)** dan **RESTful API (Laravel)** yang dirancang khusus untuk memfasilitasi tata kelola peminjaman dan operasional kendaraan dinas operasional di lingkungan **Dinas Sosial Provinsi Jawa Timur**.

Sistem ini mentransformasikan alur birokrasi peminjaman konvensional menjadi digital, transparan, akuntabel, dan *real-time*. Dilengkapi alur verifikasi bertingkat mulai dari pengajuan dinas, pemeriksaan kelayakan administrasi (SIM), penerbitan Nota Dinas / Surat Perintah Kerja (SPK) oleh Kasubag Umum, hingga Berita Acara Serah Terima (BAST) pengembalian armada.

---

## 🔄 Struktur Alur Kerja Sistem (Workflow System)

Sistem mengadopsi siklus operasional kedinasan penuh dari hulu ke hilir:

```text
  [ Pegawai / Pemohon ]
           │
           ▼
  1. Pilih Armada & Isi Form Pinjam (Unggah SIM, Tujuan & Jadwal)
           │
           ▼  (Status: 'menunggu')
  ┌────────────────────────────────────────────────────────┐
  │         2. Verifikasi oleh Kasubag Umum (Admin)        │
  │   - Cek kelengkapan surat tugas & foto SIM             │
  │   - Cek ketersediaan jadwal pada Kalender Armada       │
  └──────────────────────────┬─────────────────────────────┘
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
       [ DISETUJUI ]                     [ DITOLAK ]
            │                                 │
            ├─► Terbit No. SPK / Nota Dinas   └─► Kirim Alasan Penolakan
            │   (Status: 'disetujui')             (Status: 'ditolak')
            ▼                                     ke Notifikasi Pemohon
  3. Pengambilan Kunci & Berkas di Loket TU
            │
            ▼  (Status: 'digunakan')
  4. Armada Operasional Digunakan Bertugas
            │
            ▼
  5. Pengembalian Armada ke Pool
     (Input Odometer Akhir, Sisa BBM & Catatan Kondisi)
            │
            ▼  (Status: 'selesai')
  6. Terbit Berita Acara Serah Terima (BAST) Digital
```

---

## ✨ Fitur Utama

### 👤 1. Sisi Pegawai / Pemohon
- 🚘 **Katalog & Ketersediaan Armada**: Menampilkan unit mobil dan motor dinas lengkap dengan spesifikasi, transmisi, kapasitas, kondisi, indikator BBM, dan odometer terkini.
- 📝 **Formulir Pengajuan Digital**: Input tujuan dinas luar kota/dalam kota, tanggal peminjaman, surat tugas, dan fitur unggah foto SIM (SIM A/C) dengan fitur zoom & preview interaktif.
- 🔔 **Pusat Notifikasi Real-Time**: Pembaruan status permohonan secara otomatis (*Disetujui Kasubag* dengan nomor SPK terbit, *Ditolak*, atau *Menunggu Verifikasi*) dengan *auto-refresh & background sync*.
- 📜 **Riwayat & Cetak Lembar Nota Dinas**: Akses arsip berkas dinas, pencetakan Nota Dinas resmi, dan pelaporan mandiri saat kendaraan mulai digunakan atau selesai dikembalikan ke pool.

### 🛡️ 2. Sisi Kasubag Tata Usaha & Superadmin
- 📋 **Verifikasi Antrean Permohonan Masuk**: Pemeriksaan dokumen pemohon, kelengkapan SIM, identitas penugasan dinas, dan bentrokan jadwal kendaraan.
- ✅ **Persetujuan & Penerbitan SPK Otomatis**: Generator nomor registrasi Nota Dinas / SPK kedinasan secara otomatis (`ND-xxxx/DINSOS/2026`).
- ❌ **Penolakan dengan Berita Acara**: Memberikan alasan penolakan yang langsung terkirim sebagai notifikasi resmi ke HP pemohon.
- 📅 **Kalender Jadwal Operasional Armada**: Visualisasi interaktif kalender penggunaan seluruh armada dinas.
- 📊 **Dashboard Analitik & Monitoring**: Grafik statistik penggunaan armada, armada terlaris, persentase bahan bakar, dan ekspor laporan berkala (PDF/Excel).
- 👥 **Manajemen Pengguna & Armada**: Penambahan unit armada baru, pembaruan data teknis, dan manajemen hak akses akun pegawai.

---

## 🏗️ Arsitektur Teknologi

```text
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│     CLIENT APPS (FLUTTER)       │       │      BACKEND SERVER (LARAVEL)   │
│  - Android Application (APK)    │ <---> │  - RESTful API Controller       │
│  - Web Portal (Dashboard Admin) │ HTTP/S│  - Laravel Sanctum Token Auth   │
│  - Desktop Management           │ JSON  │  - Firebase Push Notifications  │
└─────────────────────────────────┘       └─────────────────────────────────┘
                                                           │
                                                           ▼
                                          ┌─────────────────────────────────┐
                                          │      DATABASE (MYSQL 8.4)       │
                                          │  - Users, Roles & Profiles      │
                                          │  - Vehicles & Real-time Status  │
                                          │  - Loans & SPK History          │
                                          │  - Activity Notifications       │
                                          └─────────────────────────────────┘
```

---

## 📁 Struktur Direktori Proyek

Struktur folder terorganisir rapi memisahkan frontend Flutter dan backend Laravel:

```bash
SIP-K/
├── android/                         # Konfigurasi native Android (Gradle, Manifest, Icon)
│   └── app/
│       ├── google-services.json     # Konfigurasi Firebase Cloud Messaging (FCM)
│       └── src/main/AndroidManifest.xml
│
├── assets/                          # Aset statis aplikasi
│   ├── icons/                       # Ikon kategori kendaraan & status
│   └── images/                      # Logo SIP-K Dinsos Jatim & foto armada
│
├── backend/                         # Source code lengkap REST API Laravel 11
│   ├── app/
│   │   ├── Http/Controllers/        # Controller API Endpoint
│   │   │   ├── AuthController.php   # Login, profile, dan token Sanctum
│   │   │   ├── LoanController.php   # Peminjaman, approval SPK, reject & SIM upload
│   │   │   ├── NotificationController.php # Filter notifikasi pegawai & admin
│   │   │   ├── UserController.php   # Manajemen data pengguna & akun
│   │   │   └── VehicleController.php# CRUD & update status operasional armada
│   │   ├── Models/                  # Eloquent ORM Models
│   │   │   ├── AppNotification.php  # Model entitas notifikasi
│   │   │   ├── Loan.php             # Model entitas peminjaman & SPK
│   │   │   ├── User.php             # Model entitas user & role
│   │   │   └── Vehicle.php          # Model entitas armada kendaraan
│   │   └── Services/
│   │       └── FirebaseService.php  # Pengirim Push Notification Firebase (FCM)
│   ├── config/                      # Konfigurasi database, auth, cors, dan mail
│   ├── database/
│   │   ├── migrations/              # Skema tabel database MySQL
│   │   └── seeders/                 # Data inisialisasi user dan kendaraan awal
│   └── routes/
│       └── api.php                  # Routing lengkap RESTful API (/api/*)
│
├── lib/                             # Source code frontend Flutter
│   ├── main.dart                    # Entry point aplikasi & inisialisasi FCM
│   ├── models/                      # Data classes / Model Dart
│   │   ├── loan_model.dart          # Struktur data peminjaman & status enum
│   │   ├── notification_model.dart  # Struktur data notifikasi & tipe
│   │   ├── user_model.dart          # Profil pengguna, NIP, & jabatan
│   │   └── vehicle_model.dart       # Spesifikasi kendaraan dinas
│   ├── screens/                     # Halaman Tampilan Antarmuka (UI)
│   │   ├── admin/                   # Modul Khusus Kasubag & Superadmin
│   │   │   ├── dialogs/             # Modal dialog (Detail pinjam, Form armada)
│   │   │   ├── tabs/                # Tab Admin (Dashboard, Loans, Vehicles, Users, Calendar, Reports)
│   │   │   └── widgets/             # Widget khusus admin (Sidebar, Drawer, Loan Card)
│   │   ├── admin_approval_screen.dart # Layar verifikasi persetujuan Kasubag
│   │   ├── catalog_screen.dart      # Katalog & filter unit kendaraan
│   │   ├── home_screen.dart         # Layar utama, Bottom Nav & Auto-sync background
│   │   ├── loan_flow_screen.dart    # Alur pengajuan peminjaman bertahap
│   │   ├── loan_form_screen.dart    # Formulir peminjaman & upload SIM
│   │   ├── loan_history_screen.dart # Riwayat berkas, Nota Dinas & BAST
│   │   ├── login_screen.dart        # Layar autentikasi NIP/Email
│   │   ├── notification_screen.dart # Layar notifikasi dengan Pull-to-Refresh
│   │   ├── profile_screen.dart      # Profil pegawai, ubah data & ganti tema
│   │   └── user_dashboard_screen.dart # Beranda ringkasan aktivitas pemohon
│   ├── services/                    # Business Logic & Integrasi Layanan Luar
│   │   ├── api_config.dart          # Konfigurasi cerdas Base URL server/VPS
│   │   ├── api_service.dart         # HTTP Client (GET/POST/PUT/DELETE API)
│   │   ├── fcm_service.dart         # Penangan notifikasi Firebase background
│   │   ├── notification_permission_service.dart # Izin notifikasi Android 13+
│   │   ├── report_export_service.dart # Ekspor laporan dinas ke PDF/Excel
│   │   └── theme_service.dart       # Pengatur tema tampilan (Dark/Light mode)
│   └── widgets/                     # Komponen UI Reusable
│       ├── app_header_profile_avatar.dart # Avatar header profil terpadu
│       ├── app_image.dart           # Komponen gambar dengan cache & CORS resolver
│       └── notification_permission_dialog.dart # Dialog izin notifikasi modern
│
├── sip-k-database.sql               # Backup dump SQL MySQL 8.4 siap impor
├── analysis_options.yaml            # Aturan standarisasi linter Dart
└── pubspec.yaml                     # Dependensi paket Flutter (HTTP, Firebase, dll)
```

---

## 🗄️ Struktur Basis Data (Database Schema)

Hubungan relasi antar entitas utama pada database **`sip-k`**:

```text
┌───────────────────────────┐           ┌───────────────────────────┐
│           USERS           │           │         VEHICLES          │
├───────────────────────────┤           ├───────────────────────────┤
│ PK  id                    │           │ PK  id                    │
│     name                  │           │     name                  │
│     nip                   │           │     brand                 │
│     email                 │           │     plate_number          │
│     password              │           │     type (mobil/motor)    │
│     role                  │           │     capacity              │
│     department            │           │     status                │
│     fcm_token             │           │     fuel_percent          │
└─────────────┬─────────────┘           │     odometer              │
              │ 1                       └─────────────┬─────────────┘
              │                                       │ 1
              │ N                                     │ N
              ▼                                       ▼
┌───────────────────────────────────────────────────────────────────┐
│                               LOANS                               │
├───────────────────────────────────────────────────────────────────┤
│ PK  id (REQ-xxxx)                                                 │
│ FK  user_id           ──► Referensi ke USERS (Pemohon)            │
│ FK  vehicle_id        ──► Referensi ke VEHICLES (Armada)          │
│     borrower_name                                                 │
│     destination                                                   │
│     start_date / end_date                                         │
│     official_note_number                                          │
│     sim_photo_path    (LONGTEXT - Foto SIM terenkripsi / URL)     │
│     status            (menunggu | disetujui | digunakan | selesai | ditolak) │
│     spk_number        (ND-xxxx/DINSOS/2026)                       │
│     rejection_reason                                              │
│     return_odometer / return_fuel / return_notes                  │
└─────────────────────────────────┬─────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────────────┐
│                         APP_NOTIFICATIONS                         │
├───────────────────────────────────────────────────────────────────┤
│ PK  id                                                            │
│ FK  user_id           ──► ID Penerima Notifikasi (NULL jika admin)│
│     title             ──► Judul Notifikasi                        │
│     message           ──► Ringkasan Pesan                         │
│     type              ──► 'submitted'|'approved'|'rejected'|...   │
│     reference_number  ──► Nomor Registrasi SPK / REQ ID           │
│     is_read           ──► Status Baca (Boolean)                   │
└───────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Matriks Hak Akses Pengguna (Role-Based Access Control)

| Modul / Fitur Sistem | Pegawai (Pemohon) | Kasubag Umum (Admin) | Super Administrator |
|---|:---:|:---:|:---:|
| **Katalog Armada & Ketersediaan** | ✅ Lihat Saja | ✅ Lihat & Kelola | ✅ Penuh |
| **Pengajuan Peminjaman & Upload SIM** | ✅ Ajukan Sendiri | ❌ | ❌ |
| **Verifikasi Berkas & Foto SIM** | ❌ | ✅ Verifikasi | ✅ Verifikasi |
| **Persetujuan & Penerbitan No. SPK** | ❌ | ✅ Setujui | ✅ Setujui |
| **Penolakan Permohonan + Alasan** | ❌ | ✅ Tolak | ✅ Tolak |
| **Cetak Nota Dinas & Riwayat BAST** | ✅ Milik Sendiri | ✅ Semua Berkas | ✅ Semua Berkas |
| **Kalender Jadwal Operasional** | ✅ Lihat Jadwal | ✅ Lihat & Atur | ✅ Lihat & Atur |
| **Tambah / Edit Unit Kendaraan Baru** | ❌ | ✅ Kelola Unit | ✅ Penuh |
| **Laporan & Analitik Penggunaan** | ❌ | ✅ Ekspor Laporan | ✅ Penuh |
| **Manajemen Akun & Hak Akses User** | ❌ | ❌ | ✅ Kelola Akun |

---

## 🚀 Panduan Instalasi & Menjalankan

### 1. Menjalankan Backend Laravel
Pastikan PHP 8.2+ dan MySQL sudah terpasang (misal melalui Laragon / XAMPP):
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate

# Konfigurasi database di file .env:
# DB_DATABASE=sip-k
# DB_USERNAME=root
# DB_PASSWORD=

php artisan migrate --seed
php artisan serve
```

### 2. Menjalankan Aplikasi Flutter
```bash
# Pastikan dependensi terpasang
flutter pub get

# Menjalankan di Chrome / Web
flutter run -d chrome

# Menjalankan di HP Fisik / Emulator Android
flutter run
```

### 3. Mengatur URL Endpoint API
Untuk menghubungkan HP fisik atau VPS, sesuaikan URL server di file `lib/services/api_config.dart`:
```dart
class ApiConfig {
  static String get baseUrl => 'http://<IP_KOMPUTER_ATAU_VPS>/sip-k-backend/public/api';
}
```

---

## 👥 Akun Bawaan untuk Pengujian (Default Seeded Users)

| Role / Jabatan | Nama Pengguna | NIP / Akun Login | Password | Hak Akses |
|---|---|---|---|---|
| **Pegawai (Pemohon)** | Alamsyah | `199503152020121002` | `password` | Pengajuan mobil, cek status, cetak Nota Dinas |
| **Kasubag Umum (Admin)** | Ahmad Dewantara, S.STP | `admin@dinsos.jatimprov.go.id` | `admin123` | Verifikasi SPK, setujui/tolak permohonan |
| **Super Administrator** | Super Admin SIP-K | `superadmin@dinsos.jatimprov.go.id` | `superadmin123` | Akses penuh sistem, manajemen user & armada |

---

## 📄 Lisensi
Hak Cipta © 2026 **Pemerintah Provinsi Jawa Timur - Dinas Sosial**.  
Dikembangkan untuk mendukung digitalisasi dan transparansi pengelolaan aset daerah.
