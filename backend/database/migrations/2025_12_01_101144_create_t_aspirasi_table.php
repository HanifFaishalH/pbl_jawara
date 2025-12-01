<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_aspirasi', function (Blueprint $table) {
            $table->id('aspirasi_id');
            $table->unsignedBigInteger('user_id'); 
            $table->string('judul');
            $table->text('deskripsi');
            
            // PERUBAHAN DISINI: Hanya Pending & Diterima
            $table->enum('status', ['Pending', 'Diterima'])->default('Pending');
            
            $table->text('tanggapan')->nullable(); 
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('m_user');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_aspirasi');
    }
};