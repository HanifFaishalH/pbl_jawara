<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KegiatanModel extends Model
{
    use HasFactory;

    protected $table = 't_kegiatan';
    protected $primaryKey = 'kegiatan_id';

    protected $fillable = [
        'kegiatan_nama',
        'kegiatan_kategori',
        'kegiatan_pj',
        'kegiatan_tanggal',
        'kegiatan_lokasi',
        'kegiatan_deskripsi',
        'kegiatan_foto'
    ];
}