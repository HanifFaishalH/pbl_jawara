<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class MutasiWargaSeeder extends Seeder
{
    public function run(): void
    {
        $mutasi = [
            [
                'warga_id' => 1,
                'mutasi_jenis' => 'kelahiran',
                'mutasi_tanggal' => '2024-01-15',
                'mutasi_keterangan' => 'Kelahiran bayi laki-laki bernama Ahmad Fauzi, anak pertama dari pasangan Budi dan Siti',
                'mutasi_alamat_asal' => null,
                'mutasi_alamat_tujuan' => null,
                'mutasi_dokumen' => null,
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'warga_id' => 2,
                'mutasi_jenis' => 'pindah_masuk',
                'mutasi_tanggal' => '2024-02-20',
                'mutasi_keterangan' => 'Pindah masuk dari Jakarta untuk tinggal bersama keluarga',
                'mutasi_alamat_asal' => 'Jl. Sudirman No. 100, Jakarta Pusat',
                'mutasi_alamat_tujuan' => 'Jl. Melati No. 10, RT 08/RW 03',
                'mutasi_dokumen' => null,
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'warga_id' => 3,
                'mutasi_jenis' => 'pindah_keluar',
                'mutasi_tanggal' => '2024-03-10',
                'mutasi_keterangan' => 'Pindah keluar wilayah karena pekerjaan di Surabaya',
                'mutasi_alamat_asal' => 'Jl. Mawar No. 5, RT 09/RW 03',
                'mutasi_alamat_tujuan' => 'Jl. Gatot Subroto No. 50, Surabaya',
                'mutasi_dokumen' => null,
                'mutasi_status' => 'pending',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'warga_id' => 4,
                'mutasi_jenis' => 'kematian',
                'mutasi_tanggal' => '2024-04-05',
                'mutasi_keterangan' => 'Meninggal dunia karena sakit. Telah dimakamkan di TPU setempat',
                'mutasi_alamat_asal' => null,
                'mutasi_alamat_tujuan' => null,
                'mutasi_dokumen' => null,
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'warga_id' => 5,
                'mutasi_jenis' => 'perubahan_status',
                'mutasi_tanggal' => '2024-05-15',
                'mutasi_keterangan' => 'Perubahan status dari belum menikah menjadi menikah. Telah menikah dengan Dewi Sartika pada tanggal 10 Mei 2024',
                'mutasi_alamat_asal' => null,
                'mutasi_alamat_tujuan' => null,
                'mutasi_dokumen' => null,
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'warga_id' => 6,
                'mutasi_jenis' => 'kelahiran',
                'mutasi_tanggal' => '2024-06-20',
                'mutasi_keterangan' => 'Kelahiran bayi perempuan bernama Siti Nurhaliza, anak kedua dari pasangan Ahmad dan Fatimah',
                'mutasi_alamat_asal' => null,
                'mutasi_alamat_tujuan' => null,
                'mutasi_dokumen' => null,
                'mutasi_status' => 'pending',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'warga_id' => 7,
                'mutasi_jenis' => 'pindah_masuk',
                'mutasi_tanggal' => '2024-07-01',
                'mutasi_keterangan' => 'Pindah masuk dari Bandung untuk melanjutkan pendidikan',
                'mutasi_alamat_asal' => 'Jl. Asia Afrika No. 25, Bandung',
                'mutasi_alamat_tujuan' => 'Jl. Dahlia No. 20, RT 07/RW 03',
                'mutasi_dokumen' => null,
                'mutasi_status' => 'disetujui',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'warga_id' => 8,
                'mutasi_jenis' => 'perubahan_status',
                'mutasi_tanggal' => '2024-08-10',
                'mutasi_keterangan' => 'Perubahan pekerjaan dari karyawan swasta menjadi PNS',
                'mutasi_alamat_asal' => null,
                'mutasi_alamat_tujuan' => null,
                'mutasi_dokumen' => null,
                'mutasi_status' => 'ditolak',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ];

        DB::table('t_mutasi_warga')->insert($mutasi);
    }
}
