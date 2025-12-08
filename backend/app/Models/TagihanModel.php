<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TagihanModel extends Model
{
    use HasFactory;

    protected $table = 't_tagihan';
    protected $primaryKey = 'tagihan_id';

    protected $fillable = [
        'kategori_id',
        'warga_id',
        'keluarga_id',
        'created_by',
        'kode_tagihan',
        'nominal',
        'tanggal_tagihan',
        'jatuh_tempo',
        'status',
        'keterangan',
    ];

    protected $casts = [
        'tanggal_tagihan' => 'date',
        'jatuh_tempo' => 'date',
    ];

    // Relationships
    public function kategori()
    {
        return $this->belongsTo(KategoriModel::class, 'kategori_id', 'kategori_id');
    }

    public function warga()
    {
        return $this->belongsTo(WargaModel::class, 'warga_id', 'warga_id');
    }

    public function keluarga()
    {
        return $this->belongsTo(KeluargaModel::class, 'keluarga_id', 'keluarga_id');
    }

    public function creator()
    {
        return $this->belongsTo(usersModel::class, 'created_by', 'user_id');
    }

    public function pembayaran()
    {
        return $this->hasMany(PembayaranIuranModel::class, 'tagihan_id', 'tagihan_id');
    }
}
