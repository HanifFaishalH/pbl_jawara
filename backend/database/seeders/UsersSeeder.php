<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UsersSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('m_user')->insert([
            [
                'role_id' => 1,
                'email' => 'admin@gmail.com',
                'password' => Hash::make('password'),
                'user_nama_depan' => 'User',
                'user_nama_belakang' => 'Admin',
                'user_tanggal_lahir' => '1990-01-01',
                'user_alamat' => 'Jl. Kenanga',
                'foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_id' => 2,
                'email' => 'rw@gmail.com',
                'password' => Hash::make('password'),
                'user_nama_depan' => 'Ketua',
                'user_nama_belakang' => 'RW',
                'user_tanggal_lahir' => '1991-02-01',
                'user_alamat' => 'Jl. Melati',
                'foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_id' => 3,
                'email' => 'rt@gmail.com',
                'password' => Hash::make('password'),
                'user_nama_depan' => 'Ketua',
                'user_nama_belakang' => 'RT',
                'user_tanggal_lahir' => '1992-03-01',
                'user_alamat' => 'Jl. Mawar',
                'foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_id' => 4,
                'email' => 'sekretaris@gmail.com',
                'password' => Hash::make('password'),
                'user_nama_depan' => 'Sekretaris',
                'user_nama_belakang' => '',
                'user_tanggal_lahir' => '1993-04-01',
                'user_alamat' => 'Jl. Kenanga',
                'foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_id' => 5,
                'email' => 'bendahara@gmail.com',
                'password' => Hash::make('password'),
                'user_nama_depan' => 'Bendahara',
                'user_nama_belakang' => '',
                'user_tanggal_lahir' => '1994-05-01',
                'user_alamat' => 'Jl. Lily',
                'foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_id' => 6,
                'email' => 'warga@gmail.com',
                'password' => Hash::make('password'),
                'user_nama_depan' => 'Warga',
                'user_nama_belakang' => '',
                'user_tanggal_lahir' => '1995-06-01',
                'user_alamat' => 'Jl. Matahari',
                'foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'role_id' => 6,
                'email' => 'yanto@gmail.com',
                'password' => Hash::make('yanto123'),
                'user_nama_depan' => 'Yanto',
                'user_nama_belakang' => 'Sudarsono',
                'user_tanggal_lahir' => '1995-07-12',
                'user_alamat' => 'Jl. Kenanga',
                'foto' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
