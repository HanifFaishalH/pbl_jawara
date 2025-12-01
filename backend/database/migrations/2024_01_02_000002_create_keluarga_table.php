<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('t_keluarga', function (Blueprint $table) {
            $table->id('keluarga_id');
            $table->string('keluarga_no_kk')->unique();
            $table->string('keluarga_nama_kepala');
            $table->text('keluarga_alamat');
            $table->foreignId('rumah_id')->nullable()->constrained('t_rumah', 'rumah_id')->onDelete('set null');
            $table->enum('keluarga_status', ['aktif', 'nonaktif'])->default('aktif');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('t_keluarga');
    }
};
