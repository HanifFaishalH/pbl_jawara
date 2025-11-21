<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TransaksiSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('t_transaksi')->insert([
            [
                'user_id' => 2,
                'transaksi_kode' => 'TRX-0001',
                'transaksi_tanggal' => now(),
                'total_harga' => 1150000,
                'status' => 'paid',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
