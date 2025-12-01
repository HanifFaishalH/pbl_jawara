<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PesanWargaModel extends Model
{
    use HasFactory;

    protected $table = 't_pesan_warga';
    protected $primaryKey = 'pesan_id';
    protected $fillable = [
        'pengirim_id', 
        'penerima_id', 
        'isi_pesan', 
        'dibaca'
    ];

    public function pengirim() {
        return $this->belongsTo(usersModel::class, 'pengirim_id','user_id');
    }

    public function penerima() {
        return $this->belongsTo(usersModel::class, 'pengirim_id','user_id');
    }
}
