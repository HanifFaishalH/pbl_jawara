<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class MutasiKeluargaSeeder extends Seeder
{
    public function run(): void
    {
        $mutasi = [
            [
                'keluarga_id' => 1,
                'mutasi_jenis' => 'pindah_rumah',
                'mutasi_tanggal' => '2024-10-15',
                'mutasi_alamat_lama' => 'Jl. Melati No. 10, RT 08/RW 03',
                'mutasi_alamat_baru' => 'Jl. Mawar No. 5, RT 09/RW 03',
                'mutasi_rt_lama' => '08',
                'mutasi_rw_lama' => '03',
                'mutasi_rt_baru' => '09',
                'mutasi_rw_baru' => '03',
                'mutasi_alasan' => 'Pindah rumah karena dekat dengan tempat kerja',
                'mutasi_keterangan' => 'Proses pindah sudah selesai',
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_id' => 2,
                'mutasi_jenis' => 'keluar_wilayah',
                'mutasi_tanggal' => '2024-09-20',
                'mutasi_alamat_lama' => 'Jl. Anggrek No. 15, RT 05/RW 02',
                'mutasi_alamat_baru' => 'Jl. Sudirman No. 100, Jakarta Pusat',
                'mutasi_rt_lama' => '05',
                'mutasi_rw_lama' => '02',
                'mutasi_rt_baru' => null,
                'mutasi_rw_baru' => null,
                'mutasi_alasan' => 'Pindah ke Jakarta karena pekerjaan',
                'mutasi_keterangan' => 'Surat pindah sudah diproses',
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_id' => 3,
                'mutasi_jenis' => 'masuk_wilayah',
                'mutasi_tanggal' => '2024-11-01',
                'mutasi_alamat_lama' => 'Jl. Gatot Subroto No. 50, Surabaya',
                'mutasi_alamat_baru' => 'Jl. Dahlia No. 20, RT 07/RW 03',
                'mutasi_rt_lama' => null,
                'mutasi_rw_lama' => null,
                'mutasi_rt_baru' => '07',
                'mutasi_rw_baru' => '03',
                'mutasi_alasan' => 'Pindah dari Surabaya untuk tinggal bersama keluarga',
                'mutasi_keterangan' => 'Keluarga baru di wilayah ini',
                'mutasi_status' => 'pending',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_id' => 1,
                'mutasi_jenis' => 'pindah_rt_rw',
                'mutasi_tanggal' => '2024-08-10',
                'mutasi_alamat_lama' => 'Jl. Kenanga No. 8, RT 06/RW 02',
                'mutasi_alamat_baru' => 'Jl. Kenanga No. 8, RT 08/RW 03',
                'mutasi_rt_lama' => '06',
                'mutasi_rw_lama' => '02',
                'mutasi_rt_baru' => '08',
                'mutasi_rw_baru' => '03',
                'mutasi_alasan' => 'Perubahan batas wilayah RT/RW',
                'mutasi_keterangan' => 'Alamat tetap sama, hanya perubahan RT/RW',
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'keluarga_id' => 2,
                'mutasi_jenis' => 'pindah_rumah',
                'mutasi_tanggal' => '2024-07-25',
                'mutasi_alamat_lama' => 'Jl. Flamboyan No. 12, RT 04/RW 01',
                'mutasi_alamat_baru' => 'Jl. Anggrek No. 15, RT 05/RW 02',
                'mutasi_rt_lama' => '04',
                'mutasi_rw_lama' => '01',
                'mutasi_rt_baru' => '05',
                'mutasi_rw_baru' => '02',
                'mutasi_alasan' => 'Rumah lama terlalu kecil untuk keluarga yang berkembang',
                'mutasi_keterangan' => null,
                'mutasi_status' => 'ditolak',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ];

        DB::table('t_mutasi_keluarga')->insert($mutasi);
    }
}
