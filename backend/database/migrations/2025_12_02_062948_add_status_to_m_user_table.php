<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('m_user', function (Blueprint $table) {
            // Menambahkan kolom status setelah password
            // Menggunakan ENUM agar konsisten
            if (!Schema::hasColumn('m_user', 'status')) {
                $table->enum('status', ['Pending', 'Diterima', 'Ditolak'])
                      ->default('Pending')
                      ->after('password');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('m_user', function (Blueprint $table) {
            if (Schema::hasColumn('m_user', 'status')) {
                $table->dropColumn('status');
            }
        });
    }
};