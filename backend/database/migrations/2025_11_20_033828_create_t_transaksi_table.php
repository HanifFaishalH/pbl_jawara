<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_transaksi', function (Blueprint $table) {
            $table->id('transaksi_id');
            $table->unsignedBigInteger('user_id');

            $table->string('transaksi_kode', 30)->unique();
            $table->dateTime('transaksi_tanggal');
            $table->integer('total_harga');
            $table->string('status', 20)->default('pending'); // pending, paid, canceled, selesai

            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('m_user');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_transaksi');
    }
};
