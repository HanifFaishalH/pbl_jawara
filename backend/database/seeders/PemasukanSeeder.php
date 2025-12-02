<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PemasukanSeeder extends Seeder
{
    public function run(): void
    {
        $data = [
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Iuran Bulanan',
                'deskripsi' => 'Iuran rutin bulanan warga RT 01',
                'jumlah' => 500000,
                'tanggal' => Carbon::now()->subDays(5)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Sumbangan Acara',
                'deskripsi' => 'Donasi untuk acara 17 Agustus',
                'jumlah' => 750000,
                'tanggal' => Carbon::now()->subDays(10)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Sewa Lapangan',
                'deskripsi' => 'Hasil sewa lapangan futsal',
                'jumlah' => 300000,
                'tanggal' => Carbon::now()->subDays(12)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Bantuan Pemerintah',
                'deskripsi' => 'Dana bantuan pembangunan dari kelurahan',
                'jumlah' => 5000000,
                'tanggal' => Carbon::now()->subDays(20)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 1,
                'kategori_id' => null,
                'judul' => 'Iuran Keamanan',
                'deskripsi' => 'Iuran untuk sistem keamanan lingkungan',
                'jumlah' => 350000,
                'tanggal' => Carbon::now()->subDays(3)->toDateString(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('t_pemasukan')->insert($data);
    }
}
