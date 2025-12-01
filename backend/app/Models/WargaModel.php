<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WargaModel extends Model
{
    use HasFactory;

    protected $table = 't_warga';
    protected $primaryKey = 'warga_id';

    protected $fillable = [
        'warga_nama',
        'warga_nik',
        'warga_tempat_lahir',
        'warga_tanggal_lahir',
        'warga_jenis_kelamin',
        'warga_agama',
        'warga_pendidikan',
        'warga_pekerjaan',
        'warga_status_perkawinan',
        'warga_telepon',
        'warga_email',
        'keluarga_id',
        'rumah_id',
        'warga_status'
    ];

    public function keluarga()
    {
        return $this->belongsTo(KeluargaModel::class, 'keluarga_id', 'keluarga_id');
    }

    public function rumah()
    {
        return $this->belongsTo(RumahModel::class, 'rumah_id', 'rumah_id');
    }
}
