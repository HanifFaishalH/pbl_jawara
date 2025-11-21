<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KategoriSeeder extends Seeder
{

    public function run(): void
    {
        DB::table('m_kategori')->insert([
            [
                'kategori_id' => 1,
                'kategori_kode' => "CAP",
                'kategori_nama' => "Batik Cap",
            ],
            [
                'kategori_id' => 2,
                'kategori_kode' => "TLS",
                'kategori_nama' => "Batik Tulis",
            ],
        ]);
    }
}
