<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_transaksi_detail', function (Blueprint $table) {
            $table->id('detail_id');
            $table->unsignedBigInteger('transaksi_id');
            $table->unsignedBigInteger('barang_id');

            $table->integer('harga');
            $table->integer('jumlah');
            $table->integer('subtotal');

            $table->timestamps();

            $table->foreign('transaksi_id')->references('transaksi_id')->on('t_transaksi');
            $table->foreign('barang_id')->references('barang_id')->on('m_barang');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_transaksi_detail');
    }
};
