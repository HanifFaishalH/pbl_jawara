<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_mutasi_warga', function (Blueprint $table) {
            $table->id('mutasi_id');
            $table->foreignId('warga_id')->constrained('t_warga', 'warga_id')->onDelete('cascade');
            $table->enum('mutasi_jenis', ['kelahiran', 'kematian', 'pindah_masuk', 'pindah_keluar', 'perubahan_status']);
            $table->date('mutasi_tanggal');
            $table->text('mutasi_keterangan')->nullable();
            $table->string('mutasi_alamat_asal')->nullable();
            $table->string('mutasi_alamat_tujuan')->nullable();
            $table->string('mutasi_dokumen')->nullable();
            $table->enum('mutasi_status', ['pending', 'disetujui', 'ditolak'])->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_mutasi_warga');
    }
};
