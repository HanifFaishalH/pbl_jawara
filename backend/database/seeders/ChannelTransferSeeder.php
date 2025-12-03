<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ChannelTransferSeeder extends Seeder
{
    public function run(): void
    {
        $channels = [
            [
                'channel_nama' => 'BCA - RT 08 Karangploso',
                'channel_tipe' => 'bank',
                'channel_nomor' => '1234567890',
                'channel_pemilik' => 'RT 08 Karangploso',
                'channel_qr' => null,
                'channel_thumbnail' => null,
                'channel_catatan' => 'Rekening utama untuk iuran RT',
                'channel_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'channel_nama' => 'Mandiri - Bendahara RW',
                'channel_tipe' => 'bank',
                'channel_nomor' => '9876543210',
                'channel_pemilik' => 'Budi Santoso',
                'channel_qr' => null,
                'channel_thumbnail' => null,
                'channel_catatan' => 'Rekening bendahara RW untuk iuran bulanan',
                'channel_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'channel_nama' => 'GoPay - Ketua RT',
                'channel_tipe' => 'ewallet',
                'channel_nomor' => '081234567890',
                'channel_pemilik' => 'Ahmad Fauzi',
                'channel_qr' => null,
                'channel_thumbnail' => null,
                'channel_catatan' => 'Untuk pembayaran cepat via GoPay',
                'channel_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'channel_nama' => 'OVO - Sekretaris RT',
                'channel_tipe' => 'ewallet',
                'channel_nomor' => '082345678901',
                'channel_pemilik' => 'Siti Nurhaliza',
                'channel_qr' => null,
                'channel_thumbnail' => null,
                'channel_catatan' => 'Alternatif pembayaran via OVO',
                'channel_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'channel_nama' => 'QRIS Resmi RT 08',
                'channel_tipe' => 'qris',
                'channel_nomor' => 'QRIS-RT08-2024',
                'channel_pemilik' => 'RT 08 Karangploso',
                'channel_qr' => null,
                'channel_thumbnail' => null,
                'channel_catatan' => 'Scan QRIS untuk pembayaran iuran',
                'channel_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'channel_nama' => 'Dana - Kas RT',
                'channel_tipe' => 'ewallet',
                'channel_nomor' => '083456789012',
                'channel_pemilik' => 'Dewi Lestari',
                'channel_qr' => null,
                'channel_thumbnail' => null,
                'channel_catatan' => 'Pembayaran via Dana',
                'channel_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'channel_nama' => 'BRI - Kas Keamanan',
                'channel_tipe' => 'bank',
                'channel_nomor' => '5678901234',
                'channel_pemilik' => 'Eko Prasetyo',
                'channel_qr' => null,
                'channel_thumbnail' => null,
                'channel_catatan' => 'Khusus untuk iuran keamanan lingkungan',
                'channel_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ];

        DB::table('t_channel_transfer')->insert($channels);
    }
}
