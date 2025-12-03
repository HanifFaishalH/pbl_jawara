<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RumahSeeder extends Seeder
{
    public function run(): void
    {
        $rumah = [
            [
                'rumah_alamat' => 'Jl. Melati No. 10',
                'rumah_rt' => '08',
                'rumah_rw' => '03',
                'rumah_kelurahan' => 'Karangploso',
                'rumah_kecamatan' => 'Karangploso',
                'rumah_kota' => 'Malang',
                'rumah_provinsi' => 'Jawa Timur',
                'rumah_kode_pos' => '65152',
                'rumah_luas_tanah' => '120',
                'rumah_luas_bangunan' => '80',
                'rumah_status_kepemilikan' => 'milik_sendiri',
                'rumah_jumlah_penghuni' => 4,
                'rumah_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'rumah_alamat' => 'Jl. Mawar No. 7',
                'rumah_rt' => '08',
                'rumah_rw' => '03',
                'rumah_kelurahan' => 'Karangploso',
                'rumah_kecamatan' => 'Karangploso',
                'rumah_kota' => 'Malang',
                'rumah_provinsi' => 'Jawa Timur',
                'rumah_kode_pos' => '65152',
                'rumah_luas_tanah' => '90',
                'rumah_luas_bangunan' => '60',
                'rumah_status_kepemilikan' => 'kontrak',
                'rumah_jumlah_penghuni' => 3,
                'rumah_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'rumah_alamat' => 'Jl. Kenanga No. 12',
                'rumah_rt' => '08',
                'rumah_rw' => '03',
                'rumah_kelurahan' => 'Karangploso',
                'rumah_kecamatan' => 'Karangploso',
                'rumah_kota' => 'Malang',
                'rumah_provinsi' => 'Jawa Timur',
                'rumah_kode_pos' => '65152',
                'rumah_luas_tanah' => '150',
                'rumah_luas_bangunan' => '100',
                'rumah_status_kepemilikan' => 'milik_sendiri',
                'rumah_jumlah_penghuni' => 5,
                'rumah_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'rumah_alamat' => 'Jl. Anggrek No. 5',
                'rumah_rt' => '08',
                'rumah_rw' => '03',
                'rumah_kelurahan' => 'Karangploso',
                'rumah_kecamatan' => 'Karangploso',
                'rumah_kota' => 'Malang',
                'rumah_provinsi' => 'Jawa Timur',
                'rumah_kode_pos' => '65152',
                'rumah_luas_tanah' => '100',
                'rumah_luas_bangunan' => '70',
                'rumah_status_kepemilikan' => 'sewa',
                'rumah_jumlah_penghuni' => 2,
                'rumah_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'rumah_alamat' => 'Jl. Dahlia No. 20',
                'rumah_rt' => '08',
                'rumah_rw' => '03',
                'rumah_kelurahan' => 'Karangploso',
                'rumah_kecamatan' => 'Karangploso',
                'rumah_kota' => 'Malang',
                'rumah_provinsi' => 'Jawa Timur',
                'rumah_kode_pos' => '65152',
                'rumah_luas_tanah' => '200',
                'rumah_luas_bangunan' => '150',
                'rumah_status_kepemilikan' => 'milik_sendiri',
                'rumah_jumlah_penghuni' => 6,
                'rumah_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ];

        DB::table('t_rumah')->insert($rumah);
    }
}
