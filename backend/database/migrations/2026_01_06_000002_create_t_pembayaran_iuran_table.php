<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_pembayaran_iuran', function (Blueprint $table) {
            $table->id('pembayaran_id');
            $table->unsignedBigInteger('tagihan_id');
            $table->string('bukti_transfer')->nullable(); // Path foto bukti
            $table->integer('jumlah_dibayar');
            $table->date('tanggal_bayar');
            $table->enum('status_verifikasi', ['Pending', 'Diterima', 'Ditolak'])->default('Pending');
            $table->unsignedBigInteger('verified_by')->nullable(); // Bendahara yang verifikasi
            $table->timestamp('verified_at')->nullable();
            $table->text('catatan_verifikasi')->nullable();
            $table->timestamps();

            $table->foreign('tagihan_id')->references('tagihan_id')->on('t_tagihan')->onDelete('cascade');
            $table->foreign('verified_by')->references('user_id')->on('m_user')->onDelete('set null');
            
            $table->index('status_verifikasi');
            $table->index('tanggal_bayar');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_pembayaran_iuran');
    }
};
