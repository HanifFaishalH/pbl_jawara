<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MutasiWargaModel extends Model
{
    use HasFactory;

    protected $table = 't_mutasi_warga';
    protected $primaryKey = 'mutasi_id';

    protected $fillable = [
        'warga_id',
        'mutasi_jenis',
        'mutasi_tanggal',
        'mutasi_keterangan',
        'mutasi_alamat_asal',
        'mutasi_alamat_tujuan',
        'mutasi_dokumen',
        'mutasi_status'
    ];

    public function warga()
    {
        return $this->belongsTo(WargaModel::class, 'warga_id', 'warga_id');
    }
}
