<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PengeluaranModel extends Model
{
    use HasFactory;

    protected $table = 't_pengeluaran';
    protected $primaryKey = 'pengeluaran_id';
    protected $fillable = [
        'user_id', 'kategori_id', 'judul', 'deskripsi', 'jumlah', 'tanggal'
    ];

    public function user()
    {
        return $this->belongsTo(usersModel::class, 'user_id', 'user_id');
    }

    public function kategori()
    {
        return $this->belongsTo(KategoriModel::class, 'kategori_id', 'kategori_id');
    }
}
