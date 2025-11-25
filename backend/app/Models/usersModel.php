<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class usersModel extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'm_user';
    protected $primaryKey = 'user_id';
    public $timestamps = false;

    protected $fillable = [
        'role_id',
        'email',
        'password',
        'user_nama_depan',
        'user_nama_belakang',
        'user_tanggal_lahir',
        'user_alamat',
        'foto',
    ];

    protected $hidden = [
        'password'
    ];

    public function role() {
        return $this->belongsTo(roleModel::class, 'role_id', 'role_id');
    }

    public function keranjang() {
        return $this->hasMany(KeranjangModel::class, 'user_id', 'user_id');
    }

    public function transaksi() {
        return $this->hasMany(TransaksiModel::class, 'user_id', 'user_id');
    }
}
