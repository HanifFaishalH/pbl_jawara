<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_pesan_warga', function (Blueprint $table) {
            $table->id('pesan_id');
            
            // Pastikan sesuai dengan nama kolom di tabel m_user
            $table->unsignedBigInteger('pengirim_id');
            $table->unsignedBigInteger('penerima_id');
            
            $table->foreign('pengirim_id')->references('user_id')->on('m_user')->onDelete('cascade');
            $table->foreign('penerima_id')->references('user_id')->on('m_user')->onDelete('cascade');
            
            $table->text('isi_pesan');
            $table->boolean('dibaca')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_pesan_warga');
    }
};
