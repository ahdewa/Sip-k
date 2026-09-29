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

## ✨ Fitur Utama

### 👤 1. Sisi Pegawai / Pemohon
- 🚘 **Katalog & Ketersediaan Armada**: Menampilkan unit mobil dan motor dinas lengkap dengan spesifikasi, transmisi, kapasitas, kondisi, indikator BBM, dan odometer terkini.
- 📝 **Formulir Pengajuan Digital**: Input tujuan dinas luar kota/dalam kota, tanggal peminjaman, surat tugas, dan fitur unggah foto SIM (SIM A/C) dengan fitur zoom & preview interaktif.
- 🔔 **Pusat Notifikasi Real-Time**: Pembaruan status permohonan secara otomatis (*Disetujui Kasubag* dengan nomor SPK terbit, *Ditolak*, atau *Menunggu Verifikasi*) tanpa perlu me-refresh aplikasi manual.
- 📜 **Riwayat & Cetak Lembar Nota Dinas**: Akses arsip berkas dinas, pencetakan Nota Dinas resmi, dan pelaporan mandiri saat kendaraan mulai digunakan atau selesai dikembalikan ke pool.

### 🛡️ 2. Sisi Kasubag Tata Usaha & Superadmin
- 📋 **Verifikasi Antrean Permohonan Masuk**: Pemeriksaan dokumen pemohon, kelengkapan SIM, identitas penugasan dinas, dan bentrokan jadwal kendaraan.
- ✅ **Persetujuan & Penerbitan SPK Otomatis**: Generator nomor registrasi Nota Dinas / SPK kedinasan secara otomatis.
- ❌ **Penolakan dengan Berita Acara**: Memberikan alasan penolakan yang langsung terkirim sebagai notifikasi resmi ke HP pemohon.
- 📅 **Kalender Jadwal Operasional Armada**: Visualisasi interaktif kalender penggunaan seluruh armada dinas.
- 📊 **Dashboard Analitik & Monitoring**: Grafik statistik penggunaan armada, armada terlaris, persentase bahan bakar, dan ekspor laporan berkala.
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

## 🔄 Diagram Alur Sistem (Flowchart Operasional)

Diagram alur berikut mengilustrasikan siklus lengkap pengelolaan kendaraan dinas mulai dari pengajuan permohonan oleh pegawai, verifikasi berkas oleh Kasubag Umum, hingga pengembalian unit armada dan penerbitan BAST:

```mermaid
flowchart TD
    subgraph PEMOHON["👤 1. Sisi Pegawai (Pemohon)"]
        A([Mulai]) --> B[Login Akun Pegawai]
        B --> C[Pilih Armada Dinas di Katalog]
        C --> D{Cek Status Armada}
        D -- "Digunakan / Servis" --> C
        D -- "Tersedia" --> E[Isi Formulir Peminjaman]
        E --> F[Unggah Foto SIM & Surat Tugas]
        F --> G[Kirim Permohonan Dinas]
        G --> H[(Database: Status Menunggu)]
    end

    subgraph ADMIN["🛡️ 2. Sisi Kasubag Umum (Admin Verifikasi)"]
        H --> I[Notifikasi Permohonan Masuk]
        I --> J[Review Berkas, Foto SIM & Jadwal Armada]
        J --> K{Keputusan Kasubag?}
        K -- "Tolak" --> L[Input Catatan Alasan Penolakan]
        L --> M[(Database: Status Ditolak)]
        K -- "Setujui" --> N[Sistem Generate Nomor Nota Dinas / SPK]
        N --> O[(Database: Status Disetujui)]
        O --> P[Update Status Armada: Digunakan]
    end

    subgraph PROSES["🚗 3. Pelaksanaan Dinas & Pengembalian Armada"]
        M --> Q[Push Notifikasi Penolakan ke HP Pemohon]
        Q --> Z1([Selesai / Ajukan Armada Lain])
        O --> R[Push Notifikasi Persetujuan ke HP Pemohon]
        R --> S[Cetak Lembar Nota Dinas Resmi]
        S --> T[Ambil Kunci Kontak & STNK di Loket Kasubag TU]
        T --> U[Pelaksanaan Penugasan Perjalanan Dinas]
        U --> V[Kembali ke Pool & Input Laporan Pengembalian]
        V --> W[Catat Odometer Akhir, Sisa BBM & Kondisi Fisik]
        W --> X[(Database: Status Selesai / Terbit BAST)]
        X --> Y[Update Status Armada: Tersedia]
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

## 🗄️ Struktur Database (Entity Relationship Diagram - ERD)

Berikut adalah diagram relasi antar tabel (ERD) pada basis data **`sip-k`** di MySQL:

```mermaid
erDiagram
    USERS ||--o{ LOANS : "mengajukan (places)"
    VEHICLES ||--o{ LOANS : "dialokasikan (allocated to)"
    USERS ||--o{ APP_NOTIFICATIONS : "menerima (receives)"
    USERS ||--o{ PERSONAL_ACCESS_TOKENS : "memiliki (authenticates)"

    USERS {
        bigint id PK
        string name
        string nip UK "Nomor Induk Pegawai"
        string email UK
        string password
        string role "pegawai | admin | superadmin"
        string position "Jabatan Kedinasan"
        string department "Sub Bagian / Bidang"
        string phone
        text fcm_token "Token Firebase Device"
        timestamp created_at
        timestamp updated_at
    }

    VEHICLES {
        bigint id PK
        string name "Nama Unit Armada"
        string brand "Merk / Pabrikan"
        string plate_number UK "Nomor Polisi Dinas"
        string type "mobil | motor"
        int capacity "Kapasitas Penumpang"
        string transmission "Manual | Matic"
        int odometer "Kilometer Terakhir"
        int fuel_percent "Kapasitas BBM (%)"
        string fuel_type "Jenis BBM"
        string status "tersedia | digunakan | perbaikan"
        text condition_notes
        string image_url
        timestamp created_at
        timestamp updated_at
    }

    LOANS {
        string id PK "Kode Registrasi (REQ-...)"
        bigint user_id FK "ID Pegawai Pemohon"
        string borrower_name "Nama Peminjam"
        string department "Bidang Dinas"
        string vehicle_id FK "ID Armada"
        string vehicle_name
        string destination "Kota / Lokasi Tujuan"
        text destination_address
        text purpose_description "Urgensi Dinas"
        date start_date "Tgl Mulai Peminjaman"
        date end_date "Tgl Selesai Peminjaman"
        string official_note_number "Nomor Nota Dinas"
        longtext sim_photo_path "Foto Berkas SIM Pemohon"
        string status "menunggu | disetujui | digunakan | selesai | ditolak | dibatalkan"
        string spk_number "Nomor Surat Perintah Kerja"
        text rejection_reason "Catatan Alasan Penolakan"
        int return_odometer "KM Akhir Pengembalian"
        string return_fuel "Sisa BBM Pengembalian"
        text return_notes "Catatan Kondisi Akhir"
        datetime returned_at "Waktu BAST Pengembalian"
        datetime submitted_at "Waktu Pengajuan"
        timestamp created_at
        timestamp updated_at
    }

    APP_NOTIFICATIONS {
        bigint id PK
        bigint user_id FK "Target User (NULL = Broadcast/Admin)"
        string title "Judul Pemberitahuan"
        text message "Isi Pesan Notifikasi"
        string type "submitted | approved | rejected | returned | maintenance | reminder | welcome"
        string reference_number "Nomor Referensi (SPK/REQ)"
        boolean is_read "Status Dibaca"
        timestamp created_at
        timestamp updated_at
    }

    PERSONAL_ACCESS_TOKENS {
        bigint id PK
        string tokenable_type
        bigint tokenable_id FK
        string name
        string token UK
        text abilities
        timestamp last_used_at
        timestamp expires_at
        timestamp created_at
        timestamp updated_at
    }
```

### Relasi & Integritas Data:
1. **`users` ke `loans` (One-to-Many)**: Satu akun pegawai dapat memiliki banyak riwayat permohonan dinas (`loans.user_id` merujuk ke `users.id`).
2. **`vehicles` ke `loans` (One-to-Many)**: Satu armada kendaraan dapat dijadwalkan dalam banyak permohonan pinjam (`loans.vehicle_id` merujuk ke `vehicles.id`).
3. **`users` ke `app_notifications` (One-to-Many)**: Notifikasi status persetujuan, penolakan, atau pesan personal terikat langsung ke akun pemohon (`app_notifications.user_id`). Notifikasi dengan `user_id = NULL` berlaku sebagai notifikasi global verifikasi untuk Kasubag/Admin.
4. **`users` ke `personal_access_tokens` (One-to-Many)**: Mengelola sesi login multi-device token Sanctum untuk keamanan API.

---

## 📁 Struktur Direktori Proyek

```bash
SIP-K/
├── android/                 # Konfigurasi native Android & Gradle
├── assets/                  # Logo SIP-K, gambar armada, dan ikon
├── backend/                 # Source code lengkap REST API Laravel 11
│   ├── app/Http/Controllers # Auth, Loan, Vehicle, Notification, User Controller
│   ├── app/Models/          # Eloquent Models (User, Loan, Vehicle, AppNotification)
│   ├── database/migrations/ # Skema struktur tabel database MySQL
│   ├── database/seeders/    # Data awal armada dan akun pengguna
│   └── routes/api.php       # Definisi endpoint REST API
├── lib/                     # Source code aplikasi Flutter (Frontend)
│   ├── models/              # Model data Dart (Kendaraan, Pinjaman, Notifikasi)
│   ├── screens/             # Tampilan layar (Dashboard, Form, Admin, Notifikasi)
│   ├── services/            # API Client, FCM Service, Theme Service
│   └── widgets/             # Komponen UI kustom (Kartu armada, dialog zoom SIM)
├── sip-k-database.sql       # Backup dump SQL database MySQL siap impor
└── pubspec.yaml             # Manajemen paket dan dependensi Flutter
```

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
