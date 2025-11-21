<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('m_barang', function (Blueprint $table) {
            $table->id('barang_id');
            $table->unsignedBigInteger('kategori_id');

            $table->string('barang_kode', 20)->unique();
            $table->string('barang_nama', 150);
            $table->text('barang_deskripsi')->nullable();
            $table->integer('barang_harga');
            $table->integer('barang_stok')->default(0);
            $table->string('barang_foto')->nullable();

            $table->timestamps();

            $table->foreign('kategori_id')->references('kategori_id')->on('m_kategori');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('m_barang');
    }
};
