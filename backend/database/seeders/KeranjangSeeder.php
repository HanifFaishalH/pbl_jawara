<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KeranjangSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('t_keranjang')->insert([
            [
                'user_id' => 2,
                'barang_id' => 1, // BRG-CAP-001
                'jumlah' => 2,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'user_id' => 2,
                'barang_id' => 3, // BRG-TLS-001
                'jumlah' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
