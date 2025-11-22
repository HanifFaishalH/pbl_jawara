<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KeranjangModel extends Model
{
    use HasFactory;

    protected $table = 't_keranjang';
    protected $primaryKey = 'keranjang_id';
    protected $fillable = ['user_id', 'barang_id', 'jumlah'];

    // Relasi ke user
    public function user()
    {
        return $this->belongsTo(usersModel::class, 'user_id', 'user_id');
    }

    // Relasi ke barang
    public function barang()
    {
        return $this->belongsTo(BarangModel::class, 'barang_id', 'barang_id');
    }
}
