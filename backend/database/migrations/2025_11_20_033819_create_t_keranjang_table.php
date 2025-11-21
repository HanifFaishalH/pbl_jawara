<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_keranjang', function (Blueprint $table) {
            $table->id('keranjang_id');
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('barang_id');

            $table->integer('jumlah')->default(1);

            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('m_user');
            $table->foreign('barang_id')->references('barang_id')->on('m_barang');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_keranjang');
    }
};
