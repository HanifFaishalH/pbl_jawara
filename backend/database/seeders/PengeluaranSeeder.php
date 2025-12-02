<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PengeluaranSeeder extends Seeder
{
    public function run(): void
    {
        $data = [
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Beli Sapu',
                'deskripsi' => 'Pembelian alat kebersihan untuk keamanan',
                'jumlah' => 25000,
                'tanggal' => Carbon::now()->subDays(2)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Perbaikan Lampu Jalan',
                'deskripsi' => 'Pemeliharaan lampu jalan utama',
                'jumlah' => 150000,
                'tanggal' => Carbon::now()->subDays(7)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Santunan Anak Yatim',
                'deskripsi' => 'Kegiatan sosial santunan',
                'jumlah' => 50000,
                'tanggal' => Carbon::now()->subDays(15)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Pembangunan Pos RW',
                'deskripsi' => 'Renovasi pos keamanan RT/RW',
                'jumlah' => 320000,
                'tanggal' => Carbon::now()->subDays(21)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Lomba 17an',
                'deskripsi' => 'Penyelenggaraan lomba kemerdekaan',
                'jumlah' => 500000,
                'tanggal' => Carbon::now()->subDays(30)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('t_pengeluaran')->insert($data);
    }
}
