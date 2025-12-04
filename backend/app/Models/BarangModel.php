<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BarangModel extends Model
{
    use HasFactory;

    protected $table = 'm_barang';
    protected $primaryKey = 'barang_id';
    protected $fillable = [
        'kategori_id', 'user_id', 'barang_kode', 'barang_nama', 
        'barang_deskripsi', 'barang_harga', 'barang_stok', 'barang_foto'
    ];
    protected $casts = [
        'barang_harga' => 'integer',
        'barang_stok' => 'integer'
    ];

    // Relasi ke kategori
    public function kategori()
    {
        return $this->belongsTo(KategoriModel::class, 'kategori_id', 'kategori_id');
    }

    // Relasi ke keranjang
    public function keranjang()
    {
        return $this->hasMany(KeranjangModel::class, 'barang_id', 'barang_id');
    }

    // Relasi ke transaksi detail
    public function detailTransaksi()
    {
        return $this->hasMany(TransaksiDetailModel::class, 'barang_id', 'barang_id');
    }

    public function user()
    {
        // Asumsi di tabel m_barang ada kolom user_id (pemilik barang)
        return $this->belongsTo(usersModel::class, 'user_id', 'user_id');
    }
}
