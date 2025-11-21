<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BarangSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('m_barang')->insert([
            // --- Barang Batik Cap ---
            [
                'kategori_id' => 1,
                'barang_kode' => "BRG-CAP-001",
                'barang_nama' => "Batik Cap Motif Kawung",
                'barang_deskripsi' => "Batik Cap dengan motif kawung tradisional.",
                'barang_harga' => 150000,
                'barang_stok' => 50,
                'barang_foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kategori_id' => 1,
                'barang_kode' => "BRG-CAP-002",
                'barang_nama' => "Batik Cap Motif Parang",
                'barang_deskripsi' => "Batik Cap dengan motif parang klasik.",
                'barang_harga' => 175000,
                'barang_stok' => 40,
                'barang_foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // --- Barang Batik Tulis ---
            [
                'kategori_id' => 2,
                'barang_kode' => "BRG-TLS-001",
                'barang_nama' => "Batik Tulis Premium Mega Mendung",
                'barang_deskripsi' => "Batik tulis premium dengan motif mega mendung khas Cirebon.",
                'barang_harga' => 850000,
                'barang_stok' => 10,
                'barang_foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'kategori_id' => 2,
                'barang_kode' => "BRG-TLS-002",
                'barang_nama' => "Batik Tulis Motif Sidomukti",
                'barang_deskripsi' => "Batik tulis eksklusif motif Sidomukti untuk acara resmi.",
                'barang_harga' => 950000,
                'barang_stok' => 8,
                'barang_foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
