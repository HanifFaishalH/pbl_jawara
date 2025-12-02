<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id('log_id');
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('log_type');
            $table->string('log_action');
            $table->unsignedBigInteger('log_reference_id')->nullable();
            $table->text('log_description');
            $table->json('log_old_data')->nullable();
            $table->json('log_new_data')->nullable();
            $table->string('log_ip_address')->nullable();
            $table->text('log_user_agent')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('m_user')->onDelete('set null');
            $table->index(['log_type', 'log_reference_id']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activity_logs');
    }
};
