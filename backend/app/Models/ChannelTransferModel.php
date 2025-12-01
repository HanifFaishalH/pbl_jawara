<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChannelTransferModel extends Model
{
    use HasFactory;

    protected $table = 't_channel_transfer';
    protected $primaryKey = 'channel_id';

    protected $fillable = [
        'channel_nama',
        'channel_tipe',
        'channel_nomor',
        'channel_pemilik',
        'channel_qr',
        'channel_thumbnail',
        'channel_catatan',
        'channel_status'
    ];
}
