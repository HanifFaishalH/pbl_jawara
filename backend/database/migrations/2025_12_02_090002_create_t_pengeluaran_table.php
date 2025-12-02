<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_pengeluaran', function (Blueprint $table) {
            $table->id('pengeluaran_id');
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('kategori_id')->nullable();
            $table->string('judul', 150);
            $table->text('deskripsi')->nullable();
            $table->integer('jumlah');
            $table->date('tanggal');
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('m_user')->onDelete('cascade');
            $table->foreign('kategori_id')->references('kategori_id')->on('m_kategori')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_pengeluaran');
    }
};
