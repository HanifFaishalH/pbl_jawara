<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TransaksiDetailModel extends Model
{
    use HasFactory;

    protected $table = 't_transaksi_detail';
    protected $primaryKey = 'detail_id';
    protected $fillable = ['transaksi_id', 'barang_id', 'harga', 'jumlah', 'subtotal'];

    // Relasi ke transaksi
    public function transaksi()
    {
        return $this->belongsTo(TransaksiModel::class, 'transaksi_id', 'transaksi_id');
    }

    // Relasi ke barang
    public function barang()
    {
        return $this->belongsTo(BarangModel::class, 'barang_id', 'barang_id');
    }
}
