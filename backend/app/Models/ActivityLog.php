<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ActivityLog extends Model
{
    use HasFactory;

    protected $table = 'activity_logs';
    protected $primaryKey = 'log_id';

    protected $fillable = [
        'user_id',
        'log_type',
        'log_action',
        'log_reference_id',
        'log_description',
        'log_old_data',
        'log_new_data',
        'log_ip_address',
        'log_user_agent',
    ];

    protected $casts = [
        'log_old_data' => 'array',
        'log_new_data' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(\App\Models\usersModel::class, 'user_id', 'user_id');
    }
}
