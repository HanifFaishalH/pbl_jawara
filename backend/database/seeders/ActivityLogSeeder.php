<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ActivityLog;
use App\Models\usersModel;

class ActivityLogSeeder extends Seeder
{
    public function run(): void
    {
        $admin = usersModel::where('email', 'admin@gmail.com')->first();
        
        if (!$admin) {
            $this->command->warn('Admin user not found. Skipping ActivityLogSeeder.');
            return;
        }

        $logs = [
            [
                'user_id' => $admin->user_id,
                'log_type' => 'warga',
                'log_action' => 'create',
                'log_reference_id' => 1,
                'log_description' => 'Menambahkan data warga: John Doe (NIK: 3201234567890001)',
                'log_old_data' => null,
                'log_new_data' => [
                    'warga_nama' => 'John Doe',
                    'warga_nik' => '3201234567890001',
                    'warga_status' => 'aktif'
                ],
                'log_ip_address' => '127.0.0.1',
                'log_user_agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                'created_at' => now()->subDays(5),
            ],
            [
                'user_id' => $admin->user_id,
                'log_type' => 'channel',
                'log_action' => 'create',
                'log_reference_id' => 1,
                'log_description' => 'Menambahkan channel transfer: BCA (bank)',
                'log_old_data' => null,
                'log_new_data' => [
                    'channel_nama' => 'BCA',
                    'channel_tipe' => 'bank',
                    'channel_nomor' => '1234567890'
                ],
                'log_ip_address' => '127.0.0.1',
                'log_user_agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                'created_at' => now()->subDays(4),
            ],
            [
                'user_id' => $admin->user_id,
                'log_type' => 'warga',
                'log_action' => 'update',
                'log_reference_id' => 1,
                'log_description' => 'Mengubah data warga: John Doe (NIK: 3201234567890001)',
                'log_old_data' => [
                    'warga_pekerjaan' => 'Karyawan Swasta'
                ],
                'log_new_data' => [
                    'warga_pekerjaan' => 'Wiraswasta'
                ],
                'log_ip_address' => '127.0.0.1',
                'log_user_agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                'created_at' => now()->subDays(3),
            ],
        ];

        foreach ($logs as $log) {
            ActivityLog::create($log);
        }

        $this->command->info('Activity logs seeded successfully!');
    }
}
