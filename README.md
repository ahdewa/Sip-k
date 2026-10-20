<p align="center">
  <img src="assets/images/logo_sipk.png" alt="Logo SIP-K Jatim" width="130" />
</p>

<h1 align="center">🚗 SIP-K JATIM / OVBS</h1>
<h3 align="center">Sistem Informasi Pengelolaan Kendaraan Dinas Operasional<br/><i>(Online Vehicle Booking System)</i></h3>
<p align="center"><strong>Pemerintah Provinsi Jawa Timur — Dinas Sosial</strong></p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Laravel-11.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel" />
  <img src="https://img.shields.io/badge/MySQL-8.4-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/Firebase-FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Azure-Cloud%20VM-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white" alt="Azure VM" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-brightgreen?style=for-the-badge" alt="Platform" />
</p>

<p align="center">
  <a href="#-tentang-proyek">Tentang</a> •
  <a href="#-fitur-utama">Fitur Utama</a> •
  <a href="#%EF%B8%8F-arsitektur--optimasi-performa-tinggi">Arsitektur & Kinerja</a> •
  <a href="#-diagram-kasus-penggunaan-use-case-diagram">Use Case</a> •
  <a href="#-diagram-aktivitas-activity-diagram">Activity Diagram</a> •
  <a href="#-diagram-aliran-data-data-flow-diagram---dfd">DFD (0, 1, 2)</a> •
  <a href="#-diagram-alur-sistem-flowchart-operasional">Flowchart</a> •
  <a href="#%EF%B8%8F-struktur-basis-data-erd">ERD</a> •
  <a href="#-panduan-instalasi--deployment">Instalasi & Deployment</a> •
  <a href="#-akun-uji-coba-bawaan-sistem">Akun Default</a> •
  <a href="#-support-by-">Support By</a>
</p>

---

## 📌 Tentang Proyek

**SIP-K Jatim** (*Sistem Informasi Pengelolaan Kendaraan Dinas Operasional*), juga dikenal sebagai **OVBS** (*Online Vehicle Booking System*), adalah platform modern terpadu multi-platform (**Aplikasi Mobile Flutter**, **Web Portal**, dan **Windows Desktop**) yang didukung oleh **RESTful API Laravel 11** berkinerja tinggi. Sistem ini dirancang secara khusus untuk memfasilitasi tata kelola peminjaman, perizinan, dan pemeliharaan kendaraan dinas di lingkungan **Dinas Sosial Provinsi Jawa Timur**.

Sistem ini mentransformasi birokrasi manual berbasis formulir fisik menjadi alur kerja serba digital, transparan, akuntabel, dan *real-time*:
1. **Pengajuan Kedinasan Mandiri**: Pegawai mengajukan unit kendaraan secara langsung, memilih jadwal, melampirkan berkas foto SIM, serta mengunggah surat usulan dinas (PDF/Gambar).
2. **Verifikasi & Persetujuan Kasubag Umum / TU**: Pemeriksaan keabsahan dokumen, pengecekan jadwal bebas-benturan secara otomatis, penerbitan nomor Surat Perintah Kerja (SPK) otomatis, atau penolakan dengan catatan resmi.
3. **Dual Pratinjau & Pengunduhan Dokumen**: Dukungan pratinjau langsung berkas PDF asli yang diunggah pemohon serta opsi format lembar Nota Dinas standar Pemprov Jatim, dilengkapi penyimpanan otomatis ke folder *Download/OVBS*.
4. **Pengembalian Armada Praktis & Tepat Waktu**: Pengembalian unit kendaraan dan kunci kontak ke pool tepat waktu tanpa perlu mengisi formulir BAST bagi pegawai peminjam.

---

## ✨ Fitur Utama

### 👤 1. Portal Pegawai (Pemohon)
* 🚘 **Katalog & Ketersediaan Armada Real-time**: Menampilkan unit mobil dan motor dinas lengkap dengan foto resolusi tinggi, jenis transmisi, kapasitas penumpang, sisa bahan bakar, dan status kesiapan.
* 📝 **Formulir Pengajuan Terpadu**: Input tujuan dinas, alamat, tanggal pinjam, urgensi tugas, unggah foto SIM, serta berkas surat tugas / nota dinas (PDF / Gambar).
* 📄 **In-App Dual PDF Viewer**:
  * Menampilkan dokumen asli yang diunggah oleh pemohon secara instan.
  * Opsi berganti ke format Lembar Nota Dinas resmi kedinasan.
  * Fitur perbesar (*zoom*), navigasi halaman, pencarian, dan unduh otomatis ke penyimpanan perangkat (`Download/OVBS/`).
* 🔔 **Notifikasi Real-time Terpersonalisasi**: Pegawai hanya menerima notifikasi khusus yang berkaitan dengan pengajuannya (*Diajukan*, *Disetujui*, *Ditolak*, atau *Pemberitahuan Umum*).
* 📰 **Berita & Pengumuman Kedinasan**: Menampilkan informasi, kegiatan, dan surat edaran resmi dari pimpinan Dinas Sosial Jatim.
* 📜 **Riwayat Pengajuan & Pelacakan Status**: Pemantauan status permohonan dinas secara transparan hingga status perjalanan selesai saat armada dikembalikan ke pool (tanpa kewajiban pengisian form BAST oleh pegawai).

### 🛡️ 2. Portal Kasubag Tata Usaha & Super Administrator
* 📋 **Verifikasi Berkas & Pengecekan Tabrakan Jadwal**: Pemeriksaan foto SIM dan pratinjau dokumen usulan pemohon dengan sistem deteksi benturan jadwal antar peminjam.
* ✅ **Penerbitan SPK Otomatis**: Menghasilkan nomor Surat Perintah Kerja (SPK) unik kedinasan saat permohonan disetujui.
* ❌ **Penolakan Transparan**: Mengirimkan catatan alasan penolakan secara terstruktur yang langsung diterima pemohon.
* 📅 **Kalender Jadwal Operasional Seluruh Armada**: Visualisasi jadwal agenda perjalanan seluruh armada dinas secara interaktif harian dan bulanan.
* 📥 **Import Pengguna Massal via Excel (`.xlsx`)**:
  * Mengunggah daftar pegawai dan admin sekaligus menggunakan berkas template Excel.
  * Deteksi peran otomatis (*Pegawai*, *Admin TU / Kasubag*, *Super Administrator*).
  * Sanitasi nomor WhatsApp/telepon dan pembuatan kata sandi awal secara otomatis.
* 📊 **Dashboard Analitik & Statistik**: Statistik unit paling sering digunakan, rata-rata konsumsi BBM, grafik tren dinas bulanan, dan ekspor data laporan.
* 🔧 **Manajemen Master Data Kendaraan**: Tambah, ubah data unit, kelola status perbaikan/servis rutin di bengkel, dan kelola dokumen unit.
* 🔔 **Segregasi Notifikasi Verifikator**: Administrator menerima notifikasi khusus mengenai usulan baru yang masuk serta pengembalian armada oleh pemohon.
* 💬 **Helpdesk WhatsApp Terintegrasi**: Akses cepat satu klik ke WhatsApp Admin Helpdesk untuk bantuan teknis dan reset kata sandi.

---

## ⚡ Arsitektur & Optimasi Performa Tinggi

Sistem dirancang tangguh (*high-concurrency ready*) untuk melayani ratusan pegawai dan admin secara bersamaan tanpa lonjakan beban (*resource spike*):

```text
┌────────────────────────────────────────────────────────┐
│               APLIKASI KLIEN (FLUTTER)                 │
│  - Android APK (Mobile)                                │
│  - Web Portal (Chrome / Edge / Firefox)                │
│  - Windows Desktop Native                              │
│                                                        │
│  [Fitur Kinerja]:                                      │
│  * Persistent Connection Pool (HTTP Keep-Alive)        │
│  * In-Memory TTL Cache (Kendaraan, User, Profil)       │
│  * Lifecycle-Aware Polling (Jeda saat background)      │
│  * In-App PDF Streamer & Auto-Download ke Storage      │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ HTTPS / REST API JSON
                            ▼
┌────────────────────────────────────────────────────────┐
│            AZURE CLOUD VM (UBUNTU / NGINX)             │
│  IP Server: 20.244.48.18 | PHP 8.2+ FPM                │
│                                                        │
│  [Laravel 11 REST API Backend]:                        │
│  * Laravel Sanctum Token Authentication                │
│  * Cache::remember Layer untuk Katalog Armada          │
│  * Base64 to Storage Pipeline (public/storage/)        │
│  * Push Notifications via Firebase Cloud Messaging     │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                 DATABASE (MYSQL 8.4)                   │
│  * Composite Indexes pada Kolom Query Kritis           │
│    (user_id + status, vehicle_id + start/end_date)     │
│  * Efficient Foreign Keys & Relational Integrity       │
└────────────────────────────────────────────────────────┘
```

### 🚀 Keunggulan Optimasi Kinerja
1. **Persistent HTTP Client (Keep-Alive Pooling)**: Menggunakan satu instance `http.Client` berumur panjang pada aplikasi Flutter untuk menghilangkan jeda *TCP 3-way handshake* dan *TLS negotiation* berulang, mencegah *socket exhaustion* saat banyak pengguna aktif.
2. **Multi-tier Caching**:
   * *Client-side*: Caching data armada dan pengguna di memori dengan durasi kadaluwarsa (TTL 60 detik) dan pembatalan otomatis (*auto-invalidation*) seketika setelah operasi buat/ubah/hapus usulan.
   * *Server-side*: Query katalog kendaraan dilindungi oleh `Cache::remember` dengan pembersihan otomatis via `Cache::forget` saat terjadi pembaruan armada.
3. **Lifecycle-Aware Polling**: Pemantauan data berkala secara cerdas dijeda ketika aplikasi diminimalkan ke latar belakang (*paused/inactive*) dan langsung disegarkan saat aplikasi kembali aktif (*resumed*), menghemat kuota dan baterai pengguna.
4. **Base64 to Storage Streaming**: Lampiran PDF dan gambar berukuran besar tidak lagi disimpan langsung ke kolom database melainkan didecode dan disimpan ke `public/storage/loan_documents/`, menjaga database tetap ramping dan mencegah kegagalan paket data MySQL.
5. **Database Indexing**: Indeks gabungan (*composite index*) pada tabel `loans`, `vehicles`, dan `app_notifications` untuk mempercepat pemfilteran riwayat dan pengecekan tabrakan jadwal hingga < 10ms.

---

## 👥 Diagram Kasus Penggunaan (Use Case Diagram)

```mermaid
flowchart LR
    subgraph AKTOR["🎭 Aktor Pengguna"]
        Pegawai(("👤 Pegawai<br/>(Pemohon)"))
        Kasubag(("🛡️ Kasubag Umum<br/>(Admin TU)"))
        SuperAdmin(("👑 Super Admin<br/>(Pusat)"))
    end

    subgraph SISTEM["💻 Sistem Informasi Pengelolaan Kendaraan (SIP-K / OVBS)"]
        UC_Auth(["🔐 Masuk Akun (Email / NIP)"])
        UC_Catalog(["🚗 Lihat Katalog & Ketersediaan Armada"])
        UC_News(["📰 Baca Berita & Pengumuman Dinas"])
        UC_Loan(["📝 Ajukan Permohonan Peminjaman"])
        UC_UploadDoc(["📎 Unggah Foto SIM & Surat Usulan PDF"])
        UC_Notif(["🔔 Terima Notifikasi Real-time (Sesuai Role)"])
        UC_PrintND(["📄 Pratinjau & Cetak Dokumen / Nota Dinas"])
        UC_Return(["🔄 Pengembalian Armada & Kunci ke Pool"])
        UC_Profile(["👤 Kelola Profil & Hubungi Helpdesk WA"])

        UC_Verify(["📋 Verifikasi Dokumen & Pengecekan Jadwal"])
        UC_Approve(["✅ Setujui & Terbitkan SPK Otomatis"])
        UC_Reject(["❌ Tolak Usulan dengan Catatan Alasan"])
        UC_Calendar(["📅 Pantau Kalender Jadwal Operasional"])
        UC_AssetStatus(["🔧 Kelola Status Kesiapan Armada"])

        UC_ImportUser(["📥 Import Pengguna Massal via File Excel"])
        UC_ManageUser(["👥 Kelola Data Akun Pengguna"])
        UC_ManageVehicle(["🚘 Kelola Data Master Armada"])
        UC_ManageNews(["📰 Kelola Informasi Berita Kedinasan"])
        UC_Analytics(["📊 Dashboard Statistik & Ekspor Laporan"])
    end

    %% Hubungan Pegawai (Pemohon)
    Pegawai --- UC_Auth
    Pegawai --- UC_Catalog
    Pegawai --- UC_News
    Pegawai --- UC_Loan
    Pegawai --- UC_Notif
    Pegawai --- UC_PrintND
    Pegawai --- UC_Return
    Pegawai --- UC_Profile

    UC_Loan -.->|"<<meliputi>>"| UC_UploadDoc

    %% Hubungan Kasubag Umum (Admin TU)
    Kasubag --- UC_Auth
    Kasubag --- UC_Catalog
    Kasubag --- UC_News
    Kasubag --- UC_Verify
    Kasubag --- UC_Calendar
    Kasubag --- UC_AssetStatus
    Kasubag --- UC_Notif
    Kasubag --- UC_PrintND

    UC_Verify -.->|"<<meliputi>>"| UC_Approve
    UC_Verify -.->|"<<meliputi>>"| UC_Reject

    %% Hubungan Super Administrator
    SuperAdmin --- UC_Auth
    SuperAdmin --- UC_ImportUser
    SuperAdmin --- UC_ManageUser
    SuperAdmin --- UC_ManageVehicle
    SuperAdmin --- UC_ManageNews
    SuperAdmin --- UC_Analytics
    SuperAdmin --- UC_Verify
    SuperAdmin --- UC_Calendar

    classDef actor fill:#1E293B,stroke:#64748B,stroke-width:2px,color:#fff;
    classDef usecase fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef includeUC fill:#0F766E,stroke:#14B8A6,stroke-width:1.5px,color:#fff;

    class Pegawai,Kasubag,SuperAdmin actor;
    class UC_Auth,UC_Catalog,UC_News,UC_Loan,UC_Notif,UC_PrintND,UC_Return,UC_Profile,UC_Verify,UC_Calendar,UC_AssetStatus,UC_ImportUser,UC_ManageUser,UC_ManageVehicle,UC_ManageNews,UC_Analytics usecase;
    class UC_UploadDoc,UC_Approve,UC_Reject includeUC;
```

### 📊 Matriks Hak Akses Pengguna

| No | Modul & Fungsionalitas (*Feature*) | Pegawai (Pemohon) | Kasubag Umum (Admin TU) | Super Administrator |
|:---:|---|:---:|:---:|:---:|
| 1 | **Autentikasi Akun (Email / NIP)** | ✅ | ✅ | ✅ |
| 2 | **Katalog Armada & Ketersediaan** | ✅ | ✅ | ✅ |
| 3 | **Baca Berita & Pengumuman Dinas** | ✅ | ✅ | ✅ |
| 4 | **Pengajuan Peminjaman & Unggah SIM/PDF** | ✅ | ❌ | ❌ |
| 5 | **Notifikasi Real-time Terpersonalisasi** | ✅ *(Permohonan Sendiri)* | ✅ *(Semua Usulan Masuk)* | ✅ *(Semua Aktivitas)* |
| 6 | **Pratinjau PDF Asli & Cetak Nota Dinas** | ✅ | ✅ | ✅ |
| 7 | **Pengembalian Armada & Selesai** | ✅ | ✅ | ✅ |
| 8 | **Verifikasi Usulan & Persetujuan/Penolakan SPK** | ❌ | ✅ | ✅ |
| 9 | **Kalender Jadwal Operasional Seluruh Armada** | ❌ | ✅ | ✅ |
| 10 | **Pembaruan Status Kendaraan (Tersedia/Servis)** | ❌ | ✅ | ✅ |
| 11 | **Import Pengguna Massal via File Excel (.xlsx)** | ❌ | ❌ | ✅ |
| 12 | **Manajemen Data Pengguna (CRUD Akun)** | ❌ | ❌ | ✅ |
| 13 | **Manajemen Master Data Armada (CRUD Kendaraan)** | ❌ | ❌ | ✅ |
| 14 | **Manajemen Berita & Informasi Kedinasan** | ❌ | ❌ | ✅ |
| 15 | **Dashboard Analitik & Ekspor Laporan Bulanan** | ❌ | ❌ | ✅ |

---

## ⚡ Diagram Aktivitas (Activity Diagram)

Diagram Aktivitas berikut memodelkan alur kerja (*business workflow*) dan koordinasi lintas entitas menggunakan pembagian jalur kerja (*swimlanes*) antara **Pegawai (Pemohon)**, **Sistem SIP-K / REST API Backend**, dan **Kasubag Umum / Admin TU (Verifikator)**.

### 1. Siklus Pengajuan & Verifikasi Pinjaman Kendaraan Dinas

```mermaid
flowchart TD
    subgraph LANE_PEGAWAI["👤 Swimlane: Pegawai (Pemohon)"]
        node_start1((●))
        act_p1["Pilih Armada dari Katalog"]
        act_p2["Isi Formulir Rincian & Jadwal Dinas"]
        act_p3["Unggah Berkas SIM & Dokumen Usulan (PDF)"]
        act_p4["Kirim Usulan Peminjaman"]
        act_p5["Terima Push Notification Status Usulan"]
        dec_p1{Status Usulan?}
        act_p6["Buka & Unduh Lembar Nota Dinas / SPK"]
        act_p7["Ambil Kunci Kontak & STNK di Pool"]
        act_p8["Pelaksanaan Perjalanan Dinas Operasional"]
        node_end_reject(((◉)))
    end

    subgraph LANE_SISTEM["💻 Swimlane: Sistem SIP-K / REST API"]
        act_s1["Validasi Ketersediaan Armada & Benturan Jadwal"]
        dec_s1{Validasi Berhasil?}
        act_s2["Tolak Input & Tampilkan Pesan Benturan"]
        act_s3["Simpan Usulan (Status: Menunggu) & Decode Dokumen"]
        act_s4["Kirim Push Notification FCM ke Kasubag Umum"]
        act_s5["Simpan Alasan Penolakan (Status: Ditolak)"]
        act_s6["Generate Nomor SPK Otomatis & Kunci Status Armada"]
        act_s7["Kirim Notifikasi Real-time ke Ponsel Pemohon"]
    end

    subgraph LANE_ADMIN["🛡️ Swimlane: Kasubag Umum / Admin TU"]
        act_a1["Buka Antrean Verifikasi Usulan Baru"]
        act_a2["Pemeriksaan Berkas: Foto SIM, Pratinjau PDF, & Urgensi"]
        dec_a1{Keputusan Verifikasi?}
        act_a3["Input Catatan Resmi Alasan Penolakan"]
        act_a4["Konfirmasi Persetujuan Usulan"]
        act_a5["Serah Terima Fisik Kunci Kontak & STNK"]
    end

    %% Hubungan Alur Pengajuan
    node_start1 --> act_p1
    act_p1 --> act_p2
    act_p2 --> act_p3
    act_p3 --> act_p4
    act_p4 --> act_s1

    act_s1 --> dec_s1
    dec_s1 -- "Jadwal Bentrok" --> act_s2
    act_s2 --> act_p2
    dec_s1 -- "Valid" --> act_s3

    act_s3 --> act_s4
    act_s4 --> act_a1
    act_a1 --> act_a2
    act_a2 --> dec_a1

    %% Keputusan Kasubag
    dec_a1 -- "Tolak" --> act_a3
    act_a3 --> act_s5
    act_s5 --> act_s7

    dec_a1 -- "Setujui" --> act_a4
    act_a4 --> act_s6
    act_s6 --> act_s7

    act_s7 --> act_p5
    act_p5 --> dec_p1

    dec_p1 -- "Ditolak" --> node_end_reject
    dec_p1 -- "Disetujui" --> act_p6

    act_p6 --> act_a5
    act_a5 --> act_p7
    act_p7 --> act_p8

    classDef startNode fill:#0284C7,stroke:#0369A1,stroke-width:2px,color:#fff;
    classDef endNode fill:#475569,stroke:#0F172A,stroke-width:2px,color:#fff;
    classDef activity fill:#1E293B,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef decision fill:#78350F,stroke:#F59E0B,stroke-width:1.5px,color:#fff;
    classDef system fill:#064E3B,stroke:#10B981,stroke-width:1.5px,color:#fff;

    class node_start1 startNode;
    class node_end_reject endNode;
    class act_p1,act_p2,act_p3,act_p4,act_p5,act_p6,act_p7,act_p8,act_a1,act_a2,act_a3,act_a4,act_a5 activity;
    class dec_p1,dec_s1,dec_a1 decision;
    class act_s1,act_s2,act_s3,act_s4,act_s5,act_s6,act_s7 system;
```

---

### 2. Siklus Pengembalian Kendaraan & Penyelesaian Tugas

```mermaid
flowchart TD
    subgraph LANE_P2["👤 Swimlane: Pegawai (Peminjam)"]
        node_start2((●))
        act_ret_p1["Tiba Kembali di Pool Kendaraan Dinas"]
        act_ret_p2["Serahkan Unit Kendaraan, Kunci Kontak & STNK ke Petugas"]
        act_ret_p3["Selesai"]
        node_end_ret(((◉)))
    end

    subgraph LANE_S2["💻 Swimlane: Sistem SIP-K / Backend"]
        act_ret_s1["Pencatatan Odometer & Kondisi Fisik oleh Petugas"]
        act_ret_s2["Perbarui Status Pinjaman: Selesai"]
        act_ret_s3["Perbarui Status Armada: Tersedia Kembali di Katalog"]
        act_ret_s4["Kirim Notifikasi Penyelesaian ke Pegawai & Admin"]
    end

    subgraph LANE_A2["🛡️ Swimlane: Kasubag TU / Petugas Pool"]
        act_ret_a1["Pemeriksaan Fisik Akhir & Odometer Kendaraan di Pool"]
        act_ret_a2["Penerimaan Kunci Kontak & Konfirmasi Selesai di Sistem"]
    end

    node_start2 --> act_ret_p1
    act_ret_p1 --> act_ret_p2
    act_ret_p2 --> act_ret_a1
    act_ret_a1 --> act_ret_a2
    act_ret_a2 --> act_ret_s1
    act_ret_s1 --> act_ret_s2
    act_ret_s2 --> act_ret_s3
    act_ret_s3 --> act_ret_s4
    act_ret_s4 --> act_ret_p3
    act_ret_p3 --> node_end_ret

    classDef startNode fill:#0284C7,stroke:#0369A1,stroke-width:2px,color:#fff;
    classDef endNode fill:#475569,stroke:#0F172A,stroke-width:2px,color:#fff;
    classDef activity fill:#1E293B,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef system fill:#064E3B,stroke:#10B981,stroke-width:1.5px,color:#fff;

    class node_start2 startNode;
    class node_end_ret endNode;
    class act_ret_p1,act_ret_p2,act_ret_p3,act_ret_a1,act_ret_a2 activity;
    class act_ret_s1,act_ret_s2,act_ret_s3,act_ret_s4 system;
```

---

## 📊 Diagram Aliran Data (Data Flow Diagram - DFD)

Diagram Aliran Data (*Data Flow Diagram*) berikut memodelkan bagaimana informasi dan berkas mengalir masuk, diproses oleh fungsi-fungsi sistem, disimpan ke dalam penyimpanan data (*data store*), dan didistribusikan ke entitas eksternal di lingkungan **SIP-K Jatim / OVBS**.

---

### 1. DFD Level 0 (Diagram Konteks / Context Diagram)

Diagram Konteks memodelkan keseluruhan sistem **SIP-K** sebagai satu proses tunggal (*Proses 0*) serta memetakan batasan sistem dengan seluruh entitas eksternal (*external entities / terminators*) yang berinteraksi dengannya:

```mermaid
flowchart TD
    subgraph TERMINATORS["🎭 Entitas Eksternal (Terminators)"]
        E1["👤 Pegawai<br/>(Pemohon Dinas)"]
        E2["🛡️ Kasubag Umum<br/>(Admin TU / Verifikator)"]
        E3["👑 Super Administrator<br/>(Pengelola Sistem)"]
        E4["☁️ Firebase Cloud<br/>Messaging (FCM)"]
    end

    P0(("🚗 0.0<br/>SISTEM INFORMASI PENGELOLAAN<br/>KENDARAAN DINAS (SIP-K / OVBS)"))

    %% Aliran Pegawai -> Sistem
    E1 -->|"1. Kredensial Login (NIP/Email & Sandi)<br/>2. Formulir Usulan (Tujuan, Tanggal, Urgensi)<br/>3. Berkas Lampiran (Foto SIM & Dokumen PDF)<br/>4. Laporan Pengembalian (KM Akhir, BBM, Fisik)"| P0

    %% Aliran Sistem -> Pegawai
    P0 -->|"1. Token Sesi Login & Profil Pengguna<br/>2. Data Katalog & Ketersediaan Armada<br/>3. Berita & Pengumuman Dinas Terkini<br/>4. Notifikasi Status Usulan (Approved/Rejected)<br/>5. Dokumen Lembar Nota Dinas & SPK (PDF)"| E1

    %% Aliran Kasubag Umum -> Sistem
    E2 -->|"1. Kredensial Login Kasubag<br/>2. Keputusan Verifikasi (Setujui / Tolak + Alasan)<br/>3. Pembaruan Status Kesiapan Armada (Servis/Ready)<br/>4. Konfirmasi Serah Terima Fisik Kunci & STNK"| P0

    %% Aliran Sistem -> Kasubag Umum
    P0 -->|"1. Notifikasi Usulan Peminjaman Baru Masuk<br/>2. Berkas Usulan (Pratinjau SIM & Dokumen PDF Asli)<br/>3. Kalender Jadwal Operasional Armada Seluruh Unit<br/>4. Notifikasi Pelaporan Pengembalian Armada"| E2

    %% Aliran Super Admin -> Sistem
    E3 -->|"1. Kredensial Login Super Admin<br/>2. Berkas Excel (.xlsx) Import Pengguna Massal<br/>3. Master Data Kendaraan Baru & Perubahan Unit<br/>4. Konten Berita & Pengumuman Dinas Baru"| P0

    %% Aliran Sistem -> Super Admin
    P0 -->|"1. Laporan Rekapitulasi & Statistik Penggunaan<br/>2. Log Hasil Import Pengguna Excel<br/>3. Master Data Seluruh Pengguna & Kendaraan"| E3

    %% Integrasi FCM
    P0 -->|"Payload Notifikasi Push (Title, Body, Target FCM Token)"| E4
    E4 -->|"Status Pengiriman Push Notification ke Perangkat"| P0

    classDef entity fill:#1E293B,stroke:#64748B,stroke-width:2px,color:#fff;
    classDef process fill:#1E3A8A,stroke:#3B82F6,stroke-width:2.5px,color:#fff;
    classDef external fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#fff;

    class E1,E2,E3 entity;
    class E4 external;
    class P0 process;
```

---

### 2. DFD Level 1 (Diagram Dekomposisi Proses Utama)

DFD Level 1 mendekomposisi *Proses 0* menjadi 7 subsistem/proses utama serta memetakan interaksinya dengan 6 penyimpanan data (*data stores*):

```mermaid
flowchart TD
    %% Entitas Eksternal
    E1["👤 Pegawai (Pemohon)"]
    E2["🛡️ Kasubag Umum (Admin TU)"]
    E3["👑 Super Administrator"]
    E4["☁️ Firebase FCM"]

    %% Data Stores
    subgraph DATA_STORES["🗄️ Penyimpanan Data (Data Stores)"]
        D1[("D1: USERS")]
        D2[("D2: VEHICLES")]
        D3[("D3: LOANS")]
        D4[("D4: APP_NOTIFICATIONS")]
        D5[("D5: PERSONAL_ACCESS_TOKENS")]
        D6[("D6: NEWS")]
    end

    %% Proses-Proses Utama
    P1(("1.0<br/>Manajemen Autentikasi<br/>& Pengguna"))
    P2(("2.0<br/>Pengelolaan Master<br/>Armada Kendaraan"))
    P3(("3.0<br/>Pengajuan Usulan<br/>Peminjaman Dinas"))
    P4(("4.0<br/>Verifikasi Usulan &<br/>Penerbitan SPK"))
    P5(("5.0<br/>Penyelesaian &<br/>Pengembalian Armada"))
    P6(("6.0<br/>Publikasi Berita &<br/>Pengumuman Dinas"))
    P7(("7.0<br/>Layanan Notifikasi<br/>& Sinkronisasi Push"))

    %% Aliran Proses 1.0 (Autentikasi & Akun)
    E1 -->|"Kredensial Login"| P1
    E2 -->|"Kredensial Login"| P1
    E3 -->|"Kredensial / File Excel Pegawai"| P1
    P1 -->|"Validasi Data Akun"| D1
    D1 -->|"Data Profil Pegawai"| P1
    P1 -->|"Simpan Sesi Token"| D5
    P1 -->|"Token Sesi & Data Profil"| E1
    P1 -->|"Log Hasil Import Akun"| E3

    %% Aliran Proses 2.0 (Master Armada)
    E3 -->|"Input / Ubah Data Unit Kendaraan"| P2
    E2 -->|"Ubah Status Servis / Perbaikan"| P2
    P2 -->|"Simpan / Perbarui Master Armada"| D2
    D2 -->|"Data Katalog Kendaraan"| P2
    P2 -->|"Informasi Katalog & Status Armada"| E1
    P2 -->|"Informasi Kesiapan Armada"| E2

    %% Aliran Proses 3.0 (Pengajuan Peminjaman)
    E1 -->|"Formulir Usulan, Jadwal, SIM & Dokumen PDF"| P3
    P3 -->|"Cek Jadwal Bebas-Benturan"| D3
    P3 -->|"Cek Ketersediaan Unit"| D2
    P3 -->|"Simpan Usulan Baru (Status: Menunggu)"| D3
    P3 -->|"Pemicu Notifikasi Pengajuan Baru"| P7

    %% Aliran Proses 4.0 (Verifikasi & SPK)
    D3 -->|"Data Berkas Usulan & Pratinjau PDF"| P4
    P4 -->|"Daftar Permohonan Menunggu Verifikasi"| E2
    E2 -->|"Keputusan (Disetujui / Ditolak + Catatan)"| P4
    P4 -->|"Update Status (Disetujui/Ditolak) & No. SPK"| D3
    P4 -->|"Kunci Status Armada: Digunakan"| D2
    P4 -->|"Pemicu Notifikasi Hasil Verifikasi"| P7
    P4 -->|"Lembar Nota Dinas & SPK Cetak"| E1

    %% Aliran Proses 5.0 (Pengembalian Armada)
    E1 -->|"Serah Terima Unit Fisik & Kunci Kontak"| P5
    P5 -->|"Update Status Selesai & Data Pengembalian"| D3
    P5 -->|"Kembalikan Status Armada: Tersedia"| D2
    P5 -->|"Pemicu Notifikasi Pengembalian Selesai"| P7
    P5 -->|"Konfirmasi Serah Terima Fisik oleh Petugas"| E2

    %% Aliran Proses 6.0 (Berita Kedinasan)
    E3 -->|"Konten Berita, Foto & Pengumuman"| P6
    P6 -->|"Simpan Konten Berita"| D6
    D6 -->|"Ambil Daftar Berita Aktif"| P6
    P6 -->|"Informasi Berita & Pengumuman"| E1

    %% Aliran Proses 7.0 (Notifikasi & Push)
    P7 -->|"Simpan Log Notifikasi In-App"| D4
    D4 -->|"Daftar Notifikasi Pengguna"| E1
    D4 -->|"Daftar Notifikasi Verifikator"| E2
    P7 -->|"Dispatch Push Payload FCM"| E4

    classDef entity fill:#1E293B,stroke:#64748B,stroke-width:2px,color:#fff;
    classDef process fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef store fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#fff;

    class E1,E2,E3,E4 entity;
    class P1,P2,P3,P4,P5,P6,P7 process;
    class D1,D2,D3,D4,D5,D6 store;
```

---

### 3. DFD Level 2 (Dekomposisi Rinci Sub-Proses Kritis)

Untuk menjamin kedalaman analisis teknis, sub-proses operasional inti (**Proses 3.0: Pengajuan Usulan** dan **Proses 4.0: Verifikasi & Penerbitan SPK**) didekomposisi lebih lanjut ke Level 2:

#### A. DFD Level 2 — Proses 3.0 (Siklus Pengajuan Usulan Peminjaman)

```mermaid
flowchart TD
    E1["👤 Pegawai (Pemohon)"]
    D2[("D2: VEHICLES")]
    D3[("D3: LOANS")]
    D4[("D4: APP_NOTIFICATIONS")]

    P31(("3.1<br/>Pengecekan Ketersediaan<br/>& Tabrakan Jadwal"))
    P32(("3.2<br/>Validasi Input Rincian<br/>Tugas Kedinasan"))
    P33(("3.3<br/>Pemrosesan & Penyimpanan<br/>Berkas SIM & Dokumen PDF"))
    P34(("3.4<br/>Pencatatan Record Usulan<br/>(Status: Menunggu)"))
    P35(("3.5<br/>Penerbitan Notifikasi<br/>Usulan Baru Masuk"))

    %% Alur Kerja Rinci
    E1 -->|"1. Pilih Unit & Rentang Tanggal Pinjam"| P31
    P31 -->|"Query Jadwal Armada Terpakai"| D3
    D3 -->|"Status Jadwal pada Rentang Tanggal"| P31
    P31 -->|"Query Kondisi Armada"| D2
    D2 -->|"Status Kesiapan Unit (Tersedia/Servis)"| P31

    P31 -->|"Armada Lolos Validasi Jadwal"| P32
    E1 -->|"2. Input Kota Tujuan, Alamat & Urgensi Tugas"| P32

    P32 -->|"Data Rincian Terverifikasi"| P33
    E1 -->|"3. Unggah Berkas Base64 (Foto SIM & Dokumen PDF)"| P33
    P33 -->|"Simpan Berkas Fisik ke Storage: public/storage/loan_documents/"| P33

    P33 -->|"Path URL Dokumen Tersimpan"| P34
    P34 -->|"Tulis Data Usulan Baru (REQ-...)"| D3

    P34 -->|"Pemicu Notifikasi Verifikator"| P35
    P35 -->|"Tulis Notifikasi Pengajuan Baru (user_id = NULL)"| D4
    P35 -->|"Pesan Konfirmasi Pengajuan Sukses Dikirim"| E1

    classDef entity fill:#1E293B,stroke:#64748B,stroke-width:2px,color:#fff;
    classDef process fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef store fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#fff;

    class E1 entity;
    class P31,P32,P33,P34,P35 process;
    class D2,D3,D4 store;
```

#### B. DFD Level 2 — Proses 4.0 (Siklus Verifikasi, Persetujuan & Penerbitan SPK)

```mermaid
flowchart TD
    E1["👤 Pegawai (Pemohon)"]
    E2["🛡️ Kasubag Umum (Admin TU)"]
    D2[("D2: VEHICLES")]
    D3[("D3: LOANS")]
    D4[("D4: APP_NOTIFICATIONS")]

    P41(("4.1<br/>Pemeriksaan Berkas &<br/>Pratinjau Dokumen PDF"))
    P42(("4.2<br/>Pemrosesan Penolakan<br/>Usulan Dinas"))
    P43(("4.3<br/>Pemrosesan Persetujuan &<br/>Penomoran SPK Otomatis"))
    P44(("4.4<br/>Pembaruan Kunci Status<br/>Armada Kendaraan"))
    P45(("4.5<br/>Penerbitan Lembar<br/>Nota Dinas & SPK Cetak"))
    P46(("4.6<br/>Dispatch Notifikasi Hasil<br/>Verifikasi ke Pemohon"))

    %% Alur Kerja Rinci
    D3 -->|"Baca Usulan Berstatus 'Menunggu'"| P41
    P41 -->|"Tampilkan Pratinjau SIM & Dokumen Asli PDF"| E2

    %% Jalur Penolakan
    E2 -->|"Keputusan: Tolak + Catatan Alasan"| P42
    P42 -->|"Update Status: 'ditolak' & Alasan Penolakan"| D3
    P42 -->|"Pemicu Notifikasi Penolakan"| P46

    %% Jalur Persetujuan
    E2 -->|"Keputusan: Setujui Usulan"| P43
    P43 -->|"Generate Nomor SPK (SPK-YYYYMMDD-XXX)"| P43
    P43 -->|"Update Status: 'disetujui' & Nomor SPK"| D3

    P43 -->|"Sinyal Kunci Armada"| P44
    P44 -->|"Ubah Status Unit: 'digunakan'"| D2

    P43 -->|"Data Persetujuan Lengkap"| P45
    P45 -->|"Generate Format Cetak Nota Dinas Standar Dinsos"| E1
    P45 -->|"Arsip Lembar SPK Cetak"| E2

    P43 -->|"Pemicu Notifikasi Persetujuan"| P46
    P46 -->|"Tulis Notifikasi Personalisasi (user_id Pemohon)"| D4
    P46 -->|"Kirim Notifikasi Push ke Smartphone Pegawai"| E1

    classDef entity fill:#1E293B,stroke:#64748B,stroke-width:2px,color:#fff;
    classDef process fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#fff;
    classDef store fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#fff;

    class E1,E2 entity;
    class P41,P42,P43,P44,P45,P46 process;
    class D2,D3,D4 store;
```

---

## 🔄 Diagram Alur Sistem (Flowchart Operasional)

```mermaid
flowchart TD
    subgraph PEMOHON["👤 1. Tahap Pegawai (Pemohon)"]
        A([Mulai]) --> B[Masuk Akun SIP-K]
        B --> C[Pilih Armada pada Katalog]
        C --> D{Ketersediaan Armada?}
        D -- "Sedang Digunakan / Servis" --> C
        D -- "Tersedia" --> E[Isi Formulir Peminjaman & Tujuan Dinas]
        E --> F[Unggah Berkas SIM & Dokumen Usulan PDF]
        F --> G[Kirim Permohonan]
        G --> H[(Database: Status Menunggu)]
    end

    subgraph ADMIN["🛡️ 2. Tahap Verifikasi Kasubag Umum"]
        H --> I[Terima Notifikasi Usulan Baru]
        I --> J[Periksa Foto SIM, Pratinjau Dokumen PDF & Cek Jadwal]
        J --> K{Keputusan Kasubag?}
        K -- "Tolak Permohonan" --> L[Input Catatan Alasan Penolakan]
        L --> M[(Database: Status Ditolak)]
        K -- "Setujui Permohonan" --> N[Generate Nomor SPK Otomatis]
        N --> O[(Database: Status Disetujui)]
        O --> P[Kunci Status Armada: Digunakan]
    end

    subgraph PROSES["🚗 3. Tahap Pelaksanaan & Pengembalian Armada"]
        M --> Q[Notifikasi Penolakan Masuk ke Akun Pemohon]
        Q --> Z1([Selesai / Ajukan Alternatif])
        O --> R[Notifikasi Persetujuan Masuk ke Akun Pemohon]
        R --> S[Buka / Unduh Lembar Nota Dinas & SPK]
        S --> T[Serah Terima Kunci Kontak & STNK di Pool]
        T --> U[Pelaksanaan Perjalanan Dinas Kedinasan]
        U --> V[Kembali ke Pool & Buka Menu Lapor Pengembalian]
        V --> W[Input KM Akhir, Sisa BBM, dan Catatan Fisik]
        W --> X[(Database: Status Selesai / Terbit BAST)]
        X --> Y[Kembalikan Status Armada: Tersedia]
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

## 🗄️ Struktur Basis Data (ERD)

Skema relasi antar entitas basis data **`sip-k`** pada MySQL:

```mermaid
erDiagram
    USERS ||--o{ LOANS : "mengajukan_permohonan"
    VEHICLES ||--o{ LOANS : "dialokasikan_ke"
    USERS ||--o{ APP_NOTIFICATIONS : "menerima_notifikasi"
    USERS ||--o{ PERSONAL_ACCESS_TOKENS : "memiliki_sesi"
    NEWS {
        bigint id PK "Nomor Identifikasi Berita"
        string tag "Kategori Tag (PENGUMUMAN, dsb)"
        string title "Judul Berita Kedinasan"
        text desc "Uraian Isi Berita"
        string date "Tanggal Publikasi Berita"
        string image "Tautan Berkas Gambar Berita"
        string author "Nama Penulis / Administrator"
        boolean is_active "Status Keaktifan Publikasi"
        timestamp created_at "Waktu Terbit"
        timestamp updated_at "Waktu Pembaruan"
    }

    USERS {
        bigint id PK "Nomor Identifikasi Pengguna"
        string name "Nama Lengkap Pegawai"
        string nip UK "Nomor Induk Pegawai (NIP)"
        string email UK "Alamat Email Kedinasan"
        string password "Kata Sandi Terenkripsi (Bcrypt)"
        string role "Peran: pegawai | admin | superadmin"
        string position "Jabatan Kedinasan"
        string department "Sub Bagian / Bidang Dinas"
        string phone "Nomor Telepon / WhatsApp"
        string profile_image_url "Tautan Berkas Foto Profil"
        text fcm_token "Token Firebase Cloud Messaging"
        timestamp created_at "Waktu Akun Dibuat"
        timestamp updated_at "Waktu Akun Diperbarui"
    }

    VEHICLES {
        bigint id PK "Nomor Identifikasi Kendaraan"
        string name "Nama Unit Kendaraan"
        string brand "Merk / Pabrikan Kendaraan"
        string plate_number UK "Nomor Polisi Kendaraan Dinas"
        string color "Warna Kendaraan"
        string type "Jenis: mobil | motor"
        int capacity "Kapasitas Jumlah Penumpang"
        string transmission "Transmisi: Manual | Matic"
        int current_odometer "Catatan Kilometer Terakhir (KM)"
        int fuel_percent "Kapasitas Sisa Bahan Bakar (%)"
        string fuel_type "Jenis Bahan Bakar"
        string status "Status: tersedia | digunakan | perawatan"
        text condition_note "Catatan Kondisi Fisik & Mesin"
        string image_url "Tautan Berkas Foto Kendaraan"
        timestamp created_at "Waktu Data Masuk"
        timestamp updated_at "Waktu Data Diperbarui"
    }

    LOANS {
        string id PK "Nomor Registrasi Usulan (REQ-...)"
        bigint user_id FK "ID Pegawai Pemohon (Indexed)"
        string borrower_name "Nama Lengkap Peminjam"
        string department "Bidang Dinas Pemohon"
        string vehicle_id FK "ID Kendaraan yang Dipinjam (Indexed)"
        string vehicle_name "Nama Unit Kendaraan"
        string destination "Kota / Wilayah Tujuan Dinas"
        text destination_address "Alamat Lengkap Tujuan Dinas"
        text purpose_description "Urgensi dan Keperluan Tugas"
        date start_date "Tanggal Mulai Peminjaman (Indexed)"
        date end_date "Tanggal Selesai Peminjaman (Indexed)"
        string official_note_number "Nomor Surat Usulan / Dokumen"
        longtext sim_photo_path "Path URL / Dokumen SIM & Berkas"
        string status "Status: menunggu | disetujui | digunakan | selesai | ditolak (Indexed)"
        string spk_number "Nomor Surat Perintah Kerja (SPK)"
        text rejection_reason "Catatan Alasan Penolakan Kasubag"
        int return_odometer "Catatan Kilometer Akhir Pengembalian"
        string return_fuel "Sisa Bahan Bakar Saat Kembali"
        text return_notes "Catatan Fisik Pengembalian"
        datetime returned_at "Waktu Pengembalian Resmi (BAST)"
        datetime submitted_at "Waktu Pengajuan Usulan Dikirim"
        timestamp created_at "Waktu Catatan Dibuat"
        timestamp updated_at "Waktu Catatan Diperbarui"
    }

    APP_NOTIFICATIONS {
        bigint id PK "Nomor Identifikasi Notifikasi"
        bigint user_id FK "ID Pengguna Penerima (NULL = Kasubag) (Indexed)"
        string title "Judul Pemberitahuan Notifikasi"
        text message "Rincian Isi Pesan Notifikasi"
        string type "Kategori: pengajuan | persetujuan | penolakan | info"
        string reference_number "Nomor Referensi (REQ / SPK)"
        boolean is_read "Status Keterbacaan Pesan (Indexed)"
        timestamp created_at "Waktu Notifikasi Terbit"
        timestamp updated_at "Waktu Notifikasi Diperbarui"
    }

    PERSONAL_ACCESS_TOKENS {
        bigint id PK "Nomor Identifikasi Token"
        string tokenable_type "Tipe Entitas Model Terkait"
        bigint tokenable_id FK "ID Pengguna Pemilik Token"
        string name "Nama Perangkat / Sesi Pengguna"
        string token UK "Kunci Akses Rahasia Token"
        text abilities "Hak Akses Token"
        timestamp last_used_at "Waktu Terakhir Digunakan"
        timestamp expires_at "Batas Kedaluwarsa Sesi"
        timestamp created_at "Waktu Token Diterbitkan"
        timestamp updated_at "Waktu Token Diperbarui"
    }
```

---

## 📁 Struktur Direktori Proyek

```bash
SIP-K/
├── android/                 # Konfigurasi native Android (Gradle, Manifest, Permissions)
├── assets/                  # Logo SIP-K, gambar kendaraan dinas, & aset ikon
├── backend/                 # Backend RESTful API berbasis Laravel 11
│   ├── app/Http/Controllers # Controller: Auth, Loan, Vehicle, Notification, User, News
│   ├── app/Models/          # Model Eloquent: User, Loan, Vehicle, AppNotification, News
│   ├── database/migrations/ # Skema migrasi tabel & indeks performa MySQL
│   ├── database/seeders/    # Seeder data pengguna, kendaraan, & berita awal
│   ├── public/storage/      # Direktori publik penyimpanan berkas SIM & PDF
│   └── routes/api.php       # Definisi endpoint REST API
├── lib/                     # Aplikasi Flutter Multiplatform
│   ├── models/              # Model data Dart (Kendaraan, Pinjaman, Notifikasi, Pengguna, Berita)
│   ├── screens/             # Layanan layar tampilan UI:
│   │   ├── home_screen.dart          # Dashboard utama, kalender, berita, & navigasi
│   │   ├── loan_form_screen.dart     # Formulir pengajuan permohonan dinas
│   │   ├── loan_history_screen.dart  # Riwayat peminjaman & pelaporan BAST
│   │   ├── admin_screen.dart         # Panel verifikasi usulan & manajemen armada
│   │   ├── user_management_screen.dart # Manajemen pengguna & import file Excel
│   │   ├── notification_screen.dart  # Pusat notifikasi terpersonalisasi
│   │   └── profile_screen.dart       # Profil akun & helpdesk WhatsApp
│   ├── services/            # Logika bisnis & integrasi:
│   │   ├── api_service.dart          # Klien HTTP persistent, caching, & pemanggilan API
│   │   ├── api_config.dart           # Konfigurasi endpoint URL & kontak helpdesk
│   │   ├── excel_import_service.dart # Parser berkas Excel .xlsx dengan deteksi peran
│   │   ├── firebase_service.dart     # Pengelola notifikasi push Firebase FCM
│   │   └── theme_service.dart        # Pengelola mode tema tampilan
│   └── widgets/             # Komponen UI interaktif (PDF Viewer Dialog, Zoom SIM, dsb)
├── sip-k-database.sql       # Cadangan skema basis data MySQL siap pakai
└── pubspec.yaml             # Konfigurasi dependensi dan pustaka Flutter
```

---

## 🚀 Panduan Instalasi & Deployment

### A. Pengujian & Pengembangan Lokal (Local Development)

#### 1. Menjalankan Backend Laravel
Pastikan PHP (>= 8.2) dan MySQL telah terpasang (Laragon / XAMPP):
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate

# Konfigurasi berkas .env untuk database:
# DB_DATABASE=sip-k
# DB_USERNAME=root
# DB_PASSWORD=

# Jalankan migrasi dan penghubung storage:
php artisan storage:link
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

#### 2. Menjalankan Aplikasi Flutter
```bash
# Unduh seluruh paket dependensi
flutter pub get

# Jalankan di Google Chrome (Web)
flutter run -d chrome

# Jalankan di Perangkat Android Fisik / Emulator
flutter run
```

---

### B. Deployment Server Produksi (Azure Cloud Virtual Machine)

Sistem telah berjalan pada server **Azure Cloud Virtual Machine (Ubuntu 22.04 LTS)** dengan alamat IP: `20.244.48.18`.

Langkah-langkah pembaruan (*deploy update*) di server produksi:

```bash
# 1. Masuk ke server melalui SSH
ssh dewa@20.244.48.18

# 2. Masuk ke direktori backend proyek
cd /var/www/Sip-k/backend

# 3. Ambil pembaruan kode terbaru dari GitHub
git pull origin main

# 4. Pasang/perbarui pustaka dependensi PHP
composer install --no-dev --optimize-autoloader

# 5. Jalankan migrasi basis data (termasuk indeks performa baru)
php artisan migrate --force

# 6. Pastikan symbolic link storage sudah aktif
php artisan storage:link

# 7. Bersihkan dan optimalkan cache produksi
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 8. Pastikan izin akses folder storage dan cache telah sesuai
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

> **Catatan:** Jika perintah `php artisan storage:link` menampilkan pesan `ERROR The [public/storage] link already exists`, artinya tautan simbolik sudah terpasang dan berfungsi dengan baik.

---

## 🔑 Akun Uji Coba Bawaan Sistem

| Peran / Hak Akses | Nama Pengguna | Akun Masuk (Email / NIP) | Kata Sandi | Wewenang Utama |
|---|---|---|---|---|
| **Pegawai (Pemohon)** | Alamsyah | `199503152020121002` | `password` | Pengajuan dinas, pantau status, pratinjau & cetak dokumen |
| **Kasubag Umum (Admin TU)** | Ahmad Dewantara, S.STP | `admin@dinsos.jatimprov.go.id` | `admin123` | Verifikasi berkas usulan, setujui / tolak permohonan SPK |
| **Super Administrator** | Super Admin SIP-K | `superadmin@dinsos.jatimprov.go.id` | `superadmin123` | Akses penuh, import Excel massal, manajemen armada & pengguna |

*Layanan Bantuan Akun:* **Helpdesk WhatsApp Admin SIP-K: [0856-0783-2173](https://wa.me/6285607832173)**

---

## 📄 Lisensi
Hak Cipta © 2026 **Pemerintah Provinsi Jawa Timur — Dinas Sosial**.  
Dikembangkan untuk mendukung digitalisasi, transparansi, dan efisiensi tata kelola aset kendaraan dinas operasional daerah.

---

## Support by :  
**DRD**  
**Telkom University Surabaya**  
*18 Agustus 2026 s.d. 15 Januari 2027*  

---
<p align="center">
  <sub>Sistem Informasi Pengelolaan Kendaraan Dinas Operasional (SIP-K / OVBS)<br/>Dinas Sosial Provinsi Jawa Timur</sub>
</p>
