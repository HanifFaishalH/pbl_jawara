<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AspirasiModel extends Model
{
    use HasFactory;

    protected $table = 't_aspirasi';
    protected $primaryKey = 'aspirasi_id';

    protected $fillable = [
        'user_id',
        'judul',
        'deskripsi',
        'status',
        'tanggapan',
        'feedback_by' // <-- Field Baru
    ];

    // Relasi ke User Pengirim
    public function user()
    {
        return $this->belongsTo(usersModel::class, 'user_id', 'user_id');
    }

    // Relasi ke User Pejabat (Penanggap)
    public function penanggap()
    {
        return $this->belongsTo(usersModel::class, 'feedback_by', 'user_id');
    }
}