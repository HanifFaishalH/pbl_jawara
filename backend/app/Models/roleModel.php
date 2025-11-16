<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class roleModel extends Model
{
    protected $table = 'm_role';
    protected $primaryKey = 'role_id';
    public $timestamps = false;

    protected $fillable = [
        'role_kode',
        'role_nama',
    ];

    public function users() {
        return $this->hasMany(usersModel::class, 'role_id', 'role_id');
    }
}
