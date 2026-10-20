<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('vehicles', function (Blueprint $table) {
            if (!Schema::hasColumn('vehicles', 'chassis_number')) {
                $table->string('chassis_number', 100)->nullable()->after('plate_number');
            }
            if (!Schema::hasColumn('vehicles', 'engine_number')) {
                $table->string('engine_number', 100)->nullable()->after('chassis_number');
            }
        });
    }

    public function down(): void
    {
        Schema::table('vehicles', function (Blueprint $table) {
            $table->dropColumn(['chassis_number', 'engine_number']);
        });
    }
};
