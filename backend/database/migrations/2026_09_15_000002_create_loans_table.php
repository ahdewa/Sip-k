<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loans', function (Blueprint $table) {
            $table->string('id')->primary(); // Contoh: REQ-2026-0902-001
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('borrower_name');
            $table->string('department');
            $table->string('vehicle_id');
            $table->string('vehicle_name');
            $table->string('destination');
            $table->text('destination_address')->nullable();
            $table->text('purpose_description')->nullable();
            $table->dateTime('start_date');
            $table->dateTime('end_date');
            $table->string('official_note_number')->default('-');
            $table->string('sim_photo_path')->nullable();
            $table->string('status')->default('menunggu'); // menunggu, disetujui, digunakan, ditolak, dibatalkan, selesai
            $table->dateTime('submitted_at');
            $table->string('spk_number')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->integer('return_odometer')->nullable();
            $table->string('return_fuel')->nullable();
            $table->text('return_notes')->nullable();
            $table->dateTime('returned_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loans');
    }
};
