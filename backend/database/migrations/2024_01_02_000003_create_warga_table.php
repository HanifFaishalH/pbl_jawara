<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_warga', function (Blueprint $table) {
            $table->id('warga_id');
            $table->string('warga_nama');
            $table->string('warga_nik', 16)->unique();
            $table->string('warga_tempat_lahir')->nullable();
            $table->date('warga_tanggal_lahir')->nullable();
            $table->enum('warga_jenis_kelamin', ['L', 'P'])->nullable();
            $table->string('warga_agama')->nullable();
            $table->string('warga_pendidikan')->nullable();
            $table->string('warga_pekerjaan')->nullable();
            $table->string('warga_status_perkawinan')->nullable();
            $table->string('warga_telepon')->nullable();
            $table->string('warga_email')->nullable();
            $table->foreignId('keluarga_id')->nullable()->constrained('t_keluarga', 'keluarga_id')->onDelete('set null');
            $table->foreignId('rumah_id')->nullable()->constrained('t_rumah', 'rumah_id')->onDelete('set null');
            $table->enum('warga_status', ['aktif', 'nonaktif', 'pindah', 'meninggal'])->default('aktif');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_warga');
    }
};
