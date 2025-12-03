<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
            UsersSeeder::class,
            KategoriSeeder::class,
            BarangSeeder::class,

            KeranjangSeeder::class,
            TransaksiSeeder::class,
            TransaksiDetailSeeder::class,
            PembayaranSeeder::class,
            KegiatanSeeder::class,

            RumahSeeder::class,
            KeluargaSeeder::class,
            WargaSeeder::class,
            MutasiWargaSeeder::class,
            MutasiKeluargaSeeder::class,
            ChannelTransferSeeder::class,
            AspirasiSeeder::class,

            PesanWargaSeeder::class,
            PesanBroadcastSeeder::class,
            PemasukanSeeder::class,
            PengeluaranSeeder::class,
        ]);
    }
}
