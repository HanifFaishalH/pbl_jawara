<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_mutasi_keluarga', function (Blueprint $table) {
            $table->id('mutasi_id');
            $table->foreignId('keluarga_id')->constrained('t_keluarga', 'keluarga_id')->onDelete('cascade');
            $table->enum('mutasi_jenis', ['pindah_rumah', 'keluar_wilayah', 'masuk_wilayah', 'pindah_rt_rw']);
            $table->date('mutasi_tanggal');
            $table->text('mutasi_alamat_lama')->nullable();
            $table->text('mutasi_alamat_baru')->nullable();
            $table->string('mutasi_rt_lama')->nullable();
            $table->string('mutasi_rw_lama')->nullable();
            $table->string('mutasi_rt_baru')->nullable();
            $table->string('mutasi_rw_baru')->nullable();
            $table->text('mutasi_alasan')->nullable();
            $table->text('mutasi_keterangan')->nullable();
            $table->enum('mutasi_status', ['pending', 'disetujui', 'ditolak'])->default('pending');
            $table->string('mutasi_dokumen')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_mutasi_keluarga');
    }
};
