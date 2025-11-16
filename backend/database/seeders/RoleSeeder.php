<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('m_role')->insert([
            [
                'role_kode' => 'ADM',
                'role_nama' => 'Admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_kode' => 'RW',
                'role_nama' => 'Ketua RW',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_kode' => 'RT',
                'role_nama' => 'Ketua RT',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_kode' => 'SEK',
                'role_nama' => 'Sekretaris',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_kode' => 'BEN',
                'role_nama' => 'Bendahara',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_kode' => 'WRG',
                'role_nama' => 'Warga',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
