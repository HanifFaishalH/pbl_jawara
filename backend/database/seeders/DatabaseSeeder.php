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
            
            PesanWargaSeeder::class,
            PesanBroadcastSeeder::class
        ]);
    }
}
