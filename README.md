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

**SIP-K Jatim** (*Sistem Informasi Pengelolaan Kendaraan Dinas*) adalah aplikasi terpadu berbasis **Aplikasi Mobile (Flutter)** dan **RESTful API (Laravel)** yang dirancang khusus untuk memfasilitasi tata kelola peminjaman serta operasional kendaraan dinas di lingkungan **Dinas Sosial Provinsi Jawa Timur**.

Sistem ini mengubah alur birokrasi peminjaman manual menjadi serba digital, transparan, akuntabel, dan *real-time*. Dilengkapi alur verifikasi berjenjang mulai dari pengajuan tugas kedinasan, pemeriksaan kelayakan administrasi (foto SIM), penerbitan Nota Dinas / Surat Perintah Kerja (SPK) resmi oleh Kasubag Umum, hingga pelaporan Berita Acara Serah Terima (BAST) pengembalian armada.

---

## ✨ Fitur Utama

### 👤 1. Sisi Pegawai (Pemohon)
- 🚘 **Katalog & Ketersediaan Armada**: Menampilkan unit mobil dan motor dinas lengkap dengan spesifikasi teknis, transmisi, kapasitas penumpang, kondisi fisik, indikator sisa BBM, dan catatan kilometer (odometer) terkini.
- 📝 **Formulir Pengajuan Digital**: Pengisian kota tujuan dinas, tanggal peminjaman, surat tugas, serta fitur unggah foto SIM (SIM A/C) dengan fitur perbesar foto (*zoom & preview*).
- 🔔 **Pusat Notifikasi Real-Time**: Pembaruan status permohonan secara otomatis (*Disetujui Kasubag* dengan nomor SPK terbit, *Ditolak*, atau *Menunggu Verifikasi*) langsung ke ponsel pemohon tanpa perlu memuat ulang aplikasi.
- 📜 **Riwayat & Cetak Lembar Nota Dinas**: Akses arsip berkas dinas, pencetakan lembar Nota Dinas resmi, dan pelaporan mandiri saat kendaraan mulai digunakan atau selesai dikembalikan ke pool.

### 🛡️ 2. Sisi Kasubag Tata Usaha & Super Administrator
- 📋 **Verifikasi Antrean Permohonan Masuk**: Pemeriksaan keabsahan berkas pemohon, kelengkapan foto SIM, identitas penugasan dinas, serta pengecekan bentrokan jadwal armada.
- ✅ **Persetujuan & Penerbitan SPK Otomatis**: Pembuatan nomor registrasi Nota Dinas / SPK kedinasan secara otomatis oleh sistem.
- ❌ **Penolakan dengan Berita Acara**: Pengisian catatan alasan penolakan yang langsung terkirim sebagai notifikasi resmi ke ponsel pemohon.
- 📅 **Kalender Jadwal Operasional Armada**: Visualisasi interaktif jadwal pemakaian seluruh armada dinas.
- 📊 **Dashboard Analitik & Pemantauan**: Grafik statistik penggunaan armada, kendaraan paling sering dipinjam, rata-rata konsumsi bahan bakar, dan ekspor laporan berkala.
- 👥 **Manajemen Pengguna & Armada**: Penambahan unit kendaraan baru, pembaruan data teknis, dan manajemen hak akses akun pegawai.

---

## 🏗️ Arsitektur Teknologi

```text
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│     APLIKASI KLIEN (FLUTTER)    │       │      SERVER BACKEND (LARAVEL)   │
│  - Aplikasi Android (APK)       │ <---> │  - RESTful API Controller       │
│  - Portal Web (Dashboard Admin) │ HTTP/S│  - Autentikasi Token Sanctum    │
│  - Aplikasi Desktop Windows     │ JSON  │  - Firebase Cloud Messaging     │
└─────────────────────────────────┘       └─────────────────────────────────┘
                                                           │
                                                           ▼
                                          ┌─────────────────────────────────┐
                                          │      DATABASE (MYSQL 8.4)       │
                                          │  - Data Pengguna & Hak Akses    │
                                          │  - Data Armada & Status Terkini │
                                          │  - Riwayat Peminjaman & SPK     │
                                          │  - Notifikasi Aktivitas Sistem  │
                                          └─────────────────────────────────┘
```

---

## 👥 Diagram Kasus Penggunaan (Use Case Diagram)

Diagram berikut memodelkan interaksi fungsional antara tiga aktor pengguna (**Pegawai / Pemohon**, **Kasubag Umum / Admin TU**, dan **Super Administrator**) dengan fungsi-fungsi utama di dalam sistem SIP-K:

```mermaid
flowchart LR
    subgraph AKTOR["🎭 Aktor Pengguna"]
        Pegawai(("👤 Pegawai<br/>(Pemohon)"))
        Kasubag(("🛡️ Kasubag Umum<br/>(Admin TU)"))
        SuperAdmin(("👑 Super Admin<br/>(Pusat)"))
    end

    subgraph SISTEM["💻 Sistem Informasi Pengelolaan Kendaraan (SIP-K)"]
        UC_Auth(["🔐 Masuk Akun (Email / NIP)"])
        UC_Catalog(["🚗 Lihat Katalog & Status Armada"])
        UC_Loan(["📝 Ajukan Peminjaman Kendaraan"])
        UC_UploadSIM(["📸 Unggah Foto SIM & Surat Tugas"])
        UC_Notif(["🔔 Terima Notifikasi Real-time"])
        UC_PrintND(["🖨️ Cetak Lembar Nota Dinas / SPK"])
        UC_Return(["📋 Lapor Pengembalian & BAST"])
        UC_Profile(["👤 Kelola Profil Akun"])

        UC_Verify(["📋 Verifikasi Berkas & Foto SIM"])
        UC_Approve(["✅ Setujui & Terbitkan SPK Otomatis"])
        UC_Reject(["❌ Tolak Permohonan dengan Alasan"])
        UC_Calendar(["📅 Pantau Kalender Jadwal Armada"])
        UC_AssetStatus(["🔧 Perbarui Status Kesiapan Armada"])

        UC_ManageUser(["👥 Kelola Data Pengguna & Akses"])
        UC_ManageVehicle(["🚘 Kelola Data Master Armada"])
        UC_Analytics(["📊 Dashboard Statistik & Laporan"])
    end

    %% Hubungan Pegawai (Pemohon)
    Pegawai --- UC_Auth
    Pegawai --- UC_Catalog
    Pegawai --- UC_Loan
    Pegawai --- UC_Notif
    Pegawai --- UC_PrintND
    Pegawai --- UC_Return
    Pegawai --- UC_Profile

    %% Relasi include peminjaman
    UC_Loan -.->|"<<meliputi>>"| UC_UploadSIM

    %% Hubungan Kasubag Umum (Admin TU)
    Kasubag --- UC_Auth
    Kasubag --- UC_Catalog
    Kasubag --- UC_Verify
    Kasubag --- UC_Calendar
    Kasubag --- UC_AssetStatus
    Kasubag --- UC_Notif

    %% Relasi include verifikasi
    UC_Verify -.->|"<<meliputi>>"| UC_Approve
    UC_Verify -.->|"<<meliputi>>"| UC_Reject

    %% Hubungan Super Administrator (Pusat)
    SuperAdmin --- UC_Auth
    SuperAdmin --- UC_ManageUser
    SuperAdmin --- UC_ManageVehicle
    SuperAdmin --- UC_Analytics
    SuperAdmin --- UC_Verify
    SuperAdmin --- UC_Calendar

    classDef actor fill:#1E293B,stroke:#64748B,stroke-width:2px,color:#fff;
    classDef usecase fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef includeUC fill:#0F766E,stroke:#14B8A6,stroke-width:1.5px,color:#fff;

    class Pegawai,Kasubag,SuperAdmin actor;
    class UC_Auth,UC_Catalog,UC_Loan,UC_Notif,UC_PrintND,UC_Return,UC_Profile,UC_Verify,UC_Calendar,UC_AssetStatus,UC_ManageUser,UC_ManageVehicle,UC_Analytics usecase;
    class UC_UploadSIM,UC_Approve,UC_Reject includeUC;
```

### Tabel Matriks Hak Akses Pengguna:

| No | Modul / Kasus Penggunaan (*Use Case*) | Pegawai (Pemohon) | Kasubag Umum (Admin TU) | Super Administrator |
|---|---|:---:|:---:|:---:|
| 1 | **Masuk Sistem (Email / NIP)** | ✅ | ✅ | ✅ |
| 2 | **Lihat Katalog & Status Armada** | ✅ | ✅ | ✅ |
| 3 | **Pengajuan Peminjaman & Unggah SIM** | ✅ | ❌ | ❌ |
| 4 | **Pusat Notifikasi Status Pengajuan** | ✅ | ✅ | ✅ |
| 5 | **Cetak Nota Dinas / SPK Resmi** | ✅ | ✅ | ✅ |
| 6 | **Pelaporan Pengembalian Armada & BAST** | ✅ | ✅ | ✅ |
| 7 | **Verifikasi Usulan & Persetujuan/Penolakan SPK** | ❌ | ✅ | ✅ |
| 8 | **Pemantauan Kalender Jadwal Armada** | ❌ | ✅ | ✅ |
| 9 | **Ubah Status Armada (Tersedia / Servis / Digunakan)** | ❌ | ✅ | ✅ |
| 10 | **Manajemen Data Akun Pengguna** | ❌ | ❌ | ✅ |
| 11 | **Manajemen Master Data Armada (Tambah/Ubah/Hapus)** | ❌ | ❌ | ✅ |
| 12 | **Dashboard Statistik & Ekspor Laporan Bulanan** | ❌ | ❌ | ✅ |

---

## 🔄 Diagram Alur Sistem (Flowchart Operasional)

Diagram alur berikut mengilustrasikan siklus lengkap operasional peminjaman armada dinas dari awal pengajuan hingga pengembalian dan terbitnya dokumen BAST:

```mermaid
flowchart TD
    subgraph PEMOHON["👤 1. Tahap Pegawai (Pemohon)"]
        A([Mulai]) --> B[Masuk Akun Pegawai]
        B --> C[Pilih Kendaraan di Katalog]
        C --> D{Cek Status Armada}
        D -- "Sedang Digunakan / Servis" --> C
        D -- "Tersedia" --> E[Isi Formulir Peminjaman]
        E --> F[Unggah Foto SIM & Surat Usulan]
        F --> G[Kirim Permohonan Dinas]
        G --> H[(Database: Status Menunggu)]
    end

    subgraph ADMIN["🛡️ 2. Tahap Kasubag Umum (Verifikasi Admin)"]
        H --> I[Notifikasi Permohonan Masuk]
        I --> J[Pemeriksaan Berkas, Foto SIM & Jadwal Armada]
        J --> K{Keputusan Kasubag?}
        K -- "Tolak Permohonan" --> L[Input Catatan Alasan Penolakan]
        L --> M[(Database: Status Ditolak)]
        K -- "Setujui Permohonan" --> N[Sistem Terbitkan Nomor Nota Dinas / SPK]
        N --> O[(Database: Status Disetujui)]
        O --> P[Kunci Armada: Status Digunakan]
    end

    subgraph PROSES["🚗 3. Tahap Pelaksanaan & Pengembalian Armada"]
        M --> Q[Kirim Notifikasi Penolakan ke Ponsel Pemohon]
        Q --> Z1([Selesai / Ajukan Armada Pengganti])
        O --> R[Kirim Notifikasi Persetujuan ke Ponsel Pemohon]
        R --> S[Cetak Lembar Nota Dinas Resmi]
        S --> T[Ambil Kunci Kontak & STNK di Loket Kasubag TU]
        T --> U[Pelaksanaan Perjalanan Dinas Operasional]
        U --> V[Kembali ke Pool & Input Laporan Pengembalian]
        V --> W[Catat Kilometer Akhir, Sisa BBM & Kondisi Fisik]
        W --> X[(Database: Status Selesai / Terbit BAST)]
        X --> Y[Perbarui Status Armada: Tersedia Kembali]
        Y --> Z2([Selesai])
    end

    classDef startEnd fill:#24487A,stroke:#1E3A8A,stroke-width:2px,color:#fff;
    classDef process fill:#1E293B,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef decision fill:#78350F,stroke:#F59E0B,stroke-width:1.5px,color:#fff;
    classDef database fill:#064E3B,stroke:#10B981,stroke-width:1.5px,color:#fff;
    classDef reject fill:#7F1D1D,stroke:#EF4444,stroke-width:1.5px,color:#fff;

    class A,Z1,Z2 startEnd;
    class B,C,E,F,G,I,J,N,P,R,S,T,U,V,W,Y process;
    class D,K decision;
    class H,O,X database;
    class L,M,Q reject;
```

---

## 🗄️ Struktur Basis Data (Diagram Relasi Entitas - ERD)

Diagram relasi antar tabel basis data **`sip-k`** pada MySQL:

```mermaid
erDiagram
    USERS ||--o{ LOANS : "mengajukan_permohonan"
    VEHICLES ||--o{ LOANS : "dialokasikan_ke"
    USERS ||--o{ APP_NOTIFICATIONS : "menerima_notifikasi"
    USERS ||--o{ PERSONAL_ACCESS_TOKENS : "memiliki_sesi"

    USERS {
        bigint id PK "Nomor Identifikasi Pengguna (ID)"
        string name "Nama Lengkap Pegawai"
        string nip UK "Nomor Induk Pegawai (NIP)"
        string email UK "Alamat Email Kedinasan"
        string password "Kata Sandi Terenkripsi"
        string role "Peran: pegawai | admin | superadmin"
        string position "Jabatan Kedinasan"
        string department "Sub Bagian / Bidang Dinas"
        string phone "Nomor Telepon / WhatsApp"
        text fcm_token "Token Notifikasi Perangkat"
        timestamp created_at "Waktu Akun Dibuat"
        timestamp updated_at "Waktu Akun Diperbarui"
    }

    VEHICLES {
        bigint id PK "Nomor Identifikasi Kendaraan (ID)"
        string name "Nama Unit Kendaraan"
        string brand "Merk / Pabrikan Kendaraan"
        string plate_number UK "Nomor Polisi Kendaraan Dinas"
        string type "Jenis: mobil | motor"
        int capacity "Kapasitas Jumlah Penumpang"
        string transmission "Transmisi: Manual | Matic"
        int odometer "Catatan Kilometer Terakhir (KM)"
        int fuel_percent "Kapasitas Sisa Bahan Bakar (%)"
        string fuel_type "Jenis Bahan Bakar Armada"
        string status "Status: tersedia | digunakan | perbaikan"
        text condition_notes "Catatan Kondisi Fisik & Mesin"
        string image_url "Tautan Berkas Foto Kendaraan"
        timestamp created_at "Waktu Data Masuk"
        timestamp updated_at "Waktu Data Diperbarui"
    }

    LOANS {
        string id PK "Nomor Registrasi Usulan (REQ-...)"
        bigint user_id FK "ID Pegawai Pemohon"
        string borrower_name "Nama Lengkap Peminjam"
        string department "Bidang Dinas Pemohon"
        string vehicle_id FK "ID Kendaraan yang Dipinjam"
        string vehicle_name "Nama Unit Kendaraan"
        string destination "Kota / Wilayah Tujuan Dinas"
        text destination_address "Alamat Lengkap Tujuan Dinas"
        text purpose_description "Urgensi dan Keperluan Tugas"
        date start_date "Tanggal Mulai Peminjaman"
        date end_date "Tanggal Selesai Peminjaman"
        string official_note_number "Nomor Surat Usulan / Nota Dinas"
        longtext sim_photo_path "Berkas Foto SIM Pemohon"
        string status "Status: menunggu | disetujui | digunakan | selesai | ditolak | dibatalkan"
        string spk_number "Nomor Surat Perintah Kerja (SPK)"
        text rejection_reason "Catatan Alasan Penolakan dari Kasubag"
        int return_odometer "Catatan Kilometer Akhir Pengembalian"
        string return_fuel "Sisa Bahan Bakar Saat Kembali"
        text return_notes "Catatan Kondisi Fisik Setelah Digunakan"
        datetime returned_at "Waktu Pengembalian Resmi (BAST)"
        datetime submitted_at "Waktu Pengajuan Usulan Dikirim"
        timestamp created_at "Waktu Catatan Dibuat"
        timestamp updated_at "Waktu Catatan Diperbarui"
    }

    APP_NOTIFICATIONS {
        bigint id PK "Nomor Identifikasi Notifikasi (ID)"
        bigint user_id FK "ID Pengguna Penerima (Kosong = Kasubag)"
        string title "Judul Pemberitahuan Notifikasi"
        text message "Rincian Isi Pesan Notifikasi"
        string type "Kategori: pengajuan | persetujuan | penolakan | info"
        string reference_number "Nomor Registrasi Referensi (REQ / SPK)"
        boolean is_read "Status Keterbacaan Pesan"
        timestamp created_at "Waktu Notifikasi Terbit"
        timestamp updated_at "Waktu Notifikasi Diperbarui"
    }

    PERSONAL_ACCESS_TOKENS {
        bigint id PK "Nomor Identifikasi Token (ID)"
        string tokenable_type "Tipe Entitas Model Terkait"
        bigint tokenable_id FK "ID Pengguna Pemilik Token"
        string name "Nama Perangkat / Sesi Pengguna"
        string token UK "Kode Kunci Akses Rahasia"
        text abilities "Hak Akses & Wewenang Token"
        timestamp last_used_at "Waktu Terakhir Digunakan"
        timestamp expires_at "Batas Waktu Kedaluwarsa Sesi"
        timestamp created_at "Waktu Token Diterbitkan"
        timestamp updated_at "Waktu Token Diperbarui"
    }
```

### Penjelasan Hubungan Relasi Antar-Tabel:
1. **Tabel `users` ke `loans` (Satu-ke-Banyak)**: Satu akun pegawai dapat memiliki banyak riwayat pengajuan permohonan dinas (`loans.user_id` berelasi langsung ke `users.id`).
2. **Tabel `vehicles` ke `loans` (Satu-ke-Banyak)**: Satu unit kendaraan dinas dapat dijadwalkan ke dalam banyak agenda penugasan dinas (`loans.vehicle_id` berelasi langsung ke `vehicles.id`).
3. **Tabel `users` ke `app_notifications` (Satu-ke-Banyak)**: Setiap notifikasi pembaruan status terkirim langsung ke akun pegawai pemohon (`app_notifications.user_id`). Notifikasi dengan nilai `user_id = NULL` dialokasikan khusus sebagai notifikasi antrean verifikasi Kasubag Umum / Administrator.
4. **Tabel `users` ke `personal_access_tokens` (Satu-ke-Banyak)**: Mengelola sesi masuk multi-perangkat (ponsel dan komputer) melalui token autentikasi Laravel Sanctum demi keamanan data.

---

## 📁 Struktur Direktori Proyek

```bash
SIP-K/
├── android/                 # Konfigurasi native sistem Android & Gradle
├── assets/                  # Logo SIP-K, foto armada dinas, dan ikon
├── backend/                 # Kode sumber lengkap REST API Laravel 11
│   ├── app/Http/Controllers # Controller Otentikasi, Pinjaman, Armada, Notifikasi, Pengguna
│   ├── app/Models/          # Model data Eloquent (User, Loan, Vehicle, AppNotification)
│   ├── database/migrations/ # Skema struktur tabel database MySQL
│   ├── database/seeders/    # Data awal armada dan akun default
│   └── routes/api.php       # Definisi rute endpoint REST API
├── lib/                     # Kode sumber aplikasi Flutter (Frontend)
│   ├── models/              # Model data Dart (Kendaraan, Pinjaman, Notifikasi, Pengguna)
│   ├── screens/             # Tampilan halaman (Dashboard, Formulir, Admin, Notifikasi)
│   ├── services/            # Layanan API, Firebase FCM, dan Tema Gelap/Terang
│   └── widgets/             # Komponen UI khusus (Kartu armada, dialog perbesar SIM)
├── sip-k-database.sql       # Berkas cadangan database MySQL siap impor
└── pubspec.yaml             # Manajemen paket dan dependensi Flutter
```

---

## 🚀 Panduan Pemasangan & Menjalankan

### 1. Menjalankan Backend Laravel
Pastikan PHP 8.2+ dan MySQL sudah aktif (misal melalui Laragon atau XAMPP):
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate

# Konfigurasi database pada berkas .env:
# DB_DATABASE=sip-k
# DB_USERNAME=root
# DB_PASSWORD=

php artisan migrate --seed
php artisan serve
```

### 2. Menjalankan Aplikasi Flutter
```bash
# Unduh dependensi aplikasi
flutter pub get

# Jalankan pada peramban Chrome / Web
flutter run -d chrome

# Jalankan pada ponsel Android / Emulator
flutter run
```

### 3. Mengatur Alamat Endpoint API
Untuk menghubungkan ponsel fisik atau server VPS, sesuaikan URL server pada berkas `lib/services/api_config.dart`:
```dart
class ApiConfig {
  static String get baseUrl => 'http://<IP_KOMPUTER_ATAU_VPS>/sip-k-backend/public/api';
}
```

---

## 👥 Akun Bawaan untuk Pengujian Sistem

| Peran / Jabatan | Nama Pengguna | Akun Masuk (Email / NIP) | Kata Sandi | Hak Akses Utama |
|---|---|---|---|---|
| **Pegawai (Pemohon)** | Alamsyah | `199503152020121002` | `password` | Mengajukan kendaraan dinas, cek status SPK, cetak Nota Dinas |
| **Kasubag Umum (Admin TU)** | Ahmad Dewantara, S.STP | `admin@dinsos.jatimprov.go.id` | `admin123` | Memverifikasi berkas, menyetujui / menolak usulan peminjaman |
| **Super Administrator** | Super Admin SIP-K | `superadmin@dinsos.jatimprov.go.id` | `superadmin123` | Akses sistem penuh, manajemen data pengguna & master armada |

---

## 📄 Lisensi
Hak Cipta © 2026 **Pemerintah Provinsi Jawa Timur - Dinas Sosial**.  
Dikembangkan untuk mendukung digitalisasi dan transparansi pengelolaan aset daerah.

## Didukung Oleh:  
**DRD**
