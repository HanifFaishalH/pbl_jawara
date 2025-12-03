<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('m_user', function (Blueprint $table) {
            // Menambahkan kolom jenis kelamin setelah tanggal lahir
            if (!Schema::hasColumn('m_user', 'user_jenis_kelamin')) {
                $table->enum('user_jenis_kelamin', ['L', 'P'])->nullable()->after('user_tanggal_lahir');
            }
        });
    }

    public function down(): void
    {
        Schema::table('m_user', function (Blueprint $table) {
            if (Schema::hasColumn('m_user', 'user_jenis_kelamin')) {
                $table->dropColumn('user_jenis_kelamin');
            }
        });
    }
};
