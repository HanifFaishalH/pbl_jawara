<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TransaksiModel extends Model
{
    use HasFactory;

    protected $table = 't_transaksi';
    protected $primaryKey = 'transaksi_id';
    protected $fillable = [
        'user_id', 'transaksi_kode', 'transaksi_tanggal', 'total_harga', 'status'
    ];

    // Relasi ke user
    public function user()
    {
        return $this->belongsTo(usersModel::class, 'user_id', 'user_id');
    }

    // Relasi ke detail transaksi
    public function detail()
    {
        return $this->hasMany(TransaksiDetailModel::class, 'transaksi_id', 'transaksi_id');
    }

    // Relasi ke pembayaran
    public function pembayaran()
    {
        return $this->hasOne(PembayaranModel::class, 'transaksi_id', 'transaksi_id');
    }
}
