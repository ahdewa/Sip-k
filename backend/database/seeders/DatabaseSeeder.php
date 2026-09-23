<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Vehicle;
use App\Models\Loan;
use App\Models\AppNotification;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Akun Pengguna (Users)
        $pegawai = User::create([
            'name' => 'Rendy Cahyono Putra',
            'nip' => '19980512 202401 1 002',
            'email' => 'rendy@dinsos.jatimprov.go.id',
            'role' => 'pegawai',
            'position' => 'Staf Fungsional Perencana',
            'department' => 'Subbag Penyusunan Program & Anggaran',
            'phone' => '0812-3456-7890',
            'profile_image_url' => null,
            'password' => Hash::make('password123'),
        ]);

        $admin = User::create([
            'name' => 'Ahmad Dewantara, S.STP',
            'nip' => '19850315 201001 1 003',
            'email' => 'admin@dinsos.jatimprov.go.id',
            'role' => 'admin',
            'position' => 'Kasubag Tata Usaha & Rumah Tangga',
            'department' => 'Bagian Tata Usaha',
            'phone' => '0812-9876-5432',
            'profile_image_url' => null,
            'password' => Hash::make('admin123'),
        ]);

        $superadmin = User::create([
            'name' => 'Super Admin SIP-K',
            'nip' => '19800101 200501 1 001',
            'email' => 'superadmin@dinsos.jatimprov.go.id',
            'role' => 'superadmin',
            'position' => 'Administrator Utama Sistem & Aset',
            'department' => 'Subbag Umum & Kepegawaian',
            'phone' => '0811-2233-4455',
            'profile_image_url' => null,
            'password' => Hash::make('superadmin123'),
        ]);

        // 2. Data Kendaraan (Vehicles)
        $v1 = Vehicle::create([
            'id' => 1,
            'name' => 'Toyota Innova Reborn 2.4 G',
            'brand' => 'Toyota',
            'plate_number' => 'L 1120 DP',
            'color' => 'Hitam Metalik',
            'type' => 'mobil',
            'capacity' => 7,
            'transmission' => 'Automatic',
            'current_odometer' => 45200,
            'fuel_percent' => 100,
            'fuel_type' => 'Dexlite / Solar Subsidi',
            'condition_note' => 'Kondisi mesin sangat prima, AC dingin ganda, service rutin berkala di Auto2000.',
            'status' => 'tersedia',
            'image_url' => 'assets/images/logo_sipk.png',
            'gallery_images' => ['assets/images/logo_sipk.png'],
        ]);

        $v2 = Vehicle::create([
            'id' => 2,
            'name' => 'Toyota Avanza 1.3 Veloz',
            'brand' => 'Toyota',
            'plate_number' => 'L 1455 EP',
            'color' => 'Silver',
            'type' => 'mobil',
            'capacity' => 7,
            'transmission' => 'Manual',
            'current_odometer' => 62100,
            'fuel_percent' => 75,
            'fuel_type' => 'Pertalite / Pertamax',
            'condition_note' => 'Kondisi mesin terawat, body mulus, rem baru diservis, kelengkapan surat lengkap.',
            'status' => 'tersedia',
            'image_url' => 'assets/images/logo_sipk.png',
            'gallery_images' => ['assets/images/logo_sipk.png'],
        ]);

        $v3 = Vehicle::create([
            'id' => 3,
            'name' => 'Isuzu Elf Minibus Dinsos Jatim',
            'brand' => 'Isuzu',
            'plate_number' => 'L 7002 AP',
            'color' => 'Putih Kombinasi Biru',
            'type' => 'mobil',
            'capacity' => 16,
            'transmission' => 'Manual',
            'current_odometer' => 89400,
            'fuel_percent' => 50,
            'fuel_type' => 'Solar Subsidi / Dexlite',
            'condition_note' => 'Khusus penugasan rombongan satgas linjamsos & dropping logistik sosial.',
            'status' => 'digunakan',
            'image_url' => 'assets/images/logo_sipk.png',
            'gallery_images' => ['assets/images/logo_sipk.png'],
        ]);

        $v4 = Vehicle::create([
            'id' => 4,
            'name' => 'Honda Vario 160 CBS',
            'brand' => 'Honda',
            'plate_number' => 'L 3341 DS',
            'color' => 'Hitam Doff',
            'type' => 'motor',
            'capacity' => 2,
            'transmission' => 'Matic',
            'current_odometer' => 14200,
            'fuel_percent' => 100,
            'fuel_type' => 'Pertamax',
            'condition_note' => 'Unit responsif dan lincah, khusus kurir dokumen dan dinas dalam kota Surabaya.',
            'status' => 'tersedia',
            'image_url' => 'assets/images/logo_sipk.png',
            'gallery_images' => ['assets/images/logo_sipk.png'],
        ]);

        $v5 = Vehicle::create([
            'id' => 5,
            'name' => 'Yamaha NMAX 155 ABS',
            'brand' => 'Yamaha',
            'plate_number' => 'L 4910 OS',
            'color' => 'Abu-Abu Doff',
            'type' => 'motor',
            'capacity' => 2,
            'transmission' => 'Matic',
            'current_odometer' => 19800,
            'fuel_percent' => 80,
            'fuel_type' => 'Pertamax',
            'condition_note' => 'Kondisi ban depan belakang baru, rem ABS responsif, bagasi lega untuk jas hujan dan helm.',
            'status' => 'tersedia',
            'image_url' => 'assets/images/logo_sipk.png',
            'gallery_images' => ['assets/images/logo_sipk.png'],
        ]);

        $v6 = Vehicle::create([
            'id' => 6,
            'name' => 'Honda Supra X 125 Helm-in',
            'brand' => 'Honda',
            'plate_number' => 'L 2108 PS',
            'color' => 'Merah Hitam',
            'type' => 'motor',
            'capacity' => 2,
            'transmission' => 'Semi-Manual',
            'current_odometer' => 31500,
            'fuel_percent' => 90,
            'fuel_type' => 'Pertalite',
            'condition_note' => 'Sangat irit bahan bakar, cocok untuk tugas operasional kurir surat dinas harian.',
            'status' => 'tersedia',
            'image_url' => 'assets/images/logo_sipk.png',
            'gallery_images' => ['assets/images/logo_sipk.png'],
        ]);

        // 3. Data Peminjaman (Loans)
        Loan::create([
            'id' => 'REQ-2026-0902-001',
            'user_id' => $pegawai->id,
            'borrower_name' => 'Rendy Cahyono Putra',
            'department' => 'Subbag Penyusunan Program & Anggaran',
            'vehicle_id' => '1',
            'vehicle_name' => 'Toyota Innova Reborn 2.4 G',
            'destination' => 'Bakorwil III Malang & UPT Dinsos Lawang',
            'destination_address' => 'Jl. Raya Singosari No. 120, Malang',
            'purpose_description' => 'Koordinasi evaluasi program bantuan sosial kuartal 3 dan monitoring sarana prasarana.',
            'start_date' => Carbon::create(2026, 9, 3),
            'end_date' => Carbon::create(2026, 9, 5),
            'official_note_number' => '005/1422/107.4.1/2026',
            'status' => 'menunggu',
            'submitted_at' => Carbon::create(2026, 9, 2, 8, 30),
        ]);

        Loan::create([
            'id' => 'REQ-2026-0902-002',
            'user_id' => $pegawai->id,
            'borrower_name' => 'Dewi Sekar Arum, S.Sos',
            'department' => 'Bidang Penanganan Fakir Miskin (PFM)',
            'vehicle_id' => '4',
            'vehicle_name' => 'Honda Vario 160 CBS',
            'destination' => 'Bappeda Provinsi Jawa Timur',
            'destination_address' => 'Jl. Pahlawan No. 110, Surabaya',
            'purpose_description' => 'Rapat koordinasi verifikasi dan validasi data DTKS terpadu.',
            'start_date' => Carbon::create(2026, 9, 3),
            'end_date' => Carbon::create(2026, 9, 3),
            'official_note_number' => '005/1429/107.2.2/2026',
            'status' => 'menunggu',
            'submitted_at' => Carbon::create(2026, 9, 2, 9, 15),
        ]);

        Loan::create([
            'id' => 'REQ-2026-0831-010',
            'user_id' => $pegawai->id,
            'borrower_name' => 'Bambang Triyono, S.ST',
            'department' => 'Bidang Perlindungan & Jaminan Sosial (Linjamsos)',
            'vehicle_id' => '3',
            'vehicle_name' => 'Isuzu Elf Minibus Dinsos Jatim',
            'destination' => 'Penyaluran Bantuan Satgas Tagana Kab. Bojonegoro',
            'destination_address' => 'Kompleks Pemkab & Gudang Logistik Dinsos Bojonegoro',
            'purpose_description' => 'Dropping logistik darurat bencana dan logistik dapur umum satgas Tagana.',
            'start_date' => Carbon::create(2026, 9, 1),
            'end_date' => Carbon::create(2026, 9, 4),
            'official_note_number' => '005/1398/107.3/2026',
            'status' => 'digunakan',
            'submitted_at' => Carbon::create(2026, 8, 31, 10, 0),
            'spk_number' => 'ND-5512/DINSOS/2026',
        ]);

        Loan::create([
            'id' => 'REQ-2026-0901-008',
            'user_id' => $pegawai->id,
            'borrower_name' => 'Nurul Hidayati, M.Si',
            'department' => 'Bidang Rehabilitasi Sosial (Rehsos)',
            'vehicle_id' => '2',
            'vehicle_name' => 'Toyota Avanza 1.3 Veloz',
            'destination' => 'Monev UPT PRSPA Magetan & Ponorogo',
            'destination_address' => 'Jl. Pahlawan No. 45, Magetan',
            'purpose_description' => 'Monitoring dan evaluasi pembinaan klien rehabilitasi sosial anak.',
            'start_date' => Carbon::create(2026, 9, 1),
            'end_date' => Carbon::create(2026, 9, 3),
            'official_note_number' => '005/1405/107.1/2026',
            'status' => 'disetujui',
            'submitted_at' => Carbon::create(2026, 9, 1, 7, 45),
            'spk_number' => 'ND-5519/DINSOS/2026',
        ]);

        Loan::create([
            'id' => 'REQ-2026-0828-004',
            'user_id' => $pegawai->id,
            'borrower_name' => 'Agus Setiawan, A.Md',
            'department' => 'Subbag Keuangan & Aset',
            'vehicle_id' => '1',
            'vehicle_name' => 'Toyota Innova Reborn 2.4 G',
            'destination' => 'Badan Pengelola Keuangan dan Aset Daerah (BPKAD) Jatim',
            'destination_address' => 'Jl. Johar No. 17, Surabaya',
            'purpose_description' => 'Penyerahan SPJ dan rekonsiliasi data inventarisasi barang milik daerah.',
            'start_date' => Carbon::create(2026, 8, 28),
            'end_date' => Carbon::create(2026, 8, 29),
            'official_note_number' => '005/1350/107.4.2/2026',
            'status' => 'selesai',
            'submitted_at' => Carbon::create(2026, 8, 27, 14, 20),
            'spk_number' => 'ND-5490/DINSOS/2026',
            'return_odometer' => 45200,
            'return_fuel' => 'Full (100%)',
            'return_notes' => 'Kondisi kendaraan bersih, toolkit lengkap, tidak ada kendala mesin.',
            'returned_at' => Carbon::create(2026, 8, 29, 16, 0),
        ]);

        Loan::create([
            'id' => 'REQ-2026-0825-002',
            'user_id' => $pegawai->id,
            'borrower_name' => 'Irfan Maulana, S.Kom',
            'department' => 'Seksi Data & Informasi Kesejahteraan Sosial',
            'vehicle_id' => '5',
            'vehicle_name' => 'Yamaha NMAX 155 ABS',
            'destination' => 'Diskominfo Pemprov Jawa Timur',
            'destination_address' => 'Jl. A. Yani No. 242-244, Surabaya',
            'purpose_description' => 'Koordinasi integrasi server aplikasi SIP-K ke data center Diskominfo Jatim.',
            'start_date' => Carbon::create(2026, 8, 25),
            'end_date' => Carbon::create(2026, 8, 25),
            'official_note_number' => '005/1310/107.5/2026',
            'status' => 'selesai',
            'submitted_at' => Carbon::create(2026, 8, 24, 11, 0),
            'spk_number' => 'ND-5472/DINSOS/2026',
            'return_odometer' => 19800,
            'return_fuel' => '3/4 (75%)',
            'return_notes' => 'Lengkap dengan jas hujan dinas dan 2 buah helm.',
            'returned_at' => Carbon::create(2026, 8, 25, 17, 30),
        ]);

        // 4. Data Notifikasi Awal (AppNotification)
        AppNotification::create([
            'user_id' => $pegawai->id,
            'title' => 'Pengajuan Disetujui (Nota Dinas Terbit)',
            'message' => 'Permohonan armada Toyota Avanza 1.3 Veloz telah disetujui. Softfile Nota Dinas resmi telah tersedia untuk dicetak dan diserahkan ke Kasubag TU.',
            'reference_number' => 'ND-5519/DINSOS/2026',
            'type' => 'approved',
            'is_read' => false,
        ]);

        AppNotification::create([
            'user_id' => $pegawai->id,
            'title' => 'Permohonan Berhasil Dikirim',
            'message' => 'Pengajuan peminjaman unit Toyota Innova Reborn 2.4 G (REQ-2026-0902-001) telah berhasil diajukan dan sedang menunggu verifikasi Kasubag.',
            'reference_number' => 'REQ-2026-0902-001',
            'type' => 'submitted',
            'is_read' => true,
        ]);

        AppNotification::create([
            'user_id' => $pegawai->id,
            'title' => 'Pengembalian Selesai (BAST Terbit)',
            'message' => 'Unit Toyota Innova Reborn 2.4 G telah selesai diperiksa oleh tim aset dan dikembalikan ke pool kendaraan dinas. Terima kasih.',
            'reference_number' => 'BAST-2026-0829-01',
            'type' => 'returned',
            'is_read' => true,
        ]);
    }
}
