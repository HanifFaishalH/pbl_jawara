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
        Schema::create('m_user', function (Blueprint $table) {
            $table->id('user_id');
            $table->unsignedBigInteger('role_id');

            // authenctication
            $table->string('email', 50)->unique();
            $table->string('password', 100);

            // general
            $table->string('user_nama_depan', 50);
            $table->string('user_nama_belakang', 50);
            $table->date('user_tanggal_lahir');
            $table->string('foto')->nullable();

            $table->timestamps();

            // foreign key
            $table->foreign('role_id')->references('role_id')->on('m_role');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('m_user');
    }
};
