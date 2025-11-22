<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Notifications\Notifiable;

class usersModel extends Model
{
    use Notifiable;

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
