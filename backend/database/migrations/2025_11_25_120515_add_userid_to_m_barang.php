<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('m_barang', function (Blueprint $table) {
            // Menambahkan kolom user_id setelah kategori_id
            $table->unsignedBigInteger('user_id')->after('kategori_id');
            
            // Menjadikannya Foreign Key (Opsional tapi disarankan)
            $table->foreign('user_id')->references('user_id')->on('m_user')->onDelete('cascade');
        });
    }
};
