<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TransaksiDetailSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('t_transaksi_detail')->insert([
            [
                'transaksi_id' => 1,
                'barang_id' => 1, // BRG-CAP-001
                'harga' => 150000,
                'jumlah' => 2,
                'subtotal' => 300000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'transaksi_id' => 1,
                'barang_id' => 3, // BRG-TLS-001
                'harga' => 850000,
                'jumlah' => 1,
                'subtotal' => 850000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
