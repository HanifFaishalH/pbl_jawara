<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PembayaranSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('t_pembayaran')->insert([
            [
                'transaksi_id' => 1,
                'metode' => 'transfer',
                'jumlah_bayar' => 1150000,
                'status' => 'sukses',
                'bukti_pembayaran' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
