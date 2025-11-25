<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('m_user', function (Blueprint $table) {
            // Menambahkan kolom user_alamat setelah tanggal lahir
            // Kita buat nullable dulu agar tidak error pada data lama
            $table->text('user_alamat')->nullable()->after('user_tanggal_lahir');
        });
    }

    public function down(): void
    {
        Schema::table('m_user', function (Blueprint $table) {
            $table->dropColumn('user_alamat');
        });
    }
};