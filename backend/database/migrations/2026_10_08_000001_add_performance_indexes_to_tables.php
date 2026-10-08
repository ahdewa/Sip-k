<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->index('status');
            $table->index('submitted_at');
            $table->index('vehicle_id');
            $table->index('start_date');
            $table->index('end_date');
            $table->index(['user_id', 'submitted_at']);
            $table->index(['status', 'submitted_at']);
        });

        Schema::table('app_notifications', function (Blueprint $table) {
            $table->index('is_read');
            $table->index('type');
            $table->index('created_at');
            $table->index(['user_id', 'created_at']);
            $table->index(['is_read', 'created_at']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->index('role');
        });

        Schema::table('vehicles', function (Blueprint $table) {
            $table->index('status');
            $table->index('type');
        });
    }

    public function down(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['submitted_at']);
            $table->dropIndex(['vehicle_id']);
            $table->dropIndex(['start_date']);
            $table->dropIndex(['end_date']);
            $table->dropIndex(['user_id', 'submitted_at']);
            $table->dropIndex(['status', 'submitted_at']);
        });

        Schema::table('app_notifications', function (Blueprint $table) {
            $table->dropIndex(['is_read']);
            $table->dropIndex(['type']);
            $table->dropIndex(['created_at']);
            $table->dropIndex(['user_id', 'created_at']);
            $table->dropIndex(['is_read', 'created_at']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['role']);
        });

        Schema::table('vehicles', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropIndex(['type']);
        });
    }
};
