<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PembayaranIuranModel extends Model
{
    use HasFactory;

    protected $table = 't_pembayaran_iuran';
    protected $primaryKey = 'pembayaran_id';

    protected $fillable = [
        'tagihan_id',
        'bukti_transfer',
        'jumlah_dibayar',
        'tanggal_bayar',
        'status_verifikasi',
        'verified_by',
        'verified_at',
        'catatan_verifikasi',
    ];

    protected $casts = [
        'tanggal_bayar' => 'date',
        'verified_at' => 'datetime',
    ];

    // Relationships
    public function tagihan()
    {
        return $this->belongsTo(TagihanModel::class, 'tagihan_id', 'tagihan_id');
    }

    public function verifier()
    {
        return $this->belongsTo(usersModel::class, 'verified_by', 'user_id');
    }
}
