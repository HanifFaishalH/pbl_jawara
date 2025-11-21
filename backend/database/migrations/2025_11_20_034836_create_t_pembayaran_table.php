<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_pembayaran', function (Blueprint $table) {
            $table->id('pembayaran_id');
            $table->unsignedBigInteger('transaksi_id');

            $table->string('metode', 50); // ewallet, transfer, cod, dll
            $table->integer('jumlah_bayar');
            $table->string('status', 20)->default('pending'); // pending, sukses, gagal
            $table->string('bukti_pembayaran')->nullable();

            $table->timestamps();

            $table->foreign('transaksi_id')->references('transaksi_id')->on('t_transaksi');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_pembayaran');
    }
};
