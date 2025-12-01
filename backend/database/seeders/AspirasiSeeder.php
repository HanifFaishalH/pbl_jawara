<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AspirasiSeeder extends Seeder
{
    public function run(): void
    {
        $wargaId = DB::table('m_user')->where('role_id', 6)->first()->user_id;

        DB::table('t_aspirasi')->insert([
            [
                'user_id' => $wargaId,
                'judul' => 'Lampu Jalan Mati',
                'deskripsi' => 'Lampu di jalan mawar no 4 mati total.',
                'status' => 'Pending', // Valid
                'tanggapan' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => $wargaId,
                'judul' => 'Jadwal Ronda',
                'deskripsi' => 'Mohon jadwal ronda diperbaharui.',
                'status' => 'Diterima', // Valid
                'tanggapan' => 'Akan segera kami rapatkan.',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}