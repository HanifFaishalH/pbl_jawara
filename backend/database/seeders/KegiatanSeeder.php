<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class KegiatanSeeder extends Seeder
{
    public function run()
    {
        // Pastikan folder penyimpanan ada
        Storage::makeDirectory('public/kegiatan');

        $data = [
            [
                'kegiatan_nama' => 'Kerja Bakti Akbar',
                'kegiatan_kategori' => 'Kebersihan & Keamanan',
                'kegiatan_pj' => 'Bapak Budi (RT 01)',
                'kegiatan_tanggal' => '2025-10-21',
                'kegiatan_lokasi' => 'Lingkungan RW 05',
                'kegiatan_deskripsi' => 'Membersihkan saluran air, pemangkasan pohon, dan perbaikan pos kamling.',
                'kegiatan_foto' => 'kegiatan/kegiatan1.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kegiatan_nama' => 'Senam Sehat Lansia',
                'kegiatan_kategori' => 'Kesehatan & Olahraga',
                'kegiatan_pj' => 'Ibu Siti (Kader Posyandu)',
                'kegiatan_tanggal' => '2025-11-05',
                'kegiatan_lokasi' => 'Halaman Balai Desa',
                'kegiatan_deskripsi' => 'Senam pagi bersama lansia dilanjutkan pemeriksaan tensi darah gratis.',
                'kegiatan_foto' => 'kegiatan/kegiatan2.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kegiatan_nama' => 'Pengajian Rutin Bulanan',
                'kegiatan_kategori' => 'Keagamaan',
                'kegiatan_pj' => 'Ustadz Ahmad',
                'kegiatan_tanggal' => '2025-11-10',
                'kegiatan_lokasi' => 'Masjid Al-Ikhlas',
                'kegiatan_deskripsi' => 'Kajian tafsir Al-Quran dan doa bersama untuk keselamatan warga.',
                'kegiatan_foto' => 'kegiatan/kegiatan3.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('t_kegiatan')->insert($data);
    }
}