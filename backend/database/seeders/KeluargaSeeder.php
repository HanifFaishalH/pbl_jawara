<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class KeluargaSeeder extends Seeder
{
    public function run(): void
    {
        $keluarga = [
            [
                'keluarga_no_kk' => '3507012001010001',
                'keluarga_nama_kepala' => 'Ahmad Fauzi',
                'keluarga_alamat' => 'Jl. Melati No. 10, RT 08/RW 03, Karangploso, Malang',
                'rumah_id' => 1,
                'keluarga_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_no_kk' => '3507012001010002',
                'keluarga_nama_kepala' => 'Budi Santoso',
                'keluarga_alamat' => 'Jl. Mawar No. 7, RT 08/RW 03, Karangploso, Malang',
                'rumah_id' => 2,
                'keluarga_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_no_kk' => '3507012001010003',
                'keluarga_nama_kepala' => 'Eko Prasetyo',
                'keluarga_alamat' => 'Jl. Kenanga No. 12, RT 08/RW 03, Karangploso, Malang',
                'rumah_id' => 3,
                'keluarga_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_no_kk' => '3507012001010004',
                'keluarga_nama_kepala' => 'Dewi Lestari',
                'keluarga_alamat' => 'Jl. Anggrek No. 5, RT 08/RW 03, Karangploso, Malang',
                'rumah_id' => 4,
                'keluarga_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_no_kk' => '3507012001010005',
                'keluarga_nama_kepala' => 'Hendra Wijaya',
                'keluarga_alamat' => 'Jl. Dahlia No. 20, RT 08/RW 03, Karangploso, Malang',
                'rumah_id' => 5,
                'keluarga_status' => 'aktif',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ];

        DB::table('t_keluarga')->insert($keluarga);
    }
}
