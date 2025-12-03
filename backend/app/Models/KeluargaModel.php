<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KeluargaModel extends Model
{
    use HasFactory;

    protected $table = 't_keluarga';
    protected $primaryKey = 'keluarga_id';

    protected $fillable = [
        'keluarga_no_kk',
        'keluarga_nama_kepala',
        'keluarga_alamat',
        'rumah_id',
        'keluarga_status'
    ];

    public function rumah()
    {
        return $this->belongsTo(RumahModel::class, 'rumah_id', 'rumah_id');
    }

    public function warga()
    {
        return $this->hasMany(WargaModel::class, 'keluarga_id', 'keluarga_id');
    }
}
