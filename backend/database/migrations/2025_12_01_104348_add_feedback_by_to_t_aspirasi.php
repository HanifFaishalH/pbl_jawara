<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('t_aspirasi', function (Blueprint $table) {
            // Kolom untuk menyimpan ID pejabat yang membalas
            $table->unsignedBigInteger('feedback_by')->nullable()->after('tanggapan');
        });
    }

    public function down(): void
    {
        Schema::table('t_aspirasi', function (Blueprint $table) {
            $table->dropColumn('feedback_by');
        });
    }
};