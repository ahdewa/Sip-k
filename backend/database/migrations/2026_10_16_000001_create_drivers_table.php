<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('drivers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('nip')->nullable();
            $table->string('phone')->nullable();
            $table->string('sim_type')->default('SIM A'); // SIM A, SIM B1, SIM B1 Umum, SIM B2
            $table->string('sim_number')->nullable();
            $table->string('status')->default('siaga'); // siaga, bertugas, cuti, nonaktif
            $table->text('notes')->nullable(); // Spesialisasi penugasan / catatan
            $table->longText('photo_url')->nullable();
            $table->timestamps();
        });

        // Seed data driver default awal agar kompatibel dengan data yang sudah ada
        DB::table('drivers')->insert([
            [
                'name' => 'Pak Sugeng Riyadi',
                'nip' => '198204122010011005',
                'phone' => '081234567801',
                'sim_type' => 'SIM B1 Umum',
                'sim_number' => 'SIM-B1-82041201',
                'status' => 'siaga',
                'notes' => 'Driver Pool Utama • SIM B1 Umum • Siaga',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Pak Bambang Hermawan',
                'nip' => '198507202012011008',
                'phone' => '081234567802',
                'sim_type' => 'SIM A / B1',
                'sim_number' => 'SIM-AB1-85072002',
                'status' => 'siaga',
                'notes' => 'Driver Operasional UPT • SIM A/B1 • Siaga',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Pak Agus Prasetyo',
                'nip' => '198811052014021004',
                'phone' => '081234567803',
                'sim_type' => 'SIM B1',
                'sim_number' => 'SIM-B1-88110503',
                'status' => 'siaga',
                'notes' => 'Driver Reaksi Cepat Tagana • SIM B1 • Siaga',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Pak Joko Susilo',
                'nip' => '197903152008011002',
                'phone' => '081234567804',
                'sim_type' => 'SIM A',
                'sim_number' => 'SIM-A-79031504',
                'status' => 'siaga',
                'notes' => 'Driver Kedinasan Khusus Pimpinan • SIM A • Siaga',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Pak Eko Wahyudi',
                'nip' => '199009102016031006',
                'phone' => '081234567805',
                'sim_type' => 'SIM B1 Umum',
                'sim_number' => 'SIM-B1-90091005',
                'status' => 'siaga',
                'notes' => 'Driver Patwal & Logistik Bantuan • SIM B1 Umum • Siaga',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('drivers');
    }
};
