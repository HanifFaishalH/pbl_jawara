<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_channel_transfer', function (Blueprint $table) {
            $table->id('channel_id');
            $table->string('channel_nama');
            $table->enum('channel_tipe', ['bank', 'ewallet', 'qris']);
            $table->string('channel_nomor');
            $table->string('channel_pemilik');
            $table->string('channel_qr')->nullable();
            $table->string('channel_thumbnail')->nullable();
            $table->text('channel_catatan')->nullable();
            $table->enum('channel_status', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_channel_transfer');
    }
};
