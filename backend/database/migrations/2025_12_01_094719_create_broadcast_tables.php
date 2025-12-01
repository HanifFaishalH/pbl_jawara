<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_pesan_broadcast', function (Blueprint $table) {
            $table->id('broadcast_id');

            // Ganti 'users' ke 'm_user' biar konsisten
            $table->unsignedBigInteger('admin_id');
            $table->foreign('admin_id')->references('user_id')->on('m_user')->onDelete('cascade');
            
            $table->string('judul');
            $table->text('isi_pesan');
            $table->timestamp('tanggal_kirim')->useCurrent();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_pesan_broadcast');
    }
};
