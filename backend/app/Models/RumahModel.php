<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RumahModel extends Model
{
    use HasFactory;

    protected $table = 't_rumah';
    protected $primaryKey = 'rumah_id';

    protected $fillable = [
        'rumah_alamat',
        'rumah_rt',
        'rumah_rw',
        'rumah_kelurahan',
        'rumah_kecamatan',
        'rumah_kota',
        'rumah_provinsi',
        'rumah_kode_pos',
        'rumah_luas_tanah',
        'rumah_luas_bangunan',
        'rumah_status_kepemilikan',
        'rumah_jumlah_penghuni',
        'rumah_status'
    ];

    public function keluarga()
    {
        return $this->hasMany(KeluargaModel::class, 'rumah_id', 'rumah_id');
    }

    public function warga()
    {
        return $this->hasMany(WargaModel::class, 'rumah_id', 'rumah_id');
    }
}
