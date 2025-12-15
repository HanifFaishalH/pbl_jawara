<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class NotifikasiSeeder extends Seeder
{
    /**
     * Seeder ini hanya untuk testing/development.
     * Di production, notifikasi akan dibuat otomatis melalui NotifikasiHelper
     * saat ada aktivitas admin seperti:
     * - Kegiatan baru/update/delete
     * - Aspirasi baru/status update
     * - Broadcast baru
     * - Transaksi baru/status update
     * - Iuran baru/verifikasi pembayaran
     * - User baru/status update
     * - Data warga/keluarga baru
     */
    public function run(): void
    {
        // Hanya insert notifikasi sample untuk user pertama (admin)
        $adminUser = DB::table('m_user')->where('role_id', 1)->first();
        
        if (!$adminUser) {
            $this->command->warn('Tidak ada admin ditemukan. Seeder notifikasi dilewati.');
            return;
        }

        $notifikasi = [
            [
                'user_id' => $adminUser->user_id,
                'notifikasi_judul' => 'Selamat Datang!',
                'notifikasi_pesan' => 'Sistem notifikasi telah aktif. Semua aktivitas admin akan menghasilkan notifikasi otomatis.',
                'notifikasi_tipe' => 'success',
                'notifikasi_link' => '/dashboard',
                'is_read' => false,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ];

        DB::table('t_notifikasi')->insert($notifikasi);
        
        $this->command->info('Notifikasi sample berhasil dibuat. Notifikasi real akan muncul dari aktivitas admin.');
    }
}

