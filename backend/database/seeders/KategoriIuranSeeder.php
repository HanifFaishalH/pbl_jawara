<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KategoriIuranSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('m_kategori')->insertOrIgnore([
            [
                'kategori_kode' => 'IUR-WARGA',
                'kategori_nama' => 'Iuran Warga',
            ],
            [
                'kategori_kode' => 'SUM-ACARA',
                'kategori_nama' => 'Sumbangan Acara',
            ],
            [
                'kategori_kode' => 'SEWA-LAP',
                'kategori_nama' => 'Sewa Lapangan',
            ],
        ]);
    }
}
