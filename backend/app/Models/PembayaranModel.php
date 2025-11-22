<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PembayaranModel extends Model
{
    use HasFactory;

    protected $table = 't_pembayaran';
    protected $primaryKey = 'pembayaran_id';
    protected $fillable = [
        'transaksi_id', 'metode', 'jumlah_bayar', 'status', 'bukti_pembayaran'
    ];

    // Relasi ke transaksi
    public function transaksi()
    {
        return $this->belongsTo(TransaksiModel::class, 'transaksi_id', 'transaksi_id');
    }
}
