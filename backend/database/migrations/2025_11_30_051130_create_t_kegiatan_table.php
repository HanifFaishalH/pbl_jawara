<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('t_kegiatan', function (Blueprint $table) {
            $table->id('kegiatan_id');
            $table->string('kegiatan_nama', 100);
            $table->string('kegiatan_kategori', 50); // Komunitas, Pendidikan, dll
            $table->string('kegiatan_pj', 100); // Penanggung Jawab
            $table->date('kegiatan_tanggal');
            $table->string('kegiatan_lokasi', 150);
            $table->text('kegiatan_deskripsi');
            $table->string('kegiatan_foto')->nullable(); // Path foto
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('t_kegiatan');
    }
};