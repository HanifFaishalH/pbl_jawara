<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MutasiKeluargaModel extends Model
{
    use HasFactory;

    protected $table = 't_mutasi_keluarga';
    protected $primaryKey = 'mutasi_id';

    protected $fillable = [
        'keluarga_id',
        'mutasi_jenis',
        'mutasi_tanggal',
        'mutasi_alamat_lama',
        'mutasi_alamat_baru',
        'mutasi_rt_lama',
        'mutasi_rw_lama',
        'mutasi_rt_baru',
        'mutasi_rw_baru',
        'mutasi_alasan',
        'mutasi_keterangan',
        'mutasi_status',
        'mutasi_dokumen'
    ];

    public function keluarga()
    {
        return $this->belongsTo(KeluargaModel::class, 'keluarga_id', 'keluarga_id');
    }
}
