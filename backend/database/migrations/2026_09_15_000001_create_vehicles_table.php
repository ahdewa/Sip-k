<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('brand');
            $table->string('plate_number');
            $table->string('color');
            $table->string('type')->default('mobil'); // mobil, motor
            $table->integer('capacity')->default(4);
            $table->string('transmission')->default('Manual');
            $table->integer('current_odometer')->default(0);
            $table->integer('fuel_percent')->default(100);
            $table->string('fuel_type')->default('Bensin');
            $table->text('condition_note')->nullable();
            $table->string('status')->default('tersedia'); // tersedia, digunakan, perawatan
            $table->string('image_url')->nullable();
            $table->json('gallery_images')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehicles');
    }
};
