<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PesanWargaSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('t_pesan_warga')->insert([
            [
                'pengirim_id' => 2,
                'penerima_id' => 3,
                'isi_pesan' => 'Halo, apakah besok ikut kerja bakti di RT 05?',
                'dibaca' => false,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'pengirim_id' => 3,
                'penerima_id' => 2,
                'isi_pesan' => 'Iya, saya akan hadir jam 7 pagi.',
                'dibaca' => true,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);
    }
}
