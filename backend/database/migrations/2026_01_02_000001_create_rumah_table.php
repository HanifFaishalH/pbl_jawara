<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_rumah', function (Blueprint $table) {
            $table->id('rumah_id');
            $table->string('rumah_alamat');
            $table->string('rumah_rt')->nullable();
            $table->string('rumah_rw')->nullable();
            $table->string('rumah_kelurahan')->nullable();
            $table->string('rumah_kecamatan')->nullable();
            $table->string('rumah_kota')->nullable();
            $table->string('rumah_provinsi')->nullable();
            $table->string('rumah_kode_pos')->nullable();
            $table->string('rumah_luas_tanah')->nullable();
            $table->string('rumah_luas_bangunan')->nullable();
            $table->enum('rumah_status_kepemilikan', ['milik_sendiri', 'kontrak', 'sewa', 'lainnya'])->default('milik_sendiri');
            $table->integer('rumah_jumlah_penghuni')->default(0);
            $table->enum('rumah_status', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_rumah');
    }
};
