<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PesanBroadcastSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('t_pesan_broadcast')->insert([
            [
                'admin_id' => 1,
                'judul' => 'Kegiatan Bersih Lingkungan',
                'isi_pesan' => 'Seluruh warga diminta hadir pada kegiatan bersih lingkungan hari Minggu pukul 07.00.',
                'tanggal_kirim' => Carbon::now(),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);
    }
}
