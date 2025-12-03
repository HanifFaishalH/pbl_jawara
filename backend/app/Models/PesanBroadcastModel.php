<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PesanBroadcastModel extends Model
{
    use HasFactory;

    protected $table = 't_pesan_broadcast';
    protected $primaryKey = 'broadcast_id';
    protected $fillable = [
        'admin_id',
        'judul',
        'isi_pesan',
        'tanggal_kirim',
    ];

    public function admin()
    {
        return $this->belongsTo(usersModel::class, 'admin_id', 'user_id');
    }
}
