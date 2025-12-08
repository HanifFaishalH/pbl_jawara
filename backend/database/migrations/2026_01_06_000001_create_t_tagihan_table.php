<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_tagihan', function (Blueprint $table) {
            $table->id('tagihan_id');
            $table->unsignedBigInteger('kategori_id'); // Kategori iuran
            $table->unsignedBigInteger('warga_id'); // Warga yang ditagih
            $table->unsignedBigInteger('keluarga_id'); // Keluarga warga
            $table->unsignedBigInteger('created_by'); // Admin/bendahara yang buat tagihan
            $table->string('kode_tagihan', 50)->unique(); // IR-2025-001
            $table->integer('nominal');
            $table->date('tanggal_tagihan'); // Kapan tagihan dibuat
            $table->date('jatuh_tempo'); // Deadline pembayaran
            $table->enum('status', ['Belum Bayar', 'Menunggu Verifikasi', 'Lunas', 'Ditolak'])->default('Belum Bayar');
            $table->text('keterangan')->nullable();
            $table->timestamps();

            $table->foreign('kategori_id')->references('kategori_id')->on('m_kategori')->onDelete('cascade');
            $table->foreign('warga_id')->references('warga_id')->on('t_warga')->onDelete('cascade');
            $table->foreign('keluarga_id')->references('keluarga_id')->on('t_keluarga')->onDelete('cascade');
            $table->foreign('created_by')->references('user_id')->on('m_user')->onDelete('cascade');
            
            $table->index(['warga_id', 'status']);
            $table->index('tanggal_tagihan');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_tagihan');
    }
};
