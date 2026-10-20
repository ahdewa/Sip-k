<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Driver extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'nip',
        'phone',
        'sim_type',
        'sim_number',
        'status',
        'notes',
        'photo_url',
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function loans()
    {
        return $this->hasMany(Loan::class, 'driver_name', 'name');
    }
}
